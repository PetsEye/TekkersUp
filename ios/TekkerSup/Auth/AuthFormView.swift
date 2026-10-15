import SwiftUI

struct AuthFormView: View {
    enum Mode {
        case login
        case register
    }

    let mode: Mode
    let onSwitch: () -> Void
    let onDone: (String) -> Void

    @EnvironmentObject private var account: AccountStore
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var showPassword = false
    @State private var agreed = false
    @State private var updates = false
    @State private var error = ""

    private var isRegister: Bool {
        mode == .register
    }

    var body: some View {
        Screen {
            Button("← Back") { dismiss() }
                .buttonStyle(.tekker(.ghost, small: true))

            BrandMark()

            Headline(isRegister ? "Create an Account" : "Welcome Back", size: Typo.display)

            Text(isRegister
                 ? "To create an account, enter your email and set a password."
                 : "Log in with your email and password to continue.")
                .foregroundStyle(Theme.muted)
                .lineSpacing(Space.xxs)

            VStack(alignment: .leading, spacing: Space.sm) {
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.plain)
                    .fieldBox()

                PasswordField(
                    placeholder: "Password",
                    text: $password,
                    reveal: showPassword,
                    onToggle: { showPassword.toggle() }
                )

                if isRegister {
                    PasswordField(
                        placeholder: "Confirm Password",
                        text: $confirm,
                        reveal: showPassword,
                        onToggle: { showPassword.toggle() }
                    )
                }
            }

            if !error.isEmpty {
                Text(error)
                    .font(Typo.font(Typo.label))
                    .foregroundStyle(Theme.warn)
                    .padding(Space.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(Rectangle().strokeBorder(Theme.warn, lineWidth: 1))
            }

            Button(isRegister ? "Continue" : "Log In", action: submit)
                .buttonStyle(.tekker(.primary, fullWidth: true))

            Text("Or")
                .font(Typo.font(Typo.label).italic())
                .foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity)

            HStack(spacing: Space.sm) {
                socialButton("Google")
                socialButton("Apple")
            }

            if isRegister {
                VStack(alignment: .leading, spacing: Space.sm) {
                    Toggle("I agree to the Terms & Privacy Policy", isOn: $agreed)
                        .toggleStyle(CheckboxStyle())
                    Toggle("Send me updates & news", isOn: $updates)
                        .toggleStyle(CheckboxStyle())
                }
            }

            HStack(spacing: Space.xs) {
                Text(isRegister ? "Already have an account?" : "Don't have an account?")
                    .foregroundStyle(Theme.muted)
                Button(isRegister ? "Log In" : "Register", action: onSwitch)
                    .font(Typo.font(Typo.body, .black))
                    .foregroundStyle(Theme.neon)
                    .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func socialButton(_ title: String) -> some View {
        Button {
        } label: {
            VStack(spacing: Space.xxs) {
                Text(title)
                Text("Coming soon")
                    .font(Typo.font(Typo.micro).italic())
            }
        }
        .buttonStyle(.tekker(.ghost, fullWidth: true))
        .disabled(true)
    }

    private func submit() {
        error = ""
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.wholeMatch(of: /\S+@\S+\.\S+/) != nil else {
            error = "Enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            error = "Password must be at least 6 characters."
            return
        }
        if isRegister {
            guard password == confirm else {
                error = "Passwords do not match."
                return
            }
            guard agreed else {
                error = "Please agree to the Terms & Privacy Policy."
                return
            }
        }
        let result = isRegister
            ? account.register(email: trimmed, password: password)
            : account.login(email: trimmed, password: password)
        if let result {
            error = result
            return
        }
        onDone(trimmed.lowercased())
    }
}
