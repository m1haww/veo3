import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            TextToVideoScreen()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            GalleryScreen()
                .tabItem {
                    Label("Gallery", systemImage: "photo.stack.fill")
                }
                .tag(2)
        }
        .accentColor(.purple)
    }
}

#Preview {
    ContentView()
}