import CryptoKit
import Foundation

private let usersKey = "tekkersup.users"
private let sessionKey = "tekkersup.session"

private struct Account: Codable {
    let email: String
    let passwordHash: String
}

/// Local accounts. Mirrors the web app: hashes are stored in UserDefaults and never leave the device.
@MainActor
final class AccountStore: ObservableObject {
    @Published private(set) var user: String?

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.user = defaults.string(forKey: sessionKey)
    }

    var playerName: String {
        guard let user else { return "" }
        return user.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? user
    }

    func register(email: String, password: String) -> String? {
        let normalized = normalize(email)
        var accounts = loadAccounts()
        if accounts.contains(where: { $0.email == normalized }) {
            return "An account with this email already exists."
        }
        accounts.append(Account(email: normalized, passwordHash: Self.hash(password)))
        saveAccounts(accounts)
        defaults.set(normalized, forKey: sessionKey)
        return nil
    }

    func login(email: String, password: String) -> String? {
        let normalized = normalize(email)
        guard let account = loadAccounts().first(where: { $0.email == normalized }),
              account.passwordHash == Self.hash(password) else {
            return "Email or password is incorrect."
        }
        defaults.set(normalized, forKey: sessionKey)
        return nil
    }

    /// Makes the account the active user and shows the app.
    func signIn(_ email: String) {
        let normalized = normalize(email)
        defaults.set(normalized, forKey: sessionKey)
        user = normalized
    }

    func signOut() {
        defaults.removeObject(forKey: sessionKey)
        user = nil
    }

    private func normalize(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func loadAccounts() -> [Account] {
        guard let data = defaults.data(forKey: usersKey),
              let accounts = try? JSONDecoder().decode([Account].self, from: data) else {
            return []
        }
        return accounts
    }

    private func saveAccounts(_ accounts: [Account]) {
        if let data = try? JSONEncoder().encode(accounts) {
            defaults.set(data, forKey: usersKey)
        }
    }

    static func hash(_ password: String) -> String {
        SHA256.hash(data: Data(password.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
