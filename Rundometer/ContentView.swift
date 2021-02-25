//
//  ContentView.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/21/21.
//

import SwiftUI
import Combine
import HealthKit


struct ActivityProgressView: View {
    var title: String
    @Binding var showActivity: Bool
    @Binding var milesRanPercent: Float
    @Binding var goal: Double
    @Binding var milesComplete: Double
    
    var body: some View {
        if showActivity {
            Section {
                Text("\(title)")
                    .bold()
                    .font(.title3)
                    
                ProgressCircle(progress: $milesRanPercent)
                    .frame(width: 200, height: 200)
                    .padding()
                Text(String(format: "%.2f of %.2f", milesComplete, goal))
                    .bold()
                    .font(.body)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}


struct ContentView: View {
    @State var milesWalked: Double = 0.0
    @State var milesRan: Double = 0.0
    @State var milesRanPercent: Float = 0.0
    @State var milesWalkedPercent: Float = 0.0
    @State var walkingGoal: Double = 0.0
    @State var runningGoal: Double = 0.0
    @State var viewType = 0
    @State var sinceDate = Date.beginningOfCurrentYear()
    @State var settingsPresented: Bool = false
    @ObservedObject var goals = GoalManager.shared
    
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
                
                ActivityProgressView(title: "Running", showActivity: $goals._showRunning, milesRanPercent: $milesRanPercent, goal: $runningGoal, milesComplete: $milesRan)
                
                ActivityProgressView(title: "Walking", showActivity: $goals._showWalking, milesRanPercent: $milesWalkedPercent, goal: $walkingGoal, milesComplete: $milesWalked)

            }
            .frame(maxWidth: .infinity)
            .onChange(of: viewType) { newValue in
                if newValue == 0 {
                    sinceDate = Date.beginningOfCurrentYear()
                } else {
                    sinceDate = Date.beginningOfCurrentMonth()
                }
            }
            .onChange(of: sinceDate) { _ in
                loadActivity()
            }
            .onChange(of: milesRan) { _ in
                runningGoal = viewType == 0 ? goals.runningYearlyGoal : goals.runningMonthlyGoal
            }
            .onChange(of: milesWalked) { _ in
                walkingGoal = viewType == 0 ? goals.walkingYearlyGoal : goals.walkingMonthlyGoal
            }
            .onChange(of: runningGoal) { _ in
                milesRanPercent = Float(milesRan / runningGoal)
            }
            .onChange(of: walkingGoal) { _ in
                milesWalkedPercent = Float(milesWalked / walkingGoal)
            }
            .onChange(of: goals._runningYearlyGoal) { _ in
                runningGoal = viewType == 0 ? goals.runningYearlyGoal : goals.runningMonthlyGoal
            }
            .onChange(of: goals._walkingYearlyGoal) { _ in
                walkingGoal = viewType == 0 ? goals.walkingYearlyGoal : goals.walkingMonthlyGoal
            }
            .onAppear {
                loadActivity()
            }
            .sheet(isPresented: $settingsPresented) { SettingsView() }
            .navigationBarTitle(Text("Rundometer"))
            .navigationBarItems(trailing:
                    Button(action: {
                        self.settingsPresented.toggle()
                    }) {
                        Image(systemName: "gear")
                    })
        }
    }
    
    func loadActivity() {
        // running
        ActivityFetcher.shared.distance(.running, sinceDate: sinceDate, completion: {(result) in
            switch result {
            case .success(let distanceTotal):
                self.milesRan = distanceTotal.roundToTwoDecimals()
                break
            case .failure(_):
                break
            }
        })
        
        // walking
        ActivityFetcher.shared.distance(.running, sinceDate: sinceDate, completion: {(result) in
            switch result {
            case .success(let distanceTotal):
                self.milesWalked = distanceTotal.roundToTwoDecimals()
                break
            case .failure(_):
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
