//
//  RundometerApp.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/21/21.
//

import SwiftUI

@main
struct RundometerApp: App {
    var body: some Scene {
        WindowGroup {
            if ActivityFetcher.shared.isAuthorized {
                ContentView()
            } else {
                RequestAccessView()
            }
        }
    }
}
