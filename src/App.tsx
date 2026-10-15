import { useEffect, useState, type ReactNode } from 'react';
import { BookOpen, Clock, House, Settings, type LucideIcon } from 'lucide-react';
import { getDrill } from './lib/drills';
import { loadConfig, loadSessions, saveConfig, saveSessions, type Config } from './lib/storage';
import type { SessionRecord } from './lib/analyzer';
import { FocusScreen } from './screens/Focus';
import { LibraryScreen } from './screens/Library';
import { HistoryScreen } from './screens/History';
import { ConfigScreen } from './screens/Config';
import { SessionScreen } from './screens/Session';
import { ReportScreen } from './screens/Report';
import { BattleScreen } from './screens/Battle';
import { AuthFlow } from './screens/AuthFlow';
import { currentUser, signOut } from './lib/auth';

type Tab = 'focus' | 'library' | 'history' | 'config';
type View =
  | { kind: 'tab'; tab: Tab }
  | { kind: 'session'; drillId: string }
  | { kind: 'battle' }
  | { kind: 'report'; sessionId: string };

const NAV: { id: Tab; label: string; icon: LucideIcon }[] = [
  { id: 'focus', label: 'Focus', icon: House },
  { id: 'library', label: 'Library', icon: BookOpen },
  { id: 'history', label: 'Log', icon: Clock },
  { id: 'config', label: 'Config', icon: Settings },
];

function Page({ children }: { children: ReactNode }) {
  return (
    <div className="app">
      <main className="content">{children}</main>
    </div>
  );
}

export default function App() {
  const [view, setView] = useState<View>({ kind: 'tab', tab: 'focus' });
  const [config, setConfig] = useState<Config>(loadConfig);
  const [sessions, setSessions] = useState<SessionRecord[]>(loadSessions);
  const [user, setUser] = useState<string | null>(currentUser);

  useEffect(() => saveSessions(sessions), [sessions]);
  useEffect(() => saveConfig(config), [config]);

  if (!user) {
    return (
      <Page>
        <AuthFlow onAuthed={setUser} />
      </Page>
    );
  }

  const playerName = user.split('@')[0];
  const goFocus = () => setView({ kind: 'tab', tab: 'focus' });

  if (view.kind === 'session') {
    return (
      <Page>
        <SessionScreen
          key={view.drillId}
          drill={getDrill(view.drillId)}
          side={config.kickingSide}
          playerName={playerName}
          onExit={goFocus}
          onFinish={(record) => {
            setSessions((prev) => [record, ...prev]);
            setView({ kind: 'report', sessionId: record.id });
          }}
        />
      </Page>
    );
  }

  if (view.kind === 'battle') {
    return (
      <Page>
        <BattleScreen
          defaultName={playerName}
          side={config.kickingSide}
          onSave={(records) => setSessions((prev) => [...records, ...prev])}
          onExit={goFocus}
        />
      </Page>
    );
  }

  const report = view.kind === 'report' ? sessions.find((s) => s.id === view.sessionId) : undefined;
  if (report) {
    return (
      <Page>
        <ReportScreen
          session={report}
          onBack={() => setView({ kind: 'tab', tab: 'history' })}
          onRetry={() => setView({ kind: 'session', drillId: report.drillId })}
        />
      </Page>
    );
  }

  const tab = view.kind === 'tab' ? view.tab : 'focus';

  return (
    <div className="app">
      <main className="content">
        {tab === 'focus' && (
          <FocusScreen
            sessions={sessions}
            side={config.kickingSide}
            onStart={(drillId) => setView({ kind: 'session', drillId })}
            onBattle={() => setView({ kind: 'battle' })}
          />
        )}
        {tab === 'library' && <LibraryScreen />}
        {tab === 'history' && (
          <HistoryScreen
            sessions={sessions}
            onOpen={(sessionId) => setView({ kind: 'report', sessionId })}
            onDelete={(sessionId) => setSessions((prev) => prev.filter((s) => s.id !== sessionId))}
          />
        )}
        {tab === 'config' && (
          <ConfigScreen
            config={config}
            onChange={setConfig}
            onClear={() => setSessions([])}
            sessionCount={sessions.length}
            email={user}
            onSignOut={() => {
              signOut();
              setUser(null);
              setView({ kind: 'tab', tab: 'focus' });
            }}
          />
        )}
      </main>

      <nav className="bottom-nav">
        {NAV.map((item) => (
          <button
            key={item.id}
            className={`nav-item${tab === item.id ? ' active' : ''}`}
            onClick={() => setView({ kind: 'tab', tab: item.id })}
          >
            <item.icon size={22} strokeWidth={2} />
            {item.label}
          </button>
        ))}
      </nav>
    </div>
  );
}
