import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header with Sign In and Credits
                        HStack {
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Sign In")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "film")
                                        .font(.system(size: 16))
                                    Text("0")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // AI Kiss Banner
                        VStack(spacing: 16) {
                            ZStack {
                                // Gradient Background
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.9, green: 0.6, blue: 0.8),
                                        Color(red: 0.6, green: 0.6, blue: 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 220)
                                .cornerRadius(20)
                                .blur(radius: 30)
                                
                                VStack(spacing: 12) {
                                    Text("AI kiss")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Turn photos into AI kisses!")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Button(action: {}) {
                                        Text("Go for it!")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 32)
                                            .padding(.vertical, 12)
                                            .background(Color.white)
                                            .cornerRadius(25)
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .frame(height: 240)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            // Create video prompt
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "pencil.line")
                                        .font(.system(size: 20))
                                    Text("Create video with a few words")
                                        .font(.system(size: 16, weight: .medium))
                                    Spacer()
                                    Text("ABC")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                        .colorMultiply(Color(red: 0.8, green: 0.6, blue: 1))
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.yellow, .green, .blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                        
                        // Soul Touch Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Soul Touch")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Text("Turn your photo into an emotional, heart-touching short video.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            // Style Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                VideoStyleCard(title: "Rain of", backgroundImage: "rain")
                                VideoStyleCard(title: "Heart Echo", backgroundImage: "heart")
                                VideoStyleCard(title: "Muscle Surge", backgroundImage: "muscle")
                                VideoStyleCard(title: "Balloon Pop", backgroundImage: "balloon")
                                VideoStyleCard(title: "Cloud Nine", backgroundImage: "cloud")
                                VideoStyleCard(title: "Sport Hero", backgroundImage: "sport")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct VideoStyleCard: View {
    let title: String
    let backgroundImage: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Placeholder background
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)
            
            // Title overlay
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// Corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    HomeScreen()
}