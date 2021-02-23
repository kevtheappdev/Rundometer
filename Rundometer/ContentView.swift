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
    @State var walkingGoal: Double = 0.0
    @State var runningGoal: Double = 0.0
    @State var viewType = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $viewType, label: Text("year")) {
                        Text("Year").tag(0)
                        Text("Month").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                
                Section {
                    ProgressCircle(progress: $milesRanPercent)
                        .frame(width: 200, height: 200)
                        .padding()
                    Text(String(format: "Miles Ran %0.0f of %0.0f", milesRan, runningGoal))
                        .bold()
                        .font(.body)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                Section {
                    ProgressCircle(progress: $milesWalkedPercent)
                        .frame(width: 200, height: 200)
                        .padding()
                    Text(String(format: "Miles Walked %0.0f of %0.0f", milesWalked, walkingGoal))
                        .bold()
                        .font(.body)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .padding()

            }
            .frame(maxWidth: .infinity)
            .onChange(of: viewType) { newValue in
                if newValue == 0 {
                    populateYearData()
                } else {
                    populateMonthData()
                }
            }
            .onAppear {
                    GoalManager.shared.runningYearlyGoal = 500
                    GoalManager.shared.walkingYearlyGoal = 1000
                    
                    populateYearData()
            }
            .navigationBarTitle(Text("Rundometer"))
            .navigationBarItems(trailing:
                                Button(action: {
                                            
                                }) {
                                    Image(systemName: "gear")
                                })
            
        }
    }
    
    func populateMonthData() {
        runningGoal = GoalManager.shared.runningMonthlyGoal
        walkingGoal = GoalManager.shared.walkingMonthlyGoal
        
        GoalManager.shared.computeWalkingProgressMonth({(result) in
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
        
        GoalManager.shared.computeRunningProgressMonth({(result) in
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
    
    func populateYearData() {
        runningGoal = GoalManager.shared.runningYearlyGoal
        walkingGoal = GoalManager.shared.walkingYearlyGoal
        
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
