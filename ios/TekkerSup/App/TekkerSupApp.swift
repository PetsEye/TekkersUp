import SwiftUI
import UIKit

@main
struct TekkerSupApp: App {
    @StateObject private var account = AccountStore()
    @StateObject private var store = AppStore()

    init() {
        AppAppearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(account)
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(Theme.neon)
        }
    }
}

enum AppAppearance {
    static func apply() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.background)

        let item = UITabBarItemAppearance()
        item.normal.iconColor = UIColor(Theme.muted)
        item.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.muted),
            .font: UIFont.monospacedSystemFont(ofSize: Typo.micro, weight: .black),
        ]
        item.selected.iconColor = UIColor(Theme.neon)
        item.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.neon),
            .font: UIFont.monospacedSystemFont(ofSize: Typo.micro, weight: .black),
        ]
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
