import Foundation

/// A generated budget report performed on a collection of data.
struct BudgetReport<T: DataValue> {
    /// The allocated budget amount.
    let budget: T
    /// The total amount of of the budget consumed.
    let consumed: T
    /// The remaining amount of the budget.
    var remaining: T
    /// The progress of the budget. It is a value between 0 and 1.
    var progress: Double

    init(_ budget: T, on entries: any Collection<T>)
        throws where T: BinaryFloatingPoint
    {
        guard budget.magnitude > T.zero.magnitude else {
            throw DataError.InvalidData("Budget must be greater than 0.")
        }
        self.budget = budget
        self.consumed = entries.sum()
        self.remaining = budget - consumed
        self.progress = Double(consumed / budget)
    }

    init(_ budget: T, on entries: [T]) throws where T: BinaryInteger {
        try self.init(budget, on: entries)
    }
}
