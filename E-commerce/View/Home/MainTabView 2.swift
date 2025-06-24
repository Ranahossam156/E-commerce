import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView() {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationStack {
                FavoriteScreen()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("My Profile", systemImage: "person.fill")
            }
            .tag(2)
        }
        .accentColor(Color("primaryColor"))
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(CurrencyService())
            .environmentObject(OrderViewModel())
            .environmentObject(AuthViewModel())
            .environmentObject(TabViewModel.shared)
    }
}
