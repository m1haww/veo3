import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeScreen()
                    .tag(0)
                
                TextToVideoScreen()
                    .tag(1)
                
                GalleryScreen()
                    .tag(2)
            }
            .onChange(of: AppStateManager.shared.currentTab) { newValue in
                selectedTab = newValue
            }
            
            // Custom Tab Bar
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    TabBarButton(
                        icon: "wand.and.stars",
                        title: "AI Video",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    
                    TabBarButton(
                        icon: "play.rectangle.fill",
                        title: "Studio",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                    
                    TabBarButton(
                        icon: "person.circle.fill",
                        title: "Library",
                        isSelected: selectedTab == 2,
                        action: { selectedTab = 2 }
                    )
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
                .background(
                    Color.black
                        .opacity(0.95)
                        .ignoresSafeArea()
                )
            }
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 11))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}