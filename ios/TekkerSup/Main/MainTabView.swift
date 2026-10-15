import SwiftUI

enum MainTab: Hashable {
    case focus
    case library
    case log
    case config
}

enum SessionCover: Identifiable {
    case solo(Drill)
    case battle

    var id: String {
        switch self {
        case .solo(let drill): return "solo-\(drill.id)"
        case .battle: return "battle"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var account: AccountStore
    @EnvironmentObject private var store: AppStore

    @State private var tab: MainTab = .focus
    @State private var logPath: [UUID] = []
    @State private var cover: SessionCover?

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                FocusView(
                    onStart: { drill in cover = .solo(drill) },
                    onBattle: { cover = .battle }
                )
            }
            .tabItem { Label("Focus", systemImage: "house") }
            .tag(MainTab.focus)

            NavigationStack {
                LibraryView()
            }
            .tabItem { Label("Library", systemImage: "book") }
            .tag(MainTab.library)

            NavigationStack(path: $logPath) {
                LogView()
                    .navigationDestination(for: UUID.self) { id in
                        if let session = store.session(id), let drill = session.drill {
                            ReportView(
                                session: session,
                                onTrainAgain: { cover = .solo(drill) }
                            )
                        } else {
                            EmptyView()
                        }
                    }
            }
            .tabItem { Label("Log", systemImage: "clock") }
            .tag(MainTab.log)

            NavigationStack {
                ConfigView()
            }
            .tabItem { Label("Config", systemImage: "gearshape") }
            .tag(MainTab.config)
        }
        .fullScreenCover(item: $cover) { active in
            switch active {
            case .solo(let drill):
                SessionView(
                    drill: drill,
                    side: store.config.kickingSide,
                    playerName: account.playerName,
                    onFinish: { record in
                        store.add([record])
                        self.cover = nil
                        logPath = [record.id]
                        tab = .log
                    },
                    onExit: { self.cover = nil }
                )
            case .battle:
                BattleView(
                    defaultName: account.playerName,
                    side: store.config.kickingSide,
                    onSave: { records in store.add(records) },
                    onExit: { self.cover = nil }
                )
            }
        }
    }
}
