import Foundation

typealias DateBinFunc = (Date) -> DateInterval

extension [DataEntry] {
    /// The data points.
    var dates: [Date] { self.map { $0.date } }
    /// The entries date data points.
    var values: [Double] { self.map { $0.value } }

    /// Create a data series binned by a time interval.
    func binnedDataSeries(using func: DateBinFunc) -> [DateInterval: [Double]] {
        let bins = Dictionary(grouping: self, by: { `func`($0.date) })
        return bins.mapValues { $0.map { $0.value } }
    }

    /// Create a date series binned by a time interval.
    func dateSeries(using func: DateBinFunc) -> [DateInterval: Double] {
        let binnedData = binnedDataSeries(using: `func`)
        return binnedData.mapValues { $0.reduce(0, +) }
    }
}

extension [Double] {
    /// The sum of all data points.
    func sum() -> Double {
        return self.reduce(0, +)
    }

    /// The average of all data points.
    func average() -> Double? {
        guard !self.isEmpty else {
            return nil
        }
        return Double(self.sum()) / Double(self.count)
    }
}

extension [Date] {
    /// The time interval between the first and last dates.
    func interval() -> DateInterval? {
        let dates = self.sorted()
        guard let start = dates.first, let end = dates.last else {
            return nil
        }
        return DateInterval(start: start, end: end)
    }
}

extension Date {
    /// The number of days between two dates.
    func days(to date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }

    /// The date added by a number of days.
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    // MARK: Time Intervals

    /// A time interval of a number of minutes, starting from the beginning of this minute.
    func minutesInterval(of minutes: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let minute = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)

        let start = calendar.date(from: minute)!
        let end = calendar.date(byAdding: .minute, value: Int(minutes), to: start)!
        return DateInterval(start: start, end: end)
    }

    /// A time interval of a number of hours, starting from the beginning of this hour.
    func hoursInterval(of hours: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let hour = calendar.dateComponents([.year, .month, .day, .hour], from: self)

        let start = calendar.date(from: hour)!
        let end = calendar.date(byAdding: .hour, value: Int(hours), to: start)!
        return DateInterval(start: start, end: end)
    }

    /// A time interval of a number of days, starting from the beginning of this day.
    func daysInterval(of days: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let end = calendar.date(byAdding: .day, value: Int(days), to: start)!
        return DateInterval(start: start, end: end)
    }

    /// A time interval of a number of weeks, starting from the beginning of this week.
    func weeksInterval(starting startOfWeek: Weekday, of weeks: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)

        let elapsedDays = (weekday - startOfWeek.rawValue + 7) % 7
        let start = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: -elapsedDays, to: self)!
        )

        let end = calendar.date(byAdding: .day, value: 7 * Int(weeks), to: start)!
        return DateInterval(start: start, end: end)
    }

    /// A time interval of a number of months, starting from the beginning of this month.
    func monthsInterval(of months: UInt = 1) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        )!

        let end = calendar.date(byAdding: .month, value: Int(months), to: start)!
        return DateInterval(start: start, end: end)
    }
}
