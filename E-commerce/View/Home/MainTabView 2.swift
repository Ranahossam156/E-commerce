import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tabViewModel: TabViewModel // Use TabViewModel
    
    var body: some View {
        TabView(selection: $tabViewModel.selectedTab) {
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
