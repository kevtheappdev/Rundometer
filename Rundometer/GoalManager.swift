//
//  GoalManager.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/22/21.
//

import Foundation

public typealias GoalProgress = (distance: Double, percent: Float)

public class GoalManager {
    static var shared = GoalManager()
    
    // TODO: re-evaluate need for this being a singleton
    private var activityFetcher = ActivityFetcher.shared
    
    public var runningYearlyGoal: Double {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "runningGoal")
        }
        
        get {
            return UserDefaults.standard.double(forKey: "runningGoal")
        }
    }
    
    public var walkingYearlyGoal: Double {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "walkingGoal")
        }
        
        get {
            return UserDefaults.standard.double(forKey: "walkingGoal")
        }
    }
    
    public var runningMonthlyGoal: Double {
        get {
            return runningYearlyGoal / 12
        }
        
        set {
            runningYearlyGoal = newValue * 12
        }
    }
    
    public var walkingMonthlyGoal: Double {
        get {
            return walkingYearlyGoal / 12
        }
        
        set {
            walkingYearlyGoal = newValue * 12
        }
    }
    
    private init() {}
    
    public func computeWalkingProgressYear(_ completion: @escaping (Result<GoalProgress, ActivityFetcherError>) -> Void) {
        activityFetcher.distanceWalked(sinceDate: Date.beginningOfCurrentYear(), completion: {(result) in
            completion(result.map{ (distance: $0, percent: Float($0 / self.walkingYearlyGoal)) })
        })
    }
    
    public func computeWalkingProgressMonth(_ completion: @escaping (Result<GoalProgress, ActivityFetcherError>) -> Void) {
        activityFetcher.distanceWalked(sinceDate: Date.beginningOfCurrentMonth(), completion: {(result) in
            completion(result.map{ (distance: $0, percent: Float($0 / self.walkingMonthlyGoal))})
        })
    }
    
    public func computeRunningProgressYear(_ completion: @escaping (Result<GoalProgress, ActivityFetcherError>) -> Void) {
        activityFetcher.distanceRan(sinceDate: Date.beginningOfCurrentYear(), completion: {(result) in
            completion(result.map { (distance: $0, percent: Float($0 / self.runningYearlyGoal))})
        })
    }
    
    public func computeRunningProgressMonth(_ completion: @escaping (Result<GoalProgress, ActivityFetcherError>) -> Void) {
        activityFetcher.distanceWalked(sinceDate: Date.beginningOfCurrentMonth(), completion: {(result) in
            completion(result.map { (distance: $0, percent: Float($0 / self.runningMonthlyGoal))})
        })
    }
}
