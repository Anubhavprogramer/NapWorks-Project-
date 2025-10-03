//
//  ContentView.swift
//  NapWorks(Project)
//
//  Created by Anubhav Dubey on 03/10/25.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemGray4  // custom background
        appearance.stackedLayoutAppearance.selected.iconColor = .systemGreen
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
        appearance.shadowColor = UIColor.systemGray3
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        FirebaseApp.configure()
    }
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TabView{
                    MainScreen()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Upload")
                        }
                    
                    ImagesScreen()
                        .tabItem {
                            Image(systemName: "person.crop.circle")
                            Text("Images")
                        }
                }
            } else {
                LoginScreen()
            }
        }
        .onAppear {
            authManager.checkAuthenticationState()
        }
    }
}

#Preview {
    ContentView()
}
