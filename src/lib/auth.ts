const USERS_KEY = 'tekkersup.users';
const SESSION_KEY = 'tekkersup.session';

interface Account {
  email: string;
  passwordHash: string;
}

async function hashPassword(password: string): Promise<string> {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(password));
  return Array.from(new Uint8Array(buf))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function loadAccounts(): Account[] {
  try {
    return JSON.parse(localStorage.getItem(USERS_KEY) ?? '[]') as Account[];
  } catch {
    return [];
  }
}

export function currentUser(): string | null {
  return localStorage.getItem(SESSION_KEY);
}

export function signOut(): void {
  localStorage.removeItem(SESSION_KEY);
}

export async function register(email: string, password: string): Promise<string | null> {
  const normalized = email.trim().toLowerCase();
  if (loadAccounts().some((a) => a.email === normalized)) return 'An account with this email already exists.';
  const passwordHash = await hashPassword(password);
  localStorage.setItem(USERS_KEY, JSON.stringify([...loadAccounts(), { email: normalized, passwordHash }]));
  localStorage.setItem(SESSION_KEY, normalized);
  return null;
}

export async function login(email: string, password: string): Promise<string | null> {
  const normalized = email.trim().toLowerCase();
  const account = loadAccounts().find((a) => a.email === normalized);
  if (!account || account.passwordHash !== (await hashPassword(password))) {
    return 'Email or password is incorrect.';
  }
  localStorage.setItem(SESSION_KEY, normalized);
  return null;
}
