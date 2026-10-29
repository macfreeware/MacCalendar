# MacCalendar — macOS Menü Çubuğu Takvim & Çift Dünya Saati
### Native macOS Menu Bar Calendar & Dual World Clock

<p align="center">
  <img src="docs/screenshots/calendar_dual_clock.png" width="280" alt="MacCalendar Flyout" />
  &nbsp;&nbsp;
  <img src="docs/screenshots/settings_panel.png" width="280" alt="MacCalendar Settings" />
  &nbsp;&nbsp;
  <img src="docs/screenshots/about_panel.png" width="280" alt="MacCalendar About" />
</p>

<p align="center">
  <a href="#türkçe"><b>🇹🇷 Türkçe</b></a> &nbsp;•&nbsp; <a href="#english"><b>🇬🇧 English</b></a>
</p>

<p align="center">
  <a href="https://gitlab.com/freeware2/maccalendar/-/releases/permalink/latest/downloads/MacCalendar.zip"><img src="docs/download-button-tr.png" width="320" alt="MacCalendar'ı macOS için indir"></a>
  &nbsp;
  <a href="https://gitlab.com/freeware2/maccalendar/-/releases/permalink/latest/downloads/MacCalendar.zip"><img src="docs/download-button.png" width="341" alt="Download MacCalendar for macOS"></a>
</p>

<p align="center">
  <a href="https://gitlab.com/freeware2/maccalendar/-/releases">Tüm sürümler / All releases</a> · <a href="#kurulum">Kurulum</a> · <a href="#installation">Installation</a>
</p>

---

<a name="türkçe"></a>
## 🇹🇷 Türkçe Tanıtım

**MacCalendar**, macOS menü çubuğunda (Menu Bar) hafif ve zarif bir şekilde çalışan, tek bir tıklamayla açılan modern takvim penceresi sunan, ülke bayraklarıyla birlikte aynı anda **iki farklı dünya saatini** (örneğin `🇹🇷 20:04   🇯🇵 02:04`) gösterebilen yerel (native) bir macOS uygulamasıdır.

Tamamen **Swift**, **AppKit** ve **SwiftUI** teknolojileri kullanılarak macOS ekosistemine tam uyumlu ve yüksek performanslı olarak geliştirilmiştir.

---

### ✨ Öne Çıkan Özellikler

#### 1. Menü Çubuğu (Menu Bar) Görünümü
- **Dinamik Gün Simgesi:** Menü çubuğunda o günün takvim gün numarasını içeren özel tasarlanmış mini simge.
- **Canlı Tarih & Saat Formatları:** İsteğe bağlı olarak tarih (`29 Eki Per`, `29.10.2026`, `29 Ekim` veya sadece saat), saniyeli gösterim ve özelleştirilebilir bayrak rozetleri.
- **Çift Saat Gösterimi (Açılıp Kapatılabilir):**
  - Tek tıkla sadece yerel saati (`🇹🇷 20:04`) veya yerel saatle birlikte seçilen dünya şehrinin saatini (`🇹🇷 20:04   🇯🇵 02:04`) menü çubuğunda yan yana gösterebilme.
  - 5 farklı bayrak ve saat dizilim seçeneği (bayrak başta, bayrak sonda, bayraklar ortada, sadece 2. bayrak veya bayrak + şehir kodu).

#### 2. Açılır Takvim Penceresi (Flyout Panel)
- **Akıllı Başlık Alanı:**
  - Yerel ülke bayrağı, canlı saniyeli büyük dijital saat ve tam gün adı formatlı tarih.
  - İkinci saat aktif olduğunda, hedef ülkenin bayrağı, şehir adı, saat farkı rozeti (örn. `+6 sa`) ve canlı ikinci saat kartı.
- **Aylık Takvim Izgarası:**
  - Cumartesi ve Pazar günleri için belirgin hafta sonu renklendirmesi.
  - Önceki ve sonraki aydan taşan soluk günler, bugünün mavi dolgulu dairesi ve seçili gün vurgusu.
  - **"Bugün"** butonu: Farklı bir aya veya yıla gidildiğinde tek tıkla bugünkü tarihe geri dönme imkânı.
  - Hızlı Ay/Yıl Seçici: Ay başlığına tıklayarak yıl ve ay listesinden anında seçim yapabilme.
  - Haftanın başlangıç gününü (Pazartesi veya Pazar) seçebilme.

#### 3. Güne Özel Hızlı Not & Hatırlatıcılar
- Takvimdeki herhangi bir güne tıklayarak anında hızlı not ekleyebilme.
- Not içeren günler takvim ızgarasında özel bir nokta işareti ile gösterilir.
- Eklenen notları kolayca silebilme ve gün bazlı listeleme.

#### 4. 400+ Dünya Şehri ve Saat Dilimi Arama
- Ön tanımlı popüler metropoller (Tokyo, Londra, New York, Berlin, Paris, Seul, Dubai, Singapur, Los Angeles, Pekin, Sidney, Bakü vb.).
- Entegre **400+ şehir arama motoru** sayesinde dünyanın dört bir yanındaki herhangi bir şehri veya saat dilimini saniyeler içinde bulup ikinci saat olarak atayabilme.
- Özel etiket alanı (örn. `TYO`, `Ofis`, `Ev` vb.).

#### 5. Canlı ve Reaktif Çoklu Dil Desteği
- Uygulama içindeki Ayarlar bölümünden anında **Türkçe**, **English** veya **Sistem Dili** seçebilme.
- Uygulamayı kapatıp açmaya gerek kalmadan tüm arayüz, menü çubuğu formatları, ay ve gün isimleri anında seçilen dile güncellenir.

#### 6. macOS Başlangıcında Otomatik Çalışma & Güvenli Çıkış
- **Otomatik Başlatma:** macOS `ServiceManagement` (`SMAppService`) desteği sayesinde bilgisayarınız her açıldığında arka planda otomatik olarak başlama seçeneği.
- **Güvenli Çıkış Onayı:** Refleks olarak yanlışlıkla güç butonuna basılması durumunda uygulamayı anında kapatmak yerine yerleşik şık bir onay alanı açarak veri ve durum kaybını önler.

---

<a name="kurulum"></a>
### 🚀 Kurulum

macOS 13 veya üstü gerekir. Apple Silicon ve Intel Mac'lerde çalışır (universal).

1. **[MacCalendar.zip](https://gitlab.com/freeware2/maccalendar/-/releases/permalink/latest/downloads/MacCalendar.zip)** dosyasını indirip açın.
2. `MacCalendar.app`'i **Uygulamalar** klasörüne sürükleyin. Yanındaki `LICENSE.txt` lisans metnidir.
3. MacCalendar'ı açın; simgesi menü çubuğunda belirir (Dock'ta görünmez).

> [!warning] İlk açılışta macOS MacCalendar'ı engeller. Bu beklenen bir durumdur.
> MacCalendar ücretsizdir ve Apple onayından (notarization) geçmemiştir; bu yüzden ilk açılışta macOS uygulamayı *doğrulayamadığını* söyler ve açmaz. Yalnızca bir kez izin vermeniz yeterli:
>
> 1. Uyarıda **Bitti**'ye tıklayın. *Çöp Sepetine Taşı*'ya tıklamayın.
> 2. **Sistem Ayarları ▸ Gizlilik ve Güvenlik**'i açıp **Güvenlik** bölümüne inin.
> 3. MacCalendar'ın engellendiğini söyleyen satırda **Yine de Aç**'a tıklayın ve parolanız ya da Touch ID ile onaylayın.
>
> Terminal'i mi tercih edersiniz? `xattr -dr com.apple.quarantine /Applications/MacCalendar.app` komutunu çalıştırıp MacCalendar'ı açın.

Her sürümle birlikte bir SHA-256 değeri yayımlanır: [Sürümler](https://gitlab.com/freeware2/maccalendar/-/releases).

#### Kaynak Koddan Derleme:
```bash
./build_app.sh          # MacCalendar.app
./build_app.sh --zip    # ayrıca build/release/MacCalendar-<sürüm>.zip ve SHA-256
```

### 📄 Lisans & Depo

- **Geliştirici:** Rafet Sapancı
- **GitLab Deposu:** [gitlab.com/freeware2/maccalendar](https://gitlab.com/freeware2/maccalendar)
- **Teknolojiler:** Native Swift, AppKit & SwiftUI (macOS 13+)
- **Lisans:** GNU GPL sürüm 3 ya da sonrası ([LICENSE](LICENSE))

---

<a name="english"></a>
## 🇬🇧 English Description

**MacCalendar** is a lightweight, elegant native macOS menu bar application designed to provide a modern floating calendar flyout and simultaneously display **dual world clocks** with country flag badges (e.g., `🇹🇷 20:04   🇯🇵 02:04`) right in your menu bar.

Built natively using **Swift**, **AppKit**, and **SwiftUI**, it offers top-tier performance, minimal resource usage, and a seamless macOS experience.

---

### ✨ Key Features

#### 1. Menu Bar Display
- **Dynamic Calendar Day Badge:** Displays a customized mini calendar icon showing today's day number in the menu bar.
- **Customizable Date & Clock Formats:** Choose your preferred date style (`29 Oct Thu`, `29.10.2026`, `29 October`, or Time Only), optional seconds display, and flag badges.
- **Dual Clock Mode (Toggleable):**
  - Switch between local time only (`🇹🇷 20:04`) and dual world clock mode (`🇹🇷 20:04   🇯🇵 02:04`) with a single click.
  - 5 customizable flag layout styles (flags preceding time, flags trailing time, flags in the middle, second flag only, or flag with city code).

#### 2. Floating Calendar Flyout
- **Header Card:**
  - Local country flag automatically resolved from your system time zone/region, large live digital clock with seconds, and full localized date string.
  - Dedicated secondary clock card showing the target country flag, city name, time difference badge (e.g., `+6 hrs`), and live secondary time.
- **Monthly Calendar Grid:**
  - Distinct weekend coloring for Saturday and Sunday.
  - Leading and trailing out-of-month days, highlighted current day badge, and day selection indicator.
  - **"Today" Quick Jump:** Instantly returns to the current day from any month or year.
  - Interactive Month/Year Picker: Click on the header to easily navigate across different years and months.
  - Configurable week start day (Monday or Sunday).

#### 3. Daily Quick Notes & Reminders
- Click on any calendar day to attach quick notes or reminders.
- Days with notes are visually marked with an indicator dot on the calendar grid.
- Easily review and delete notes per date.

#### 4. 400+ World Cities & Time Zones Search
- Pre-configured presets for major global hubs (Tokyo, London, New York, Berlin, Paris, Seoul, Dubai, Singapore, Los Angeles, Beijing, Sydney, Baku, etc.).
- Integrated **search across 400+ world cities** to find and track any global time zone instantly.
- Optional custom label field (e.g., `TYO`, `Office`, `HQ`).

#### 5. Live & Reactive Multi-Language Support
- Switch seamlessly between **English**, **Türkçe**, or **System Language** directly from the Preferences panel.
- No application restart required: all UI labels, menu bar formats, weekday headers, and months update immediately upon selection.

#### 6. Launch Automatically at Login & Safe Quit
- **Auto Launch:** Native macOS `ServiceManagement` (`SMAppService`) integration allowing MacCalendar to start automatically whenever your Mac boots up.
- **Accidental Quit Protection:** Prompt an inline confirmation dialog when clicking the power button to prevent accidental termination.

---

<a name="installation"></a>
### 🚀 Installation

Requires macOS 13 or later. Runs on Apple Silicon and Intel Macs (universal).

1. Download **[MacCalendar.zip](https://gitlab.com/freeware2/maccalendar/-/releases/permalink/latest/downloads/MacCalendar.zip)** and open it.
2. Drag `MacCalendar.app` to **Applications**. The `LICENSE.txt` next to it is the license text.
3. Open MacCalendar; its icon appears in the menu bar (not in the Dock).

> [!warning] The first time you open MacCalendar, macOS blocks it. This is expected.
> MacCalendar is free and not notarized by Apple, so the first time you open it macOS says it *could not verify* the app and does not open it. You only need to allow it once:
>
> 1. In the warning, click **Done**. Do **not** click *Move to Trash*.
> 2. Open **System Settings ▸ Privacy & Security** and scroll down to **Security**.
> 3. On the line saying MacCalendar was blocked, click **Open Anyway** and confirm with your password or Touch ID.
>
> Prefer Terminal? Run `xattr -dr com.apple.quarantine /Applications/MacCalendar.app`, then open MacCalendar.

Every release lists a SHA-256 checksum: [Releases](https://gitlab.com/freeware2/maccalendar/-/releases).

#### Compile from Source:
```bash
./build_app.sh          # MacCalendar.app
./build_app.sh --zip    # also build/release/MacCalendar-<version>.zip and its SHA-256
```

---

### 📄 License & Repository

- **Developer:** Rafet Sapancı
- **GitLab Repository:** [gitlab.com/freeware2/maccalendar](https://gitlab.com/freeware2/maccalendar)
- **Tech Stack:** Native Swift, AppKit & SwiftUI (macOS 13+)
- **License:** GNU GPL version 3 or later ([LICENSE](LICENSE))
