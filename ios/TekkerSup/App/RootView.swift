import SwiftUI

struct RootView: View {
    @EnvironmentObject private var account: AccountStore

    var body: some View {
        Group {
            if account.user == nil {
                AuthFlowView()
            } else {
                MainTabView()
            }
        }
        .background(Theme.background.ignoresSafeArea())
    }
}
