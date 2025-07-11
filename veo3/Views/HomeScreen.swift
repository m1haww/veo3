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
                        .padding(.bottom, 20)
                        
                        // Romance & Intimacy Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Romance & Intimacy")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Text("Create romantic and intimate moments with AI magic.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    VideoStyleCard(title: "AI Kiss", backgroundImage: "kiss")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Romantic Hug", backgroundImage: "hug")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Love Story", backgroundImage: "love")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Wedding", backgroundImage: "wedding")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "First Date", backgroundImage: "date")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Proposal", backgroundImage: "proposal")
                                        .frame(width: 120)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Dance & Movement Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Dance & Movement")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Text("Get moving with trending dance styles and movements.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    VideoStyleCard(title: "Booty Dance", backgroundImage: "booty")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Twerk Mode", backgroundImage: "twerk")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Hip Hop", backgroundImage: "hiphop")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Salsa", backgroundImage: "salsa")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Ballet", backgroundImage: "ballet")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Breakdance", backgroundImage: "break")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Belly Dance", backgroundImage: "belly")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "K-Pop Dance", backgroundImage: "kpop")
                                        .frame(width: 120)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Entertainment & Fun Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Entertainment & Fun")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Text("Have fun with creative and entertaining video effects.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                VideoStyleCard(title: "Comedy Skit", backgroundImage: "comedy")
                                VideoStyleCard(title: "Magic Trick", backgroundImage: "magic")
                                VideoStyleCard(title: "Superhero", backgroundImage: "superhero")
                                VideoStyleCard(title: "Zombie Walk", backgroundImage: "zombie")
                                VideoStyleCard(title: "Robot Dance", backgroundImage: "robot")
                                VideoStyleCard(title: "Animal Morph", backgroundImage: "animal")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                        
                        // Fashion & Style Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Fashion & Style")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Text("Transform your look with fashion and style effects.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    VideoStyleCard(title: "Runway Model", backgroundImage: "runway")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Glamour Shot", backgroundImage: "glamour")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Vintage Look", backgroundImage: "vintage")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Punk Rock", backgroundImage: "punk")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Boho Chic", backgroundImage: "boho")
                                        .frame(width: 120)
                                    VideoStyleCard(title: "Street Style", backgroundImage: "street")
                                        .frame(width: 120)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Fitness & Sports Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Fitness & Sports")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Text("Get fit and show your athletic side.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                VideoStyleCard(title: "Gym Pump", backgroundImage: "gym")
                                VideoStyleCard(title: "Yoga Flow", backgroundImage: "yoga")
                                VideoStyleCard(title: "Boxing", backgroundImage: "boxing")
                                VideoStyleCard(title: "Soccer Star", backgroundImage: "soccer")
                                VideoStyleCard(title: "Basketball", backgroundImage: "basketball")
                                VideoStyleCard(title: "Running", backgroundImage: "running")
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
