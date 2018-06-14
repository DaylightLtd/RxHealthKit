//
//  HKHealthStore+Rx.swift
//  RxHealthKit
//
//  Created by Ivan Fabijanovic on 13/06/2018.
//  Copyright © 2018 Ivan Fabijanović. All rights reserved.
//

import Foundation
import HealthKit
import RxSwift

public extension Reactive where Base: HKHealthStore {
    func add(_ samples: [HKSample], to workout: HKWorkout) -> Single<Bool> {
        return Single.create { observer in
            self.base.add(samples, to: workout) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    func delete(_ object: HKObject) -> Single<Bool> {
        return Single.create { observer in
            self.base.delete(object) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    @available(iOS 9.0, *)
    func delete(_ objects: [HKObject]) -> Single<Bool> {
        return Single.create { observer in
            self.base.delete(objects) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    @available(iOS 9.0, *)
    func deleteObjects(of objectType: HKObjectType, predicate: NSPredicate) -> Single<(Bool, Int)> {
        return Single.create { observer in
            self.base.deleteObjects(of: objectType, predicate: predicate) { (success, count, error) in
                error.map { observer(.error($0)) } ?? observer(.success((success, count)))
            }
            return Disposables.create {}
        }
    }
    
    func disableBackgroundDelivery(for type: HKObjectType) -> Single<Bool> {
        return Single.create { observer in
            self.base.disableBackgroundDelivery(for: type) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    func disableAllBackgroundDelivery() -> Single<Bool> {
        return Single.create { observer in
            self.base.disableAllBackgroundDelivery { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency) -> Single<Bool> {
        return Single.create { observer in
            self.base.enableBackgroundDelivery(for: type, frequency: frequency) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    @available(iOS 8.2, *)
    func preferredUnits(for quantityTypes: Set<HKQuantityType>) -> Single<[HKQuantityType: HKUnit]> {
        return Single.create { observer in
            self.base.preferredUnits(for: quantityTypes) { (result, error) in
                error.map { observer(.error($0)) } ?? observer(.success(result))
            }
            return Disposables.create {}
        }
    }
    
    func requestAuthorization(toShare: Set<HKSampleType>?, read: Set<HKObjectType>?) -> Single<Bool> {
        return Single.create { observer in
            self.base.requestAuthorization(toShare: toShare, read: read) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    func save(_ object: HKObject) -> Single<Bool> {
        return Single.create { observer in
            self.base.save(object) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    func save(_ objects: [HKObject]) -> Single<Bool> {
        return Single.create { observer in
            self.base.save(objects) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    @available(iOS 10.0, *)
    func startWatchApp(with workoutConfiguration: HKWorkoutConfiguration) -> Single<Bool> {
        return Single.create { observer in
            self.base.startWatchApp(with: workoutConfiguration) { (success, error) in
                error.map { observer(.error($0)) } ?? observer(.success(success))
            }
            return Disposables.create {}
        }
    }
    
    // MARK: - Queries
    
    @available(iOS 9.3, *)
    func activitySummaryQuery(
        predicate: NSPredicate?,
        monitorUpdates: Bool = false
        ) -> Observable<[HKActivitySummary]> {
        return Observable.create { observer in
            let handler: (HKActivitySummaryQuery, [HKActivitySummary]?, Error?) -> Void = { (_, activitySummaries, error) in
                if let error = error {
                    observer.on(.error(error))
                } else {
                    observer.on(.next(activitySummaries ?? []))
                    if !monitorUpdates { observer.on(.completed) }
                }
            }
            
            let query = HKActivitySummaryQuery(predicate: predicate, resultsHandler: handler)
            if monitorUpdates {
                query.updateHandler = handler
            }
            
            self.base.execute(query)
            return Disposables.create {
                if monitorUpdates { self.base.stop(query) }
            }
        }
    }
    
    @available(iOS 9.0, *)
    func anchoredObjectQuery(
        type: HKSampleType,
        predicate: NSPredicate?,
        anchor: HKQueryAnchor?,
        limit: Int,
        monitorUpdates: Bool = false
        ) -> Observable<([HKSample], [HKDeletedObject], HKQueryAnchor?)> {
        return Observable.create { observer in
            let handler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { (_, samples, deletedObjects, anchor, error) in
                if let error = error {
                    observer.on(.error(error))
                } else {
                    observer.on(.next((samples ?? [], deletedObjects ?? [], anchor)))
                    if !monitorUpdates { observer.on(.completed) }
                }
            }
            
            let query = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: anchor, limit: limit, resultsHandler: handler)
            if monitorUpdates {
                query.updateHandler = handler
            }
            
            self.base.execute(query)
            return Disposables.create {
                if monitorUpdates { self.base.stop(query) }
            }
        }
    }
    
    func correlationQuery(
        type correlationType: HKCorrelationType,
        predicate: NSPredicate?,
        samplePredicates: [HKSampleType : NSPredicate]?
        ) -> Single<[HKCorrelation]> {
        return Single.create { observer in
            let query = HKCorrelationQuery(type: correlationType, predicate: predicate, samplePredicates: samplePredicates) { (_, correlation, error) in
                error.map { observer(.error($0)) } ?? observer(.success(correlation ?? []))
            }
            self.base.execute(query)
            return Disposables.create {}
        }
    }
    
    @available(iOS 10.0, *)
    func documentQuery(
        documentType: HKDocumentType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?,
        includeDocumentData: Bool
        ) -> Observable<[HKDocumentSample]> {
        return Observable.create { observer in
            let query = HKDocumentQuery(documentType: documentType, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors, includeDocumentData: includeDocumentData) { (_, documentSamples, isCompleted, error) in
                if let error = error {
                    observer.on(.error(error))
                } else {
                    observer.on(.next(documentSamples ?? []))
                    if isCompleted { observer.on(.completed) }
                }
            }
            self.base.execute(query)
            return Disposables.create {}
        }
    }
    
    func observerQuery(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        usingBackgroundUpdates: Bool = false
        ) -> Observable<()> {
        return Observable.create { observer in
            let query = HKObserverQuery(sampleType: sampleType, predicate: predicate) { (_, completionHandler, error) in
                if let error = error {
                    observer.on(.error(error))
                } else {
                    observer.on(.next(()))
                    if usingBackgroundUpdates { completionHandler() }
                }
            }
            self.base.execute(query)
            return Disposables.create { self.base.stop(query) }
        }
    }
    
    func sampleQuery(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?
        ) -> Single<[HKSample]> {
        return Single.create { observer in
            let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors) { (_, samples, error) in
                error.map { observer(.error($0)) } ?? observer(.success(samples ?? []))
            }
            self.base.execute(query)
            return Disposables.create {}
        }
    }
    
    func sourceQuery(
        sampleType: HKSampleType,
        samplePredicate objectPredicate: NSPredicate?
        ) -> Single<Set<HKSource>> {
        return Single.create { observer in
            let query = HKSourceQuery(sampleType: sampleType, samplePredicate: objectPredicate) { (_, sources, error) in
                error.map { observer(.error($0)) } ?? observer(.success(sources ?? []))
            }
            self.base.execute(query)
            return Disposables.create {}
        }
    }
    
    func statisticsCollectionQuery(
        quantityType: HKQuantityType,
        quantitySamplePredicate: NSPredicate?,
        options: HKStatisticsOptions = [],
        anchorDate: Date,
        intervalComponents: DateComponents,
        monitorUpdates: Bool = false
        ) -> Observable<HKStatisticsCollection?> {
        return Observable.create { observer in
            let handler: (HKStatisticsCollection?, Error?) -> Void = { (result, error) in
                if let error = error {
                    observer.on(.error(error))
                } else {
                    observer.on(.next(result))
                    if !monitorUpdates { observer.on(.completed) }
                }
            }
            
            let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: quantitySamplePredicate, options: options, anchorDate: anchorDate, intervalComponents: intervalComponents)
            query.initialResultsHandler = { (_, result, error) in handler(result, error) }
            
            if monitorUpdates {
                query.statisticsUpdateHandler = { (_, _, result, error) in handler(result, error) }
            }
            
            self.base.execute(query)
            return Disposables.create {
                if monitorUpdates { self.base.stop(query) }
            }
        }
    }
    
    func statisticsQuery(
        quantityType: HKQuantityType,
        quantitySamplePredicate: NSPredicate?,
        options: HKStatisticsOptions = []
        ) -> Single<HKStatistics?> {
        return Single.create { observer in
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: quantitySamplePredicate, options: options) { (_, statistics, error) in
                error.map { observer(.error($0)) } ?? observer(.success(statistics))
            }
            self.base.execute(query)
            return Disposables.create {}
        }
    }
}
