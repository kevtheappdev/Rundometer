//
//  RequestAccessView.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/22/21.
//

import SwiftUI

struct RequestAccessView: View {
    @State var healthDataAuthorized = false
    
    var body: some View {
            if !healthDataAuthorized {
                Button("Allow Access to Health Data", action: {
                    ActivityFetcher.shared.requestAccess { (result) in

                        switch result {
                        case .success():
                            healthDataAuthorized = true
                            break
                        case .failure(let error):
                            switch error {
                            case .unsupportedDeviceErrror:
                                print("unsupported device")
                            case .authorizationError(let error):
                                print("error: \(error.debugDescription)")
                            case .queryError(_):
                                fatalError("NEVER")
                            }
                        }
                    }
                    })
            } else {
                ContentView()
            }
    }
}

struct RequestAccessView_Previews: PreviewProvider {
    static var previews: some View {
        RequestAccessView()
    }
}
