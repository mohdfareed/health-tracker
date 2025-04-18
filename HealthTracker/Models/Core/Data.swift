import SwiftData
import SwiftUI

enum DataError: Error {
    case InvalidData(String)
    case InvalidModel(String)
    case InvalidQuery(String, Error? = nil)
}

// MARK: Data Models
// ============================================================================

/// The supported sources of data.
enum DataSource: Codable, CaseIterable {
    case local, healthKit
    init() { self = .local }  // default
    #if DEBUG
        case simulation
    #endif
}

/// A protocol for data models that originate from a data source.
protocol DataRecord {
    /// The source of the data.
    var source: DataSource { get }
}

// MARK: Data Queries
// ============================================================================

/// A protocol for the query consumed by remote stores for remote data.
protocol RemoteQuery<Model> {
    /// The type of the data queried.
    associatedtype Model: DataRecord
}

/// A protocol for remote queries that can be performed on local data stores.
protocol CoreQuery: RemoteQuery where Model: PersistentModel {
    /// The local data store query descriptor.
    var descriptor: FetchDescriptor<Model> { get }
}

/// The in-memory filter to apply to data from remote sources.
struct InMemoryQuery<Model: DataRecord> {
    /// The data sources of the data. Query all sources if empty.
    var sources: [DataSource] = []
    /// The predicate to filter the data.
    var predicate: Predicate<Model>? = nil
    /// The sort order of the data.
    var sortOrder: [SortDescriptor<Model>] = []
    /// The limit of the data.
    var limit: Int? = nil
    /// The offset of the data.
    var offset: Int = 0
    /// The animation to apply to the data.
    var animation: Animation = .default
}

// MARK: Remote Data Stores
// ============================================================================

/// A protocol for remote data records stores.
/// The store queries a remote store for remote data and optional backups of
/// local data. A store is the provider of all non-local data it returns.
/// Remote stores **must** be used through the `RemoteContext`
protocol RemoteStore {
    /// Fetch the data from the store.
    /// The store must correctly assign the source to the data.
    func fetch<M, Q>(_ query: Q) throws -> [M] where Q: RemoteQuery<M>
    /// Add or update a local data backup in the store.
    func save(_ model: any DataRecord) throws
    /// Remove a local data backup from the store.
    func delete(_ model: any DataRecord) throws
}
