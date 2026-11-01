<p align="center">
  <img src="AppIconPreview.png" width="128" alt="MacCalendar simgesi">
</p>

<h1 align="center">MacCalendar</h1>

<p align="center">
  macOS için ülke bayraklı <b>çift dünya saati</b> gösteren (<code>🇹🇷 20:04   🇯🇵 02:04</code>), ücretsiz ve açık kaynak bir <b>menü çubuğu takvimi</b>.<br>
  Swift, AppKit ve SwiftUI ile yazılmıştır; Electron ya da üçüncü taraf kütüphane gerektirmez.
</p>

<p align="center">
  <b>Itsycal</b>, <b>Dato</b> ve <b>Clocker</b>'a ücretsiz bir alternatif: menü çubuğunda aylık takvim ve ikinci bir saat dilimi.
</p>

<p align="center">
  <a href="README.md">🇬🇧 English</a> · <b>🇹🇷 Türkçe</b>
</p>

<p align="center">
  <a href="https://gitlab.com/freeware2/maccalendar/-/releases/permalink/latest/downloads/MacCalendar.pkg"><img src="docs/download-button-tr.png" width="320" alt="MacCalendar'ı macOS için indir"></a>
</p>

<p align="center">
  <a href="https://gitlab.com/freeware2/maccalendar/-/releases">Tüm sürümler</a> · <a href="#i̇ndirme-ve-kurulum">Kurulum adımları</a> · Arayüz Türkçe ve İngilizcedir
</p>

> [!warning] Kurulum paketini ilk açtığınızda macOS onu engeller. Bu beklenen bir durumdur.
> MacCalendar ücretsizdir ve Apple onayından (notarization) geçmemiştir. Bu yüzden indirdiğiniz `MacCalendar-<sürüm>.pkg` dosyasına ilk kez çift tıkladığınızda macOS paketi *doğrulayamadığını* söyler ve açmaz. Bunu bir kez onaylamanız yeterlidir:
>
> 1. Uyarıda **Bitti**'ye tıklayın. *Çöp Sepetine Taşı*'yı **seçmeyin**.
> 2. **Sistem Ayarları ▸ Gizlilik ve Güvenlik**'i açın ve **Güvenlik** bölümüne inin.
> 3. *"MacCalendar-&lt;sürüm&gt;.pkg" Mac'inizi korumak için engellendi* satırında **Yine de Aç**'a tıklayın ve parolanız ya da Touch ID ile onaylayın. Kurulum açılır.
>
> Terminal'i mi tercih edersiniz? `xattr -d com.apple.quarantine ~/Downloads/MacCalendar-*.pkg` komutunu çalıştırıp pakete çift tıklayın.

## Ekran görüntüleri

Menü çubuğunda tarih ve iki saat, tıklayınca açılan takvim ve Ayarlar paneli açıkken aynı pencere.

<p align="center"><img src="docs/screenshots/menu-bar.png" width="338" alt="Menü çubuğu: gün numaralı takvim simgesi, tarih, Türkiye 00:54 ve Japonya 06:54"></p>

<p align="center">
  <img src="docs/screenshots/calendar.png" width="330" alt="Takvim penceresi: bayraklı yerel saat, ikinci saat olarak Tokyo, aylık takvim ve hızlı not alanı">
  &nbsp;
  <img src="docs/screenshots/settings.png" width="330" alt="Ayarlar paneli: ikinci saat şehri, özel etiket, dil, bayrak stili, tarih biçimi, saniye, haftanın ilk günü ve otomatik başlatma">
</p>

## Özellikler

### Menü çubuğu

- **Gün simgesi:** o günün tarihini gösteren küçük takvim simgesi.
- **Tarih ve saat biçimleri:** `30 Eki Cum`, `30.10.2026`, `30 Ekim` ya da yalnızca saat; isteğe bağlı saniye ve bayrak rozetleri.
- **Çift saat (açılıp kapatılabilir):** yalnızca yerel saati (`🇹🇷 20:04`) ya da yanında ikinci bir şehrin saatini (`🇹🇷 20:04   🇯🇵 02:04`) gösterin.
  Beş dizilim: bayrak saatten önce, saatten sonra, ortada, yalnızca ikinci bayrak ya da bayrak ve şehir kodu.

### Takvim penceresi

- **Başlık:** ülkenizin bayrağı (sistem saat dilimi ve bölgesinden), saniyeli büyük canlı saat ve tam tarih.
  İkinci saat açıkken bir kart diğer şehrin bayrağını, adını, saat farkını (örn. `+6 sa`) ve canlı saatini gösterir.
- **Aylık takvim:** hafta sonları renkli, önceki ve sonraki ayın günleri soluk, bugün ve seçili gün vurgulu.
- Herhangi bir ay ya da yıldan tek tıkla dönmek için **Bugün** düğmesi; ay başlığına tıklayarak ay ve yıl seçimi.
- Hafta Pazartesi ya da Pazar başlar; seçim sizin.

### Güne özel hızlı notlar

- Herhangi bir güne tıklayıp kısa bir not ya da hatırlatma ekleyin.
- Not içeren günler takvimde bir noktayla işaretlenir; notlar gün gün listelenir ve silinir.

### 400+ dünya şehri ve saat dilimi

- Büyük şehirler hazır gelir (Tokyo, Londra, New York, Berlin, Paris, Seul, Dubai, Singapur, Los Angeles, Pekin, Sidney, Bakü ve diğerleri).
- 400'den fazla şehir arasında arama yapıp istediğiniz saat dilimini ikinci saat yapın; isterseniz özel bir etiket verin (`TYO`, `Ofis`, `Ev`).

### Dil, oturum açılışı ve çıkış

- **Türkçe, İngilizce ya da sistem dili**; Ayarlar'dan, yeniden başlatmadan değişir: etiketler, menü çubuğu biçimleri, ay ve gün adları anında güncellenir.
- macOS `ServiceManagement` (`SMAppService`) ile **oturum açılışında başlatma**.
- **Çıkış onayı:** güç düğmesi önce sorar; yanlışlıkla tıklamak uygulamayı kapatmaz.

<a name="kurulum"></a>
## İndirme ve kurulum

Paket Apple Silicon ve Intel Mac'lerde çalışır; macOS 13 veya üstü gerekir.

1. Kurulum paketini yukarıdaki [indirme düğmesiyle](https://gitlab.com/freeware2/maccalendar/-/releases/permalink/latest/downloads/MacCalendar.pkg) indirin ya da [Sürümler](https://gitlab.com/freeware2/maccalendar/-/releases) sayfasından bir sürüm seçin.
2. `MacCalendar-<sürüm>.pkg` dosyasına çift tıklayın. **İlk açılışta macOS onu engeller:** aşağıdaki adımları bir kez izleyin.
3. Kurulum adımlarını tamamlayın. MacCalendar **Uygulamalar** klasörüne kurulur, kendiliğinden açılır ve simgesi menü çubuğunda, sistem saatinin yanında belirir.
4. Bundan sonra MacCalendar Mac her açıldığında kendiliğinden başlar. Bunu Ayarlar'dan (*Mac Açıldığında Otomatik Başlat*) kapatabilirsiniz.

Kurulum paketi istemiyor musunuz? Her sürümde bir `MacCalendar-<sürüm>.zip` de var: açın ve `MacCalendar.app`'i **Uygulamalar** klasörüne sürükleyin.

### İlk açılış: kurulum paketine bir kez izin verin

> [!important] macOS kurulum paketini ilk açılışta engeller. Bu bir hata değil, beklenen bir durumdur.
> Paket bir Apple geliştirici kimliğiyle imzalanmamış ve Apple onayından geçmemiştir; bu yüzden macOS onu doğrulayamaz. Bir kez izin verin:
>
> 1. **Pakete çift tıklayın.** macOS, Apple'ın onu doğrulayamadığını söyler ve açmaz. **Bitti**'ye tıklayın. *Çöp Sepetine Taşı*'yı **seçmeyin**.
> 2. **Sistem Ayarları ▸ Gizlilik ve Güvenlik**'i açın ve **Güvenlik** bölümüne inin.
> 3. Paketin engellendiğini belirten satırda **Yine de Aç**'a tıklayın, ardından Mac parolanız ya da Touch ID ile onaylayın. Kurulum açılır.
>
> *Yine de Aç* görünmüyor mu? 1. adımı tekrarlayın: düğme ancak paketi açma denemesinden sonra çıkar. macOS 13 ve 14'te Finder'da pakete sağ tıklayıp **Aç**'ı da seçebilirsiniz.

> [!tip] Terminal mi kullanıyorsunuz? Tek komut aynı işi yapar.
> ```bash
> xattr -d com.apple.quarantine ~/Downloads/MacCalendar-*.pkg
> ```
> macOS'un internetten indirilen dosyalara koyduğu karantina işaretini kaldırır. Sonrasında paket her zamanki gibi çift tıklamayla açılır.

### İndirilen dosyayı doğrulama

Paketi sürüm notlarındaki SHA-256 değeriyle karşılaştırın:

```bash
shasum -a 256 ~/Downloads/MacCalendar-1.1.4.pkg
```

## Kaynak koddan derleme

Xcode komut satırı araçları gerekir (macOS 13 veya üstü).

```bash
./build_app.sh          # MacCalendar.app'i derler (universal: arm64 + x86_64)
./build_app.sh --zip    # ayrıca build/release/MacCalendar-<sürüm>.zip ve SHA-256
scripts/build_pkg.sh    # kurulum paketi: build/release/MacCalendar-<sürüm>.pkg ve SHA-256
```

## Sık sorulan sorular

### MacCalendar ücretsiz mi?

Evet. MacCalendar, GPL-3.0 lisansıyla ücretsiz ve açık kaynaktır; reklam, hesap ya da uygulama içi satın alma yoktur.

### Mac'te menü çubuğunda takvimi nasıl gösteririm?

macOS'un menü çubuğu saatinde aylık görünüm yoktur. MacCalendar'ı kurup menü çubuğundaki tarihe tıklayın: bugünün vurgulandığı aylık takvim, **Bugün** düğmesi ve her gün için hızlı notlar açılır.

### Mac menü çubuğuna ikinci bir saat dilimi ya da dünya saati nasıl eklenir?

MacCalendar'ın Ayarlar'ında çift saati açıp 400'den fazla şehirden birini seçin. Menü çubuğu iki saati ülke bayraklarıyla gösterir, örneğin `🇹🇷 20:04   🇯🇵 02:04`; takvim de saat farkını gösterir.

### Apple Takvim etkinliklerimi gösterir mi?

Hayır. MacCalendar aylık takvimi ve her gün için kendi hızlı notlarını gösterir; Takvim uygulamasındaki etkinlikleri okumaz.

### Hangi Mac'lerde çalışır?

macOS 13 Ventura veya üstü yüklü Apple Silicon ve Intel Mac'lerde.

### macOS neden ilk seferde engelliyor?

MacCalendar, ücretli geliştirici hesabı gerektiren Apple onayından (notarization) geçmemiştir. **Sistem Ayarları ▸ Gizlilik ve Güvenlik ▸ Yine de Aç** ile bir kez izin verin; ayrıntılar [İlk açılış](#i̇lk-açılış-kurulum-paketine-bir-kez-izin-verin) bölümünde.

<sub>Itsycal, Dato ve Clocker yalnızca karşılaştırma için anılmıştır; MacCalendar'ın bunlarla bir bağı yoktur.</sub>

## Lisans

Telif hakkı © 2026 Rafet SAPANCI

MacCalendar özgür yazılımdır: [GNU Genel Kamu Lisansı](LICENSE) sürüm 3 ya da (tercihinize göre) daha sonraki bir sürüm (GPL-3.0-or-later) koşullarıyla kullanabilir, değiştirebilir ve yeniden dağıtabilirsiniz. Değiştirilmiş sürümleri dağıtırsanız kaynak kodlarını da aynı lisansla sunmalısınız. Program **hiçbir garanti olmadan** sunulur; ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
