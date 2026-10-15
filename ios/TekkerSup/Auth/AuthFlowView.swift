import SwiftUI

enum AuthStep: Hashable {
    case about
    case login
    case register
    case onboarding(String)
}

struct AuthFlowView: View {
    @EnvironmentObject private var account: AccountStore
    @State private var path: [AuthStep] = []

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(
                onPlay: { path.append(.login) },
                onRegister: { path.append(.register) },
                onAbout: { path.append(.about) }
            )
            .navigationDestination(for: AuthStep.self) { step in
                destination(for: step)
            }
        }
        .tint(Theme.neon)
    }

    @ViewBuilder
    private func destination(for step: AuthStep) -> some View {
        switch step {
        case .about:
            OnboardingView(
                primaryLabel: "Create an account",
                showsBack: true,
                onPrimary: { path = [.register] }
            )
        case .login:
            AuthFormView(
                mode: .login,
                onSwitch: { path = [.register] },
                onDone: { email in account.signIn(email) }
            )
        case .register:
            AuthFormView(
                mode: .register,
                onSwitch: { path = [.login] },
                onDone: { email in path.append(.onboarding(email)) }
            )
        case .onboarding(let email):
            OnboardingView(
                primaryLabel: "Get started",
                showsBack: false,
                onPrimary: { account.signIn(email) }
            )
        }
    }
}
