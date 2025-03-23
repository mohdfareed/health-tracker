import Foundation

typealias Advancer<T: Strideable> = (T, T.Stride) -> T

// MARK: Statistics

extension Collection where Element: Numeric {
    /// The sum of all data points.
    func sum() -> Element {
        self.reduce(Element.zero, +)
    }
}

extension Collection where Element: DataValue & Numeric & DurationProtocol {
    /// The average of all data points.
    func average() -> Double? {
        guard !self.isEmpty else {
            return nil
        }

        let sum = self.sum()
        let count = self.count
        return self.sum() / Element(exactly: self.count)!
    }
}

// MARK: Plotting

extension DataEntry {
    /// Convert the entry to a data point.
    var dataPoint: any DataPoint<Date, T> {
        return ValuePoint(x: self.date, y: self.value)
    }
}

extension Collection where Element: DataEntry {
    /// The data points of the entries.
    var dataPoints: any Collection<any DataPoint<Date, Element.T>> {
        return self.map({ $0.dataPoint })
    }
}

extension Collection where Element: DataPoint {
    /// The x-axis data points.
    var xAxis: any Collection<Element.X> { self.map { $0.x } }
    /// The y-axis data points.
    var yAxis: any Collection<Element.Y> { self.map { $0.y } }
}

// MARK: Data Binning

extension Collection where Element: DataPoint {
    /// Bin the data points into the range.
    func bin(
        _ count: Element.X.Stride,
        using advance: Advancer<Element.X> = { $0.advanced(by: $1) }
    ) -> [(Range<Element.X>, values: [Element.Y])]
    where Element.X.Stride: BinaryFloatingPoint {
        guard
            let minValue = self.xAxis.min(),
            let maxValue = self.xAxis.max()
        else {
            return []
        }

        let step = minValue.distance(to: maxValue) / count
        return self.bin(step: step, using: advance)
    }

    /// Bin the data points into the range.
    func bin(
        step: Element.X.Stride, anchor: Element.X? = nil,
        using advance: Advancer<Element.X> = { $0.advanced(by: $1) }
    ) -> [(Range<Element.X>, values: [Element.Y])] {
        guard
            let minValue = self.xAxis.min(),
            let maxValue = self.xAxis.max()
        else {
            return []
        }

        let inTimeRange = {
            if step > 0 {
                return $0 > minValue
            } else {
                return $0 < maxValue
            }
        }

        // Fix the start to be before the min value
        var start = anchor ?? minValue
        while inTimeRange(start) {
            start = advance(start, -step)
        }

        // Generate the bins
        let bins = (start...maxValue).generateBins(step: step, using: advance)
        var binnedData = bins.map { (range: $0, values: [Element.Y]()) }

        // Split the data into the bins
        for point in self {
            if let index = bins.firstIndex(where: { $0.contains(point.x) }) {
                binnedData[index].values.append(point.y)
            }
        }
        return binnedData
    }
}

extension ClosedRange where Bound: DataValue {
    /// Generate data bins out of a range with a given step.
    func generateBins(
        step: Bound.Stride, using advance: Advancer<Bound>
    ) -> [Range<Bound>] {
        var bins: [Range<Bound>] = []
        var current = self.lowerBound
        while current < self.upperBound {
            let next = advance(current, step)
            bins.append(current..<next)
            current = next
        }
        return bins
    }
}
