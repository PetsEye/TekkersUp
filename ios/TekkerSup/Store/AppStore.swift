import Foundation

private let sessionsKey = "tekkersup.sessions"
private let configKey = "tekkersup.config"

struct Config: Codable, Equatable {
    var kickingSide: Side = .right
}

/// Saved sessions and settings, persisted as JSON in UserDefaults.
@MainActor
final class AppStore: ObservableObject {
    @Published var sessions: [SessionRecord] {
        didSet { save(sessions, key: sessionsKey) }
    }

    @Published var config: Config {
        didSet { save(config, key: configKey) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.sessions = Self.load([SessionRecord].self, key: sessionsKey, defaults: defaults) ?? []
        self.config = Self.load(Config.self, key: configKey, defaults: defaults) ?? Config()
    }

    func add(_ records: [SessionRecord]) {
        sessions = records + sessions
    }

    func delete(_ id: UUID) {
        sessions.removeAll { $0.id == id }
    }

    func clearSessions() {
        sessions = []
    }

    func session(_ id: UUID) -> SessionRecord? {
        sessions.first { $0.id == id }
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
