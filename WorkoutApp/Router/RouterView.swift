//
//  RouterView.swift
//  WorkoutApp
//
//  Created by Valencia Melita Christy on 17/10/25.
//

import SwiftUI

struct RouterView: View {
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            rootView.navigationDestination(for: Route.self) { route in
                destinationView(for: route)
            }
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private var rootView: some View {
        switch router.currentRoute {
        case .onboarding:
            OnboardingView()
        case .survey:
            SurveyView()
        case .home, .summary, .profile:
            TabBarView()
        default:
            OnboardingView()
        }
    }
    
    //MARK: - Destination View Builder
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .onboarding:
            OnboardingView()
        case .survey:
            SurveyView()
        case .home:
            TabBarView()
        case .summary:
            TabBarView()
        case .profile:
            TabBarView()
        //TODO: nanti bisa ditambahin sendiri buat detail"nya, jangan lupa tambahin di file Router casenya
        }
    }
    
    // MARK: - Helper Methods
    private func shouldHideBackButton(for route: Route) -> Bool {
        // Hide back button only for dashboard routes that come from login
        switch route {
        case .home, .summary, .profile:
            //TODO: ini buat yang back buttonnya ga bakalan keliatan kalau pas di page paling luar (bkn detail page)
            return true
        default:
            return false
        }
    }
}

//KALO MAU PAKE KE DETAIL TINGGAL KASIH
// @EnvironmentObject var router: Router -- diatas banget
// router.navigateTo(.home) (.home bisa diganti sesuai casenya)



    
