import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let onCreateTap: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                TabBarButton(
                    icon: "house.fill",
                    title: "Home",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                Spacer()
                
                TabBarButton(
                    icon: "photo.stack.fill",
                    title: "Gallery",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
            }
            .padding(.horizontal, 50)
            
            Button(action: onCreateTap) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -8)
        }
        .frame(height: 65)
        .background(
            Color(red: 0.11, green: 0.11, blue: 0.12)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: -5)
        )
        .padding(.bottom, 20)
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
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .purple : Color(UIColor.systemGray))
                
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .purple : Color(UIColor.systemGray))
            }
        }
    }
}