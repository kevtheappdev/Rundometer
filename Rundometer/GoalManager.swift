//
//  GoalManager.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/22/21.
//

import Foundation
import Combine
import SwiftUI

public typealias GoalProgress = (distance: Double, percent: Float)

@propertyWrapper
class Persistent<T> {
    var key: String
    var defaultValue: T
    
    var storedValue: T {
        get {
            UserDefaults.standard.value(forKey: key) as? T ?? defaultValue
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    public var wrappedValue: T {
        get { fatalError() }
        set { fatalError() }
    }
    
    public static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance object: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Persistent<T>>
    ) -> T {
        get {
            return object[keyPath: storageKeyPath].storedValue
        }
        set {
            (object.objectWillChange as? ObservableObjectPublisher)?.send()
            object[keyPath: storageKeyPath].storedValue = newValue
        }
    }
    
    
    init(wrappedValue: T, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }
}




public class GoalManager: ObservableObject {
    static var shared = GoalManager()
    
    @Persistent("showRunning") var _showRunning: Bool = true
    @Persistent("runningGoal") var _runningYearlyGoal: String = UserDefaults.standard.string(forKey: "runningGoal") ?? ""
    @Persistent("showWalking") var _showWalking: Bool = true
    @Persistent("walkingGoal") var _walkingYearlyGoal: String = UserDefaults.standard.string(forKey: "walkingGoal") ?? ""

    public var runningYearlyGoal: Double
    {
        set {
            _runningYearlyGoal = String(newValue)
        }

        get {
            return Double(_runningYearlyGoal)?.roundToTwoDecimals() ?? 0.0
        }
    }

    public var walkingYearlyGoal: Double {
        set {
            _walkingYearlyGoal = String(newValue)
        }
        
        get {
            return Double(_walkingYearlyGoal)?.roundToTwoDecimals() ?? 0.0
        }
    }
    
    public var runningMonthlyGoal: Double {
        get {
            return (runningYearlyGoal / 12).roundToTwoDecimals()
        }
        
        set {
            runningYearlyGoal = (newValue * 12).roundToTwoDecimals()
        }
    }
    
    public var walkingMonthlyGoal: Double {
        get {
            return (walkingYearlyGoal / 12).roundToTwoDecimals()
        }
        
        set {
            walkingYearlyGoal = (newValue * 12).roundToTwoDecimals()
        }
    }
    
    
    private init() {}
}
