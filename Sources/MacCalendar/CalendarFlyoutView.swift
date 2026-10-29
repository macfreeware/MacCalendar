import SwiftUI
import AppKit

private struct FlyoutHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

public struct CalendarFlyoutView: View {
    @ObservedObject var settings: AppSettings
    var onHeightChange: ((CGFloat) -> Void)?

    @State private var now: Date = Date()
    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var isPickingMonthYear: Bool = false
    @State private var showSettingsPanel: Bool = false
    @State private var showAboutPanel: Bool = false
    @State private var showQuitConfirmation: Bool = false
    @State private var canConfirmQuit: Bool = false
    @State private var showCustomCitySearch: Bool = false
    @State private var citySearchQuery: String = ""
    @State private var newNoteText: String = ""

    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    // Cumartesi ve Pazar için belirgin hafta sonu rengi (Mercan Kırmızısı / Turuncu-Kırmızı)
    private let weekendColor = Color(red: 0.93, green: 0.30, blue: 0.28)

    public init(
        settings: AppSettings,
        showSettingsInitially: Bool = false,
        showAboutInitially: Bool = false,
        showQuitInitially: Bool = false,
        onHeightChange: ((CGFloat) -> Void)? = nil
    ) {
        self.settings = settings
        self._showSettingsPanel = State(initialValue: showSettingsInitially)
        self._showAboutPanel = State(initialValue: showAboutInitially)
        self._showQuitConfirmation = State(initialValue: showQuitInitially)
        self._canConfirmQuit = State(initialValue: showQuitInitially)
        self.onHeightChange = onHeightChange
    }

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = settings.effectiveLocale
        cal.firstWeekday = settings.startWeekOnMonday ? 2 : 1
        return cal
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 1. ÜST BÖLÜM: Saat & Tarih Başlığı + İkinci Saat Kartı
            headerClockSection
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .opacity(0.5)

            // 2. ORTA BÖLÜM: Aylık Takvim Izgarası veya Aylar/Yıllar Seçici
            VStack(spacing: 8) {
                calendarNavigationHeader

                if isPickingMonthYear {
                    monthYearPickerGrid
                } else {
                    weekdayHeaderRow
                    daysGridView
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .fixedSize(horizontal: false, vertical: true)

            Divider()
                .opacity(0.5)

            // 3. SEÇİLİ GÜN NOT / HATIRLATICI BÖLÜMÜ
            selectedDayAgendaSection
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .fixedSize(horizontal: false, vertical: true)

            Divider()
                .opacity(0.5)

            // 4. LİSTEDE OLMAYAN ŞEHİR ARAMA PANELİ (Açık olduğunda)
            if showCustomCitySearch {
                customCitySearchSection
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                Divider()
                    .opacity(0.5)
            }

            // 5. AYARLAR PANELİ (Açık olduğunda)
            if showSettingsPanel {
                settingsSection
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
                Divider()
                    .opacity(0.5)
            }

            // 6. HAKKINDA PANELİ (Açık olduğunda)
            if showAboutPanel {
                aboutSection
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
                Divider()
                    .opacity(0.5)
            }

            // 7. ALT HIZLI KONTROL ÇUBUĞU
            bottomQuickBar
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.4))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 350)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: FlyoutHeightPreferenceKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(FlyoutHeightPreferenceKey.self) { newHeight in
            if newHeight > 100 {
                onHeightChange?(ceil(newHeight))
            }
        }
        .background(VisualEffectBlur())
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.14), lineWidth: 1)
        )
        .onReceive(timer) { current in
            self.now = current
        }
        .onReceive(NotificationCenter.default.publisher(for: .flyoutDidClose)) { _ in
            showSettingsPanel = false
            showAboutPanel = false
            showQuitConfirmation = false
            canConfirmQuit = false
            showCustomCitySearch = false
            isPickingMonthYear = false
            citySearchQuery = ""
        }
    }

    // MARK: - 1. Header Clock Section
    private var headerClockSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack(alignment: .top) {
                // Eğer bugün dışındaysak sol tarafta hızlı "Bugün" butonu
                if !calendar.isDate(selectedDate, inSameDayAs: now) || !calendar.isDate(displayedMonth, equalTo: now, toGranularity: .month) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 11, weight: .semibold))
                        Text(settings.tr(.today))
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundColor(Color.accentColor)
                    .clipShape(Capsule())
                    .contentShape(Capsule())
                    .onTapGesture {
                        displayedMonth = now
                        selectedDate = now
                        isPickingMonthYear = false
                    }
                    .padding(.top, 4)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    // Büyük Yerel Saat + Otomatik Yerel Ülke Bayrağı (Sağa Yaslı)
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Text(settings.localFlag)
                            .font(.system(size: 28))
                            .baselineOffset(1)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(formattedLocalHourMinute(now))
                                .font(.system(size: 32, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.primary)

                            Text(formattedLocalSeconds(now))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.secondary)
                        }
                    }
                    .fixedSize()

                    // Tam Tarih (Sağa Yaslı - Tıklanınca bugüne odaklar)
                    Text(formattedFullDate(now))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.accentColor)
                        .multilineTextAlignment(.trailing)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            displayedMonth = now
                            selectedDate = now
                            isPickingMonthYear = false
                        }
                        .help(settings.tr(.clickToGoToToday))
                }
            }

            // İkinci Saat Kartı
            if settings.showSecondClock {
                secondClockCard
            }
        }
    }

    private var secondClockCard: some View {
        let tz = settings.secondTimeZone
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(settings.secondClockFlag)
                        .font(.system(size: 18))

                    Text(settings.secondClockCityOnlyName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(timeDifferenceBadge(for: tz))
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1.5)
                        .background(Color.secondary.opacity(0.16))
                        .foregroundColor(.secondary)
                        .clipShape(Capsule())
                }

                Text(formattedSecondaryDate(now, timeZone: tz))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(formattedTime(now, timeZone: tz, includeSeconds: false))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary)

                Text(":" + formattedSeconds(now, timeZone: tz))
                    .font(.system(size: 11.5, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: - 2. Calendar Navigation & Grid
    private var calendarNavigationHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Text(monthYearTitle(for: displayedMonth))
                    .font(.system(size: 14.5, weight: .semibold))
                    .foregroundColor(.primary)

                Image(systemName: isPickingMonthYear ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
            .onTapGesture {
                isPickingMonthYear.toggle()
            }
            .help(settings.tr(.clickToSelectMonthYear))

            Spacer()

            HStack(spacing: 4) {
                Button {
                    if isPickingMonthYear {
                        changeYear(by: -1)
                    } else {
                        changeMonth(by: -1)
                    }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 28, height: 26)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
                .help(isPickingMonthYear ? settings.tr(.previousYear) : settings.tr(.previousMonth))

                Button {
                    if isPickingMonthYear {
                        changeYear(by: 1)
                    } else {
                        changeMonth(by: 1)
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 28, height: 26)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
                .help(isPickingMonthYear ? settings.tr(.nextYear) : settings.tr(.nextMonth))
            }
        }
    }

    private var weekdayHeaderRow: some View {
        let headers = L10n.weekdayHeaders(startMonday: settings.startWeekOnMonday, lang: settings.appLanguage)
        return HStack(spacing: 4) {
            ForEach(headers.indices, id: \.self) { idx in
                let item = headers[idx]
                Text(item.title)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(item.isWeekend ? weekendColor : .secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 2)
    }

    private var daysGridView: some View {
        let days = generateCalendarDays(for: displayedMonth)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 3) {
            ForEach(days) { item in
                dayCell(for: item)
            }
        }
    }

    private func dayCell(for item: CalendarDayItem) -> some View {
        let isToday = calendar.isDate(item.date, inSameDayAs: now)
        let isSelected = calendar.isDate(item.date, inSameDayAs: selectedDate)
        let hasNotes = !settings.notes(for: item.date).isEmpty
        let weekday = calendar.component(.weekday, from: item.date)
        let isWeekend = (weekday == 1 || weekday == 7) // Pazar = 1, Cumartesi = 7

        let dayTextColor: Color = {
            if isToday {
                return .white
            }
            if isWeekend {
                return item.isCurrentMonth ? weekendColor : weekendColor.opacity(0.45)
            }
            return item.isCurrentMonth ? .primary : Color.secondary.opacity(0.45)
        }()

        return Button {
            selectedDate = item.date
            if !item.isCurrentMonth {
                displayedMonth = item.date
            }
        } label: {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 32, height: 32)
                } else if isSelected {
                    Circle()
                        .strokeBorder(isWeekend ? weekendColor : Color.accentColor, lineWidth: 1.8)
                        .background(Circle().fill((isWeekend ? weekendColor : Color.accentColor).opacity(0.12)))
                        .frame(width: 32, height: 32)
                } else if isWeekend && item.isCurrentMonth {
                    Circle()
                        .fill(weekendColor.opacity(0.07))
                        .frame(width: 32, height: 32)
                }

                VStack(spacing: 1) {
                    Text("\(item.dayNumber)")
                        .font(.system(size: 13, weight: (isToday || isSelected || (isWeekend && item.isCurrentMonth)) ? .semibold : .regular))
                        .foregroundColor(dayTextColor)

                    if hasNotes {
                        Circle()
                            .fill(isToday ? Color.white : (isWeekend ? weekendColor : Color.accentColor))
                            .frame(width: 4, height: 4)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(height: 34)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var monthYearPickerGrid: some View {
        let months = L10n.shortMonths(for: settings.appLanguage)
        let currentMonthIndex = calendar.component(.month, from: displayedMonth) - 1
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<12, id: \.self) { idx in
                let isSelectedMonth = (idx == currentMonthIndex)
                Button {
                    var comps = calendar.dateComponents([.year, .month, .day], from: displayedMonth)
                    comps.month = idx + 1
                    comps.day = 1
                    if let newDate = calendar.date(from: comps) {
                        displayedMonth = newDate
                    }
                    isPickingMonthYear = false
                } label: {
                    Text(months[idx])
                        .font(.system(size: 13, weight: isSelectedMonth ? .semibold : .regular))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isSelectedMonth ? Color.accentColor : Color.primary.opacity(0.05))
                        )
                        .foregroundColor(isSelectedMonth ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - 3. Selected Day Quick Notes / Agenda
    private var selectedDayAgendaSection: some View {
        let notes = settings.notes(for: selectedDate)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(formattedSelectedDayHeader(selectedDate))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)

                Spacer()

                if !notes.isEmpty {
                    Text(settings.tr(.notesCount(notes.count)))
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            if !notes.isEmpty {
                VStack(spacing: 4) {
                    ForEach(Array(notes.enumerated()), id: \.offset) { idx, note in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 6, height: 6)

                            Text(note)
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                                .lineLimit(2)

                            Spacer()

                            Button {
                                settings.removeNote(at: idx, for: selectedDate)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primary.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }
            }

            HStack(spacing: 6) {
                TextField(settings.tr(.addNotePlaceholder), text: $newNoteText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .onSubmit {
                        addCurrentNote()
                    }

                Button {
                    addCurrentNote()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary.opacity(0.4) : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func addCurrentNote() {
        let text = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        settings.addNote(text, for: selectedDate)
        newNoteText = ""
    }

    // MARK: - 4. Listede Olmayan Şehir / Saat Dilimi Arama Bölümü
    private var filteredWorldCities: [WorldCityPreset] {
        let q = citySearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            return Array(AppSettings.allSystemTimeZones.prefix(25))
        }
        return Array(
            AppSettings.allSystemTimeZones.filter {
                $0.name.lowercased().contains(q) ||
                $0.timeZoneID.lowercased().contains(q) ||
                $0.shortCode.lowercased().contains(q)
            }.prefix(30)
        )
    }

    private var customCitySearchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(settings.tr(.searchWorldCityTitle), systemImage: "magnifyingglass")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Button {
                    showCustomCitySearch = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            TextField(settings.tr(.searchCityPlaceholder), text: $citySearchQuery)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11.5))

            ScrollView {
                VStack(spacing: 3) {
                    ForEach(filteredWorldCities) { item in
                        let isSelected = (settings.secondClockTimeZoneID == item.timeZoneID)
                        Button {
                            settings.secondClockTimeZoneID = item.timeZoneID
                            settings.showSecondClock = true
                            showCustomCitySearch = false
                        } label: {
                            HStack {
                                Text("\(item.flag) \(item.name)")
                                    .font(.system(size: 11.5, weight: isSelected ? .semibold : .regular))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Spacer()
                                Text(item.shortCode)
                                    .font(.system(size: 10.5, weight: .medium))
                                    .foregroundColor(.secondary)
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 11.5))
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.primary.opacity(0.03))
                            )
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: 125)
        }
    }

    // MARK: - 5. Settings Panel
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(settings.tr(.settingsTitle), systemImage: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
            }

            // İkinci saat ayarı
            Toggle(settings.tr(.showSecondClock), isOn: $settings.showSecondClock)
                .font(.system(size: 12))
                .toggleStyle(.switch)
                .controlSize(.small)

            if settings.showSecondClock {
                HStack {
                    Text(settings.tr(.secondClockCity))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("", selection: $settings.secondClockTimeZoneID) {
                        ForEach(settings.activePresetsWithSelection) { preset in
                            Text("\(preset.flag) \(preset.name) (\(preset.shortCode))")
                                .tag(preset.timeZoneID)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 190)
                }

                HStack {
                    Text(settings.tr(.notInList))
                        .font(.system(size: 11.5))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button {
                        showCustomCitySearch.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 10.5, weight: .semibold))
                            Text(showCustomCitySearch ? settings.tr(.closeSearch) : settings.tr(.searchAllCities))
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.14))
                        .foregroundColor(.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    Text(settings.tr(.customLabel))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField(settings.tr(.customLabelPlaceholder), text: $settings.secondClockCustomLabel)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                        .frame(width: 145)
                }
            }

            Divider()

            // Dil Seçimi (Language)
            HStack {
                Text(settings.tr(.appLanguage))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
                Picker("", selection: $settings.appLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .labelsHidden()
                .frame(width: 210)
            }

            HStack {
                Text(settings.tr(.flagStyle))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
                Picker("", selection: $settings.menuBarClockBadgeStyle) {
                    ForEach(MenuBarClockBadgeStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .labelsHidden()
                .frame(width: 210)
            }

            HStack {
                Text(settings.tr(.dateFormat))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
                Picker("", selection: $settings.menuBarDateFormat) {
                    ForEach(MenuBarDateFormat.allCases) { fmt in
                        Text(fmt.title(lang: settings.appLanguage)).tag(fmt)
                    }
                }
                .labelsHidden()
                .frame(width: 210)
            }

            HStack {
                Toggle(settings.tr(.secondsInMenuBar), isOn: $settings.showSecondsInMenuBar)
                    .font(.system(size: 12))
                    .toggleStyle(.checkbox)

                Spacer()

                Toggle(settings.tr(.startMonday), isOn: $settings.startWeekOnMonday)
                    .font(.system(size: 12))
                    .toggleStyle(.checkbox)
            }

            Toggle(settings.tr(.launchAtLogin), isOn: $settings.launchAtLogin)
                .font(.system(size: 12))
                .toggleStyle(.checkbox)
        }
    }

    // MARK: - 6. Hakkında (About) Bölümü
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                // Uygulama Simgesi
                if let appIcon = NSImage(named: NSImage.applicationIconName) {
                    Image(nsImage: appIcon)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(settings.tr(.aboutTitle))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("v1.1.0")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.18))
                            .foregroundColor(Color.accentColor)
                            .clipShape(Capsule())
                    }

                    Text(settings.tr(.aboutSubtitle))
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.secondary)

                    Text(settings.tr(.developer))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.9))
                }

                Spacer()
            }

            Text(settings.tr(.aboutDescription))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Link(destination: URL(string: "https://gitlab.com/freeware2/maccalendar")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 10.5))
                        Text(settings.tr(.gitlabRepo))
                            .font(.system(size: 10.5, weight: .medium))
                    }
                    .foregroundColor(.accentColor)
                }

                Spacer()

                Text(settings.tr(.copyright))
                    .font(.system(size: 10.5))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func triggerQuitConfirmation() {
        canConfirmQuit = false
        withAnimation(.easeInOut(duration: 0.15)) {
            showQuitConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.15)) {
                canConfirmQuit = true
            }
        }
    }

    // MARK: - 7. Bottom Quick Bar (Ayarlar ve sağında Hakkında butonu)
    private var bottomQuickBar: some View {
        Group {
            if showQuitConfirmation {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 13))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(settings.tr(.quitConfirmTitle))
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(.primary)
                        Text(settings.tr(.quitConfirmMessage))
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 4)

                    // 1. Çıkışı Onayla Butonu (İmleçten uzakta, solda ve ilk 0.6 sn kilitli)
                    Button {
                        guard canConfirmQuit else { return }
                        NSApplication.shared.terminate(nil)
                    } label: {
                        Text(settings.tr(.quitAction))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(canConfirmQuit ? Color.red : Color.red.opacity(0.45))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canConfirmQuit)

                    // 2. Vazgeç Butonu (EN SAĞDA: Güç butonuna basan imlecin tam altında!)
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showQuitConfirmation = false
                            canConfirmQuit = false
                        }
                    } label: {
                        Text(settings.tr(.cancel))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.primary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.red.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.red.opacity(0.25), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                HStack(spacing: 6) {
                    // Hızlı 2. Saat Aç/Kapat Butonu (Bayraklı)
                    Button {
                        settings.showSecondClock.toggle()
                    } label: {
                        HStack(spacing: 5) {
                            Text(settings.showSecondClock ? settings.secondClockFlag : settings.localFlag)
                                .font(.system(size: 16))

                            Text(settings.showSecondClock ? settings.secondClockShortLabel : settings.tr(.localTime))
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .fixedSize()
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(settings.showSecondClock ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.05))
                        )
                    }
                    .buttonStyle(.plain)
                    .help(settings.showSecondClock ? settings.tr(.onlyLocal) : settings.tr(.secondClock("")))

                    // Hızlı Şehir Seçici (2. saat açıkken)
                    if settings.showSecondClock {
                        Menu {
                            ForEach(settings.activePresetsWithSelection) { preset in
                                Button {
                                    settings.secondClockTimeZoneID = preset.timeZoneID
                                } label: {
                                    HStack {
                                        Text("\(preset.flag) \(preset.name) (\(preset.shortCode))")
                                        if settings.secondClockTimeZoneID == preset.timeZoneID {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }

                            Divider()

                            Button {
                                showCustomCitySearch = true
                            } label: {
                                Label(settings.tr(.otherCitySearchAction), systemImage: "magnifyingglass")
                            }
                        } label: {
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                                .padding(5)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                        .menuStyle(.borderlessButton)
                        .fixedSize()
                        .help(settings.tr(.otherCitySearchAction))
                    }

                    Spacer(minLength: 2)

                    // Ayarlar Butonu
                    Button {
                        if !showSettingsPanel {
                            showAboutPanel = false
                        }
                        showSettingsPanel.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 11))
                            Text(settings.tr(.settings))
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                        }
                        .fixedSize()
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(showSettingsPanel ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.05))
                        .foregroundColor(showSettingsPanel ? .accentColor : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(settings.tr(.settingsTitle))

                    // Hakkında Butonu (Ayarlar'ın hemen sağında)
                    Button {
                        if !showAboutPanel {
                            showSettingsPanel = false
                        }
                        showAboutPanel.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 11))
                            Text(settings.tr(.about))
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                        }
                        .fixedSize()
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(showAboutPanel ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.05))
                        .foregroundColor(showAboutPanel ? .accentColor : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .help(settings.tr(.about))

                    // Çıkış Butonu (Onay İster)
                    Button {
                        triggerQuitConfirmation()
                    } label: {
                        Image(systemName: "power")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(5)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .fixedSize()
                    .help(settings.tr(.quit))
                }
            }
        }
    }

    // MARK: - Formatting & Calendar Calculation Helpers
    private func formattedLocalHourMinute(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = settings.effectiveLocale
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func formattedLocalSeconds(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = settings.effectiveLocale
        f.dateFormat = ":ss"
        return f.string(from: date)
    }

    private func formattedFullDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = settings.effectiveLocale
        f.dateFormat = "d MMMM yyyy EEEE"
        return f.string(from: date)
    }

    private func formattedSelectedDayHeader(_ date: Date) -> String {
        if calendar.isDate(date, inSameDayAs: now) {
            let f = DateFormatter()
            f.locale = settings.effectiveLocale
            f.dateFormat = "d MMMM EEEE"
            return settings.tr(.todayWithDash) + f.string(from: date)
        }
        let f = DateFormatter()
        f.locale = settings.effectiveLocale
        f.dateFormat = "d MMMM yyyy EEEE"
        return f.string(from: date)
    }

    private func formattedTime(_ date: Date, timeZone: TimeZone, includeSeconds: Bool) -> String {
        let f = DateFormatter()
        f.locale = settings.effectiveLocale
        f.timeZone = timeZone
        f.dateFormat = includeSeconds ? "HH:mm:ss" : "HH:mm"
        return f.string(from: date)
    }

    private func formattedSeconds(_ date: Date, timeZone: TimeZone) -> String {
        let f = DateFormatter()
        f.locale = settings.effectiveLocale
        f.timeZone = timeZone
        f.dateFormat = "ss"
        return f.string(from: date)
    }

    private func formattedSecondaryDate(_ date: Date, timeZone: TimeZone) -> String {
        let f = DateFormatter()
        f.locale = settings.effectiveLocale
        f.timeZone = timeZone
        f.dateFormat = "d MMMM EEEE"
        return f.string(from: date)
    }

    private func timeDifferenceBadge(for targetTZ: TimeZone) -> String {
        let localOffset = TimeZone.current.secondsFromGMT(for: now)
        let targetOffset = targetTZ.secondsFromGMT(for: now)
        let diffSeconds = targetOffset - localOffset
        let diffHours = Double(diffSeconds) / 3600.0

        if diffSeconds == 0 {
            return settings.tr(.sameTime)
        }
        if diffHours == floor(diffHours) {
            let h = Int(diffHours)
            let formatted = h > 0 ? "+\(h)" : "\(h)"
            return settings.tr(.hoursDiff(formatted))
        } else {
            let formatted = String(format: "%+.1f", diffHours)
            return settings.tr(.hoursDiff(formatted))
        }
    }

    private func monthYearTitle(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = settings.effectiveLocale
        f.dateFormat = isPickingMonthYear ? "yyyy" : "MMMM yyyy"
        return f.string(from: date).capitalized(with: settings.effectiveLocale)
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func changeYear(by value: Int) {
        if let newYear = calendar.date(byAdding: .year, value: value, to: displayedMonth) {
            displayedMonth = newYear
        }
    }

    private func generateCalendarDays(for monthDate: Date) -> [CalendarDayItem] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
            return []
        }
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7

        guard let startDay = calendar.date(byAdding: .day, value: -offset, to: firstOfMonth) else {
            return []
        }

        var items: [CalendarDayItem] = []
        items.reserveCapacity(42)

        for i in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDay) {
                let isCurrent = calendar.isDate(date, equalTo: monthDate, toGranularity: .month)
                let dayNum = calendar.component(.day, from: date)
                items.append(CalendarDayItem(id: i, date: date, dayNumber: dayNum, isCurrentMonth: isCurrent))
            }
        }
        return items
    }
}

public struct CalendarDayItem: Identifiable {
    public let id: Int
    public let date: Date
    public let dayNumber: Int
    public let isCurrentMonth: Bool
}

public struct VisualEffectBlur: NSViewRepresentable {
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
