import Foundation
import HealthKit
import SwiftData

final class HealthKitStore: DataStore {
    typealias Configuration = HealthKitStoreConfiguration
    typealias Snapshot = DefaultSnapshot

    var configuration: HealthKitStoreConfiguration
    var identifier: String = UUID().uuidString
    var schema: Schema

    private var logger = AppLogger(for: HealthKitStore.self)
    private var healthStore = HKHealthStore()

    init(
        _ configuration: HealthKitStoreConfiguration, migrationPlan: (any SchemaMigrationPlan.Type)?
    ) throws {
        self.configuration = configuration
        self.schema = configuration.schema ?? Schema([])
    }

    func fetch<T>(_ request: DataStoreFetchRequest<T>) throws
        -> DataStoreFetchResult<T, DefaultSnapshot> where T: PersistentModel
    {
        guard let T = T.self as? any HealthKitModel.Type else {
            throw HealthKitError.invalidModelType(
                "Model type '\(T.self)' does not conform to \((any HealthKitModel).self)"
            )
        }

        guard request.descriptor.fetchOffset == nil,
            request.descriptor.includePendingChanges,
            request.descriptor.relationshipKeyPathsForPrefetching.isEmpty
        else {
            throw HealthKitError.unsupportedQuery(
                "Unsupported query options: \(request.descriptor)"
            )
        }

        let predicate: Predicate<NSObject>? = request.descriptor.predicate
        let nsPredicate: NSPredicate? = predicate != nil ? NSPredicate(predicate!) : nil

        let healthStore = HKHealthStore()
        let query = T.HealthKitQueryType(
            sampleType: T.healthKitType,
            predicate: nsPredicate,
            limit: request.descriptor.fetchLimit,
            sortDescriptors: request.descriptor.sortBy
        ) { _, samples, error in
            if let error = error {
                request.completion(.failure(HealthKitError.queryError(error)))
                return
            }

            guard let samples = samples else {
                request.completion(
                    .failure(HealthKitError.invalidData("No samples returned.")))
                return
            }

            do {
                let models = try samples.map { try T.from(healthKitSample: $0) }
                request.completion(.success(models))
            } catch {
                request.completion(.failure(error))
            }
        }

        healthStore.execute(query)
    }

    func save(_ request: DataStoreSaveChangesRequest<DefaultSnapshot>) throws
        -> DataStoreSaveChangesResult<DefaultSnapshot>
    {

    }

}

final class HealthKitService {
    private var logger = AppLogger(for: HealthKitService.self)
    private var healthStore = HKHealthStore()

    func fetch<T>(_ request: FetchDescriptor<T>) throws
        -> DataStoreFetchResult<T, DefaultSnapshot> where T: HealthKitModel
    {
        guard let T = T.self as? any HealthKitModel.Type else {
            throw HealthKitError.invalidModelType(
                "Model type '\(T.self)' does not conform to \((any HealthKitModel).self)"
            )
        }

        guard request.descriptor.fetchOffset == nil,
            request.descriptor.includePendingChanges,
            request.descriptor.relationshipKeyPathsForPrefetching.isEmpty
        else {
            throw HealthKitError.unsupportedQuery(
                "Unsupported query options: \(request.descriptor)"
            )
        }

        let predicate: Predicate<NSObject>? = request.descriptor.predicate
        let nsPredicate: NSPredicate? = predicate != nil ? NSPredicate(predicate!) : nil

        let healthStore = HKHealthStore()
        let query = HKObserverQuery(
            sampleType: T.healthKitType,
            predicate: nsPredicate,
            limit: request.descriptor.fetchLimit,
            sortDescriptors: request.descriptor.sortBy
        ) { query, samples, error in

        }

        healthStore.execute(query)
    }

    func save(_ request: DataStoreSaveChangesRequest<DefaultSnapshot>) throws
        -> DataStoreSaveChangesResult<DefaultSnapshot>
    {

    }

}
