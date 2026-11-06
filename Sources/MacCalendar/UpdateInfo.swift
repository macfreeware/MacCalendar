import CryptoKit
import Foundation

/// GitLab'daki son sürümün bilgileri (`/api/v4/projects/<yol>/releases/permalink/latest`).
public struct UpdateRelease: Sendable, Equatable {
    public let version: String
    public let notes: String
    public let page: URL?
    /// Uygulamanın zip'i (sabit ad: `MacCalendar.zip`).
    public let archive: URL?
    /// Zip'in SHA-256 özeti dosyası (`MacCalendar.zip.sha256`).
    public let checksum: URL?
}

public enum UpdateFailure: Error, Sendable {
    case notFound
    case http(Int)
    case network(String)
    case missingFiles
    case badChecksumFile
    case checksumMismatch
    case unzipFailed
    case wrongApp
    case badSignature
    case notWritable(String)
}

public enum UpdateInfo {
    public static let archiveName = "MacCalendar.zip"
    public static let checksumName = "MacCalendar.zip.sha256"

    /// Dosya ve sayfa bağlantıları yalnızca `https://gitlab.com` üzerinde olabilir.
    public static func isTrusted(_ url: URL) -> Bool {
        url.scheme?.lowercased() == "https" && url.host?.lowercased() == "gitlab.com"
    }

    /// GitLab sürüm yanıtını çözer. Sürüm etiketi "v1.2.3" ya da "1.2.3". `gitlab.com` dışındaki bağlantılar yok sayılır;
    /// `allowAnyHost` yalnızca geliştirme denemeleri içindir (yerel sahte sürüm).
    public static func parse(_ data: Data, allowAnyHost: Bool = false) throws -> UpdateRelease {
        struct Payload: Decodable {
            let tag_name: String
            let description: String?
            let _links: Links?
            let assets: Assets?
            struct Links: Decodable { let `self`: String? }
            struct Assets: Decodable { let links: [Link]? }
            struct Link: Decodable { let name: String; let url: String; let direct_asset_url: String? }
        }
        let p = try JSONDecoder().decode(Payload.self, from: data)
        let version = p.tag_name.hasPrefix("v") ? String(p.tag_name.dropFirst()) : p.tag_name
        func allowed(_ text: String?) -> URL? {
            guard let url = text.flatMap(URL.init(string:)), allowAnyHost || isTrusted(url) else { return nil }
            return url
        }
        func asset(_ name: String) -> URL? {
            guard let link = p.assets?.links?.first(where: { $0.name == name }) else { return nil }
            return allowed(link.direct_asset_url ?? link.url)
        }
        return UpdateRelease(version: version, notes: p.description ?? "",
                             page: allowed(p._links?.`self`),
                             archive: asset(archiveName), checksum: asset(checksumName))
    }

    /// Noktalı sürümlerin sayısal karşılaştırması: 1.10 > 1.9, 1.2.1 > 1.2.
    public static func isNewer(_ a: String, than b: String) -> Bool {
        let x = a.split(separator: ".").map { Int($0.prefix(while: \.isNumber)) ?? 0 }
        let y = b.split(separator: ".").map { Int($0.prefix(while: \.isNumber)) ?? 0 }
        for i in 0..<max(x.count, y.count) {
            let l = i < x.count ? x[i] : 0, r = i < y.count ? y[i] : 0
            if l != r { return l > r }
        }
        return false
    }

    /// `shasum -a 256` çıktısından özet: "abc…  MacCalendar.zip" ya da yalnızca "abc…". Küçük harfe çevrilir.
    public static func parseChecksum(_ text: String) -> String? {
        guard let first = text.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).first else { return nil }
        let hex = first.lowercased()
        return hex.count == 64 && hex.allSatisfy(\.isHexDigit) ? hex : nil
    }

    /// Sürüm notlarından yalnızca arayüz dilindeki "yenilikler" bölümünü alır; bulamazsa notların tamamını döndürür.
    public static func whatsNew(in notes: String, turkish: Bool) -> String {
        let lines = notes.components(separatedBy: "\n")
        let isHeading: (String) -> Bool = { $0.hasPrefix("#") || $0.hasPrefix("---") }
        let marker = turkish ? "yenilikler" : "What's new"
        guard let start = lines.firstIndex(where: { $0.hasPrefix("#") && $0.contains(marker) }) else { return notes }
        let body = lines[(start + 1)...].prefix { !isHeading($0) }
        return body.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// İndirme, doğrulama ve yerine koyma. Arayüzden ve kullanıcı ayarlarından bağımsızdır; ekransız denemede de bu kod çalışır.
public enum UpdateCore {
    public static func fetch(from url: URL, allowAnyHost: Bool) async throws -> UpdateRelease {
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw http.statusCode == 404 ? UpdateFailure.notFound : UpdateFailure.http(http.statusCode)
            }
            return try UpdateInfo.parse(data, allowAnyHost: allowAnyHost)
        } catch let failure as UpdateFailure {
            throw failure
        } catch {
            throw UpdateFailure.network(error.localizedDescription)
        }
    }

    private static func requireSuccess(_ response: URLResponse) throws {
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw UpdateFailure.http(http.statusCode)
        }
    }

    private static func run(_ tool: String, _ arguments: [String]) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool)
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do { try process.run() } catch { return -1 }
        process.waitUntilExit()
        return process.terminationStatus
    }

    /// Uygulama yerine yazılabilir mi? Sürükleyerek kurulan ya da pkg ile kullanıcıya devredilen kopyada evet;
    /// başka kullanıcıya ait kopyada hayır (o zaman indirme sayfası önerilir).
    public static func canReplace(_ app: URL) -> Bool {
        let files = FileManager.default
        return app.pathExtension == "app"
            && !app.path.contains("/AppTranslocation/")
            && files.isWritableFile(atPath: app.path)
            && files.isWritableFile(atPath: app.deletingLastPathComponent().path)
    }

    /// İndirir, özeti doğrular, açar ve içindeki uygulamayı denetler; kurulmaya hazır uygulamanın yerini döndürür.
    /// Geçici klasör uygulamanın yanında (aynı birimde) olur: değiştirme kopyalama değil yeniden adlandırmadır.
    public static func prepare(_ release: UpdateRelease, replacing current: URL, bundleID: String?) async throws -> (app: URL, workFolder: URL) {
        guard let archiveURL = release.archive, let checksumURL = release.checksum else {
            throw UpdateFailure.missingFiles
        }
        let checksumData: Data
        let downloaded: URL
        do {
            let (data, checksumResponse) = try await URLSession.shared.data(from: checksumURL)
            try requireSuccess(checksumResponse)
            checksumData = data
            let (file, archiveResponse) = try await URLSession.shared.download(from: archiveURL)
            try requireSuccess(archiveResponse)
            downloaded = file
        } catch let failure as UpdateFailure {
            throw failure
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw UpdateFailure.network(error.localizedDescription)
        }
        guard let expected = UpdateInfo.parseChecksum(String(decoding: checksumData, as: UTF8.self)) else {
            throw UpdateFailure.badChecksumFile
        }
        try Task.checkCancellation()

        let files = FileManager.default
        let work: URL
        do {
            work = try files.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: current, create: true)
            let zip = work.appendingPathComponent(UpdateInfo.archiveName)
            try files.moveItem(at: downloaded, to: zip)
            let app = try await Task.detached { () throws -> URL in
                // SHA-256: indirilen dosya sürümdeki özetle aynı mı (yarım ya da değiştirilmiş indirme kurulmaz)?
                let digest = SHA256.hash(data: try Data(contentsOf: zip, options: .mappedIfSafe))
                guard digest.map({ String(format: "%02x", $0) }).joined() == expected else {
                    throw UpdateFailure.checksumMismatch
                }
                let unpacked = work.appendingPathComponent("unpacked", isDirectory: true)
                guard run("/usr/bin/ditto", ["-x", "-k", zip.path, unpacked.path]) == 0 else {
                    throw UpdateFailure.unzipFailed
                }
                // Zip düzeni: MacCalendar/MacCalendar.app ve MacCalendar/LICENSE.txt
                let app = unpacked.appendingPathComponent("MacCalendar/MacCalendar.app", isDirectory: true)
                guard let bundle = Bundle(url: app), bundle.bundleIdentifier == bundleID,
                      bundle.infoDictionary?["CFBundleShortVersionString"] as? String == release.version else {
                    throw UpdateFailure.wrongApp
                }
                guard run("/usr/bin/codesign", ["--verify", "--deep", "--strict", app.path]) == 0 else {
                    throw UpdateFailure.badSignature
                }
                // İndirilen uygulama "internetten indirildi" işaretini taşımasın (kullanıcı güncellemeyi zaten onayladı).
                _ = run("/usr/bin/xattr", ["-dr", "com.apple.quarantine", app.path])
                return app
            }.value
            return (app, work)
        } catch let failure as UpdateFailure {
            throw failure
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw UpdateFailure.notWritable(current.deletingLastPathComponent().path)
        }
    }

    /// Çalışan uygulamanın paketini yenisiyle değiştirir (macOS çalışan bir paketin yerine yenisini koymaya izin verir).
    public static func replace(_ current: URL, with app: URL) throws {
        do {
            _ = try FileManager.default.replaceItemAt(current, withItemAt: app, backupItemName: nil, options: [])
        } catch {
            throw UpdateFailure.notWritable(current.deletingLastPathComponent().path)
        }
    }
}
