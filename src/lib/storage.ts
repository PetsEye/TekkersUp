import type { SessionRecord, Side } from './analyzer';

const SESSIONS_KEY = 'tekkersup.sessions';
const CONFIG_KEY = 'tekkersup.config';

export interface Config {
  kickingSide: Side;
}

const DEFAULT_CONFIG: Config = { kickingSide: 'right' };

export function loadSessions(): SessionRecord[] {
  try {
    return JSON.parse(localStorage.getItem(SESSIONS_KEY) ?? '[]') as SessionRecord[];
  } catch {
    return [];
  }
}

export function saveSessions(sessions: SessionRecord[]): void {
  localStorage.setItem(SESSIONS_KEY, JSON.stringify(sessions));
}

export function loadConfig(): Config {
  try {
    return { ...DEFAULT_CONFIG, ...(JSON.parse(localStorage.getItem(CONFIG_KEY) ?? '{}') as Partial<Config>) };
  } catch {
    return DEFAULT_CONFIG;
  }
}

export function saveConfig(config: Config): void {
  localStorage.setItem(CONFIG_KEY, JSON.stringify(config));
}
