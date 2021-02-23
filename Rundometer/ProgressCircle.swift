//
//  ProgressCircle.swift
//  Rundometer
//
//  Created by Kevin Turner on 2/22/21.
//

import SwiftUI

struct ProgressCircle: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.red)
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.red)
                .rotationEffect(Angle(degrees:  270))
                .animation(.linear)
            Text(String(format: "%.0f %%", min(self.progress, 1.0) * 100))
                .font(.largeTitle)
                .bold()
        }
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    @State static var progress: Float = 0.35
    
    static var previews: some View {
        ZStack {
            ProgressCircle(progress: $progress)
                .frame(width: 150, height: 150)
        }
    }
}
