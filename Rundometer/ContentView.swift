//
//  ContentView.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/21/21.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State var milesWalked: Double = 0.0
    @State var milesRan: Double = 0.0
    @State var milesRanPercent: Float = 0.0
    @State var milesWalkedPercent: Float = 0.0
    
    var body: some View {
        VStack {
            ProgressCircle(progress: $milesWalkedPercent)
                .frame(width: 200, height: 200)
            Text(String(format: "Miles Walked %.0f of \(GoalManager.shared.walkingYearlyGoal)", milesWalked))
                .padding()
            Spacer()
            ProgressCircle(progress: $milesRanPercent)
                .frame(width: 200, height: 200)
            Text(String(format: "Miles Ran %.0f of \(GoalManager.shared.runningYearlyGoal)", milesRan))
                .padding()
        }
        .onAppear {
            GoalManager.shared.runningYearlyGoal = 500
            GoalManager.shared.walkingYearlyGoal = 1000
            
            GoalManager.shared.computeWalkingProgressYear({(result) in
                switch result {
                case .success(let progress):
                    self.milesWalked = progress.distance
                    self.milesWalkedPercent = progress.percent
                    break
                case .failure(let error):
                    print("some error: \(error)")
                break
                }
            })
            
            GoalManager.shared.computeRunningProgressYear({(result) in
                switch result {
                case .success(let progress):
                    self.milesRan = progress.distance
                    self.milesRanPercent = progress.percent
                    break
                case .failure(let error):
                    print("some error: \(error)")
                break
                }
            })
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
