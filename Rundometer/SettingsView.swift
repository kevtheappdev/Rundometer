//
//  SettingsView.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/24/21.
//

import SwiftUI

struct ActivitySetting: View {
    var goalName: String
    @State var editingYearly: Bool = false
    @State var editingMonthly: Bool = false
    @Binding var showActivity: Bool
    @Binding var yearlyGoal: String
    @State var monthlyGoal: String
    
    var body: some View {
        Section(header: Text("\(goalName) Goal")) {
            Toggle("Include \(goalName) Goal", isOn: $showActivity)
            if showActivity {
                Text("Yearly Goal")
                    .bold()
                    .font(.title2)
                
                HStack {
                    TextField("\(goalName) Goal (miles/year)", text: $yearlyGoal, onEditingChanged: {(editingChanged) in
                        self.editingYearly = editingChanged
                    })
                    .keyboardType(.decimalPad)
                    .onChange(of: yearlyGoal) {(newValue) in
                        if !self.editingYearly { return }
                        let val = "\(((Double(newValue) ?? 0) / 12).roundToTwoDecimals())"
                        self.monthlyGoal = val
                        }
                    Text("miles")
                }
                Text("Montly Goal")
                    .bold()
                    .font(.title2)
                HStack {
                    TextField("\(goalName) Goal (miles/month)", text: $monthlyGoal, onEditingChanged:{(editingChanged) in
                        self.editingMonthly = editingChanged
                    })
                    .keyboardType(.decimalPad)
                        .onChange(of: monthlyGoal) {(newValue) in
                            if !self.editingMonthly { return }
                            let val = "\((Double(newValue) ?? 0).roundToTwoDecimals() * 12)"
                            self.yearlyGoal = val
                        }
                    Text("miles")
                }
            }
        }
    }
}


struct SettingsView: View {
    @ObservedObject var goals: GoalManager = GoalManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                ActivitySetting(goalName: "Running", showActivity: $goals._showRunning, yearlyGoal: $goals._runningYearlyGoal, monthlyGoal: String(goals.runningMonthlyGoal))
                ActivitySetting(goalName: "Walking", showActivity: $goals._showWalking, yearlyGoal: $goals._walkingYearlyGoal, monthlyGoal: String(goals.walkingMonthlyGoal))
                
            }
            .navigationBarTitle(Text("Set Goals"))
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
