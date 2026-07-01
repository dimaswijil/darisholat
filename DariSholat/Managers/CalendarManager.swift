//
//  CalendarManager.swift
//  DariSholat
//
//  Manages Apple Calendar (EventKit) integration:
//  - Requests calendar access permission
//  - Fetches upcoming events (next 7 days)
//  - Auto-refreshes on EKEventStore changes
//

import Foundation
import EventKit
import Combine
import AppKit

// MARK: - Calendar Event Item

struct CalendarEventItem: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let calendarColor: NSColor
    let isAllDay: Bool

    /// Human-readable countdown from `now` to `startDate`.
    func countdownText(now: Date = Date(), lang: String = "en") -> String {
        let diff = startDate.timeIntervalSince(now)
        guard diff > 0 else {
            switch lang {
            case "ar": return "الآن"
            case "id": return "Sekarang"
            default:   return "Now"
            }
        }

        let totalSeconds = Int(diff)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60

        if days > 0 {
            switch lang {
            case "ar": return "\(days)ي \(hours)س"
            case "id": return "\(days)h \(hours)j"
            default:   return "\(days)d \(hours)h"
            }
        } else if hours > 0 {
            switch lang {
            case "ar": return "\(hours)س \(minutes)د"
            case "id": return "\(hours)j \(minutes)m"
            default:   return "\(hours)h \(minutes)m"
            }
        } else {
            switch lang {
            case "ar": return "\(minutes)د"
            case "id": return "\(minutes)m"
            default:   return "\(minutes)m"
            }
        }
    }

    /// Detailed date info for tooltip on hover
    func tooltipText(lang: String = "en") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lang == "id" ? "id_ID" : lang == "ar" ? "ar_SA" : "en_US")

        if isAllDay {
            formatter.dateFormat = "EEEE, d MMMM yyyy"
            return formatter.string(from: startDate)
        } else {
            formatter.dateFormat = "EEEE, d MMMM yyyy\nHH:mm"
            let start = formatter.string(from: startDate)

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            timeFormatter.locale = formatter.locale
            let end = timeFormatter.string(from: endDate)

            return "\(start) – \(end)"
        }
    }
}

// MARK: - Calendar Manager

class CalendarManager: ObservableObject {

    @Published var events: [CalendarEventItem] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var availableCalendars: [EKCalendar] = []
    @Published var selectedCalendarIdentifiers: Set<String> = []

    private let store = EKEventStore()
    private var storeChangedCancellable: AnyCancellable?

    init() {
        checkAuthorizationStatus()
        observeStoreChanges()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if isAuthorized {
            loadCalendars()
            loadSelectedCalendars()
            fetchEvents()
        }
    }

    func requestAccess() {
        if #available(macOS 14.0, *) {
            store.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.checkAuthorizationStatus()
                    if granted {
                        self?.loadCalendars()
                        self?.loadSelectedCalendars()
                        self?.fetchEvents()
                    }
                }
            }
        } else {
            store.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.checkAuthorizationStatus()
                    if granted {
                        self?.loadCalendars()
                        self?.loadSelectedCalendars()
                        self?.fetchEvents()
                    }
                }
            }
        }
    }

    var isAuthorized: Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(macOS 14.0, *) {
            return status == .fullAccess || status == .authorized
        }
        return status == .authorized
    }

    // MARK: - Calendar Filtering

    func loadCalendars() {
        let all = store.calendars(for: .event)
        DispatchQueue.main.async { [weak self] in
            self?.availableCalendars = all.sorted(by: { $0.title < $1.title })
        }
    }

    func loadSelectedCalendars() {
        if let saved = UserDefaults.standard.stringArray(forKey: "selectedCalendarIdentifiers") {
            selectedCalendarIdentifiers = Set(saved)
        } else {
            // Default to selecting all available calendars
            let all = store.calendars(for: .event)
            selectedCalendarIdentifiers = Set(all.map { $0.calendarIdentifier })
        }
    }

    func toggleCalendar(identifier: String) {
        if selectedCalendarIdentifiers.contains(identifier) {
            selectedCalendarIdentifiers.remove(identifier)
        } else {
            selectedCalendarIdentifiers.insert(identifier)
        }
        UserDefaults.standard.set(Array(selectedCalendarIdentifiers), forKey: "selectedCalendarIdentifiers")
        fetchEvents()
    }

    // MARK: - Fetch Events

    func fetchEvents() {
        guard isAuthorized else { return }

        let now = Date()
        let cal = Calendar.current
        guard let endDate = cal.date(byAdding: .year, value: 1, to: now) else { return }

        let predicate = store.predicateForEvents(withStart: now, end: endDate, calendars: nil)
        let ekEvents = store.events(matching: predicate)

        print("DEBUG Calendar: Total events found in next year = \(ekEvents.count)")
        
        let nonAllDay = ekEvents.filter { !$0.isAllDay }
        print("DEBUG Calendar: Non-all-day events = \(nonAllDay.count)")

        let mapped: [CalendarEventItem] = nonAllDay
            .sorted { $0.startDate < $1.startDate }
            .prefix(10) // Keep a reasonable buffer
            .map { event in
                CalendarEventItem(
                    id: event.eventIdentifier ?? UUID().uuidString,
                    title: event.title ?? "Untitled",
                    startDate: event.startDate,
                    endDate: event.endDate,
                    calendarColor: event.calendar.color ?? .systemBlue,
                    isAllDay: event.isAllDay
                )
            }

        DispatchQueue.main.async { [weak self] in
            self?.events = mapped
        }
    }

    // MARK: - Observe Store Changes

    private func observeStoreChanges() {
        storeChangedCancellable = NotificationCenter.default
            .publisher(for: .EKEventStoreChanged, object: store)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchEvents()
            }
    }
}

// MARK: - NSColor extraction for EKCalendar

extension EKCalendar {
    var color: NSColor? {
        guard let cgColor = self.cgColor else { return nil }
        return NSColor(cgColor: cgColor)
    }
}
