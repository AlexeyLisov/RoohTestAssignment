//
//  ContentView.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 18/07/2024.
//

import SwiftUI
import UIKit



struct ContentView: View {
    
    let service = WatchConnectivityService()
    var body: some View {
        VStack {
            MainView()
                .onAppear {
                    service.setupWCSession()
                    Task {
                        await service.activateSession()
                    }
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
