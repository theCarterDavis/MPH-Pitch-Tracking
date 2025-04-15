import SwiftUI

struct MainAppView: View {
    // Custom colors
    let customGreen = Color(hex: "#0d3222")
    let customYellow = Color(hex: "#f5c84e")
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "baseball")
                    Text("Record")
                }
            
            PitchHistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("History")
                }
        }
        .accentColor(customYellow)
        .onAppear {
            // Style the tab bar
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(customGreen)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}
