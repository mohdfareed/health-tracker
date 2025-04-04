import Foundation
import OSLog
import SwiftData

// MARK: Settings

/// A protocol to define the raw value stored in the `UserDefaults` database.
/// It mirrors the `AppStorage` interface and **must not be implemented**.
/// It must only implement the types supported by the `AppStorage` interface.
internal protocol SettingsRawValue: Sendable {}

/// A key for a settings value stored in the `UserDefaults` database.
struct Settings<Value: Sendable>: Sendable {
    /// The unique key for the value in `UserDefaults`.
    let id: String
    /// The default value for the setting.
    let defaultValue: Value?
}

// MARK: Data Store

/// The supported sources of data.
typealias DataSource = String

/// A protocol for data models that originate from a data source.
protocol DataResource: PersistentModel {
    /// The source of the data.
    var source: DataSource { get }
}

/// An application store that is the source of data.
protocol ResourceStore<SupportedModel> {
    /// The type of models the store supports.
    associatedtype SupportedModel: DataResource
    /// The source of the store's data.
    static var source: DataSource { get }

    /// Fetches records matching a predicate.
    func fetch<M>(_ descriptor: FetchDescriptor<M>) throws -> [M]
    where M == SupportedModel
    /// Creates or updates a record in the store.
    func save(_ model: SupportedModel) throws
    /// Deletes a record from the store.
    func delete(_ model: SupportedModel) throws
}

// MARK: Plotting

/// A data point made up of 2 data values. Allows 2D operations.
protocol DataPoint<X, Y> {
    associatedtype X
    associatedtype Y
    var x: X { get }
    var y: Y { get }
}

/// A data point default implementation.
struct GenericPoint<X, Y>: DataPoint {
    var x: X
    var y: Y
}
