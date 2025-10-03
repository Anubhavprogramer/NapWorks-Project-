//
//  ContentView.swift
//  NapWorks(Project)
//
//  Created by Anubhav Dubey on 03/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            UploadScreen()
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
    }
}

#Preview {
    ContentView()
}
