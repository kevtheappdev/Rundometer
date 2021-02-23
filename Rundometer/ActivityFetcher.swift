//
//  ActivityFetcher.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/21/21.
//

import HealthKit
import Combine


public enum ActivityFetcherError: Error {
    case unsupportedDeviceErrror
    case authorizationError(Error?)
    case queryError(Error?)
}

public class ActivityFetcher {
    static var shared = ActivityFetcher()
    private var healthStore = HKHealthStore()

    private init() {}

    // TODO: these might not need to be lazy
    // we could optionally populate these whenever we receive a notification that user changes any of these settings
    lazy var isAuthorized: Bool = {
        // TODO: move keys to special file
        return UserDefaults.standard.bool(forKey: "isAuthorized")
    }()
    
    lazy var useMetric: Bool = {
        return UserDefaults.standard.bool(forKey: "useMetric")
    }()
    
    private lazy var unit: HKUnit = {
        if useMetric {
            return HKUnit.meterUnit(with: .kilo)
        } else {
            return HKUnit.mile()
        }
    }()
    
    public func requestAccess(_ result: @escaping (Result<(), ActivityFetcherError>) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            UserDefaults.standard.setValue(false, forKey: "isAuthorized")
            result(.failure(.unsupportedDeviceErrror))
            return
        }
        
        let types = Set([HKObjectType.workoutType(),
                         HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                         HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!])
        
        healthStore.requestAuthorization(toShare: types, read: types) {(success, error) in
            if !success {
                result(.failure(.authorizationError(error)))
                UserDefaults.standard.setValue(false, forKey: "isAuthorized")
            } else {
                result(.success(()))
                UserDefaults.standard.setValue(true, forKey: "isAuthorized")
            }
        }
    }
    
    public func distanceWalked(sinceDate: Date, completion: @escaping (Result<Double, ActivityFetcherError>) -> Void) {
        if !isAuthorized {
            completion(.failure(.authorizationError(nil)))
            return
        }
        
        let predicate = HKQuery.predicateForWorkouts(with: .walking)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        executeWorkoutQuery(withPredicate: predicate, sortDescriptors: [sortDescriptor], completion: {(result) in
            completion(result.map { self.totalWorkoutDistances($0, sinceDate: sinceDate) })
        })
    }
    
    public func distanceRan(sinceDate: Date, completion: @escaping (Result<Double, ActivityFetcherError>) -> Void) {
        if !isAuthorized {
            completion(.failure(.authorizationError(nil)))
            return
        }
        
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        executeWorkoutQuery(withPredicate: predicate, sortDescriptors: [sortDescriptor], completion: {(result) in
            completion(result.map { self.totalWorkoutDistances($0, sinceDate: sinceDate) })
        })
    }
    
    private func totalWorkoutDistances(_ workouts: [HKWorkout], sinceDate: Date) -> Double {
        let distances = workouts.map {(workout) -> Double in
            if workout.startDate > sinceDate {
                return workout.totalDistance?.doubleValue(for: self.unit) ?? 0
            }
            return 0
        }.filter{ $0 != 0 }
        print(distances)
        return distances.reduce(0, +)
    }
    
    private func executeWorkoutQuery(withPredicate predicate: NSPredicate, sortDescriptors: [NSSortDescriptor], completion: @escaping (Result<[HKWorkout], ActivityFetcherError>)-> Void) {
        let query = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 10000, sortDescriptors: sortDescriptors, resultsHandler: {(query, samples, error) in
            if let error = error {
                completion(.failure(.queryError(error)))
            } else {
                guard let workouts = samples as? [HKWorkout] else {
                    completion(.failure(.queryError(nil)))
                    return
                }
                
                completion(.success(workouts))
            }
        })

        healthStore.execute(query)
    }
    
}
