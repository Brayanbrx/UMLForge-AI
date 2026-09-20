import { createContext, use, useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  fetchMe,
  isConnectionUnavailable,
  login as loginRequest,
  logout as logoutRequest,
  refreshSession,
  sessionRefreshUnavailable,
  register as registerRequest,
  setAccessToken,
  type SessionUser,
  type RegistrationResponse,
} from '../../lib/api.js';
import {
  forgetUser,
  logoutPending,
  offlineUser,
  OFFLINE_USER_KEY,
  rememberUser,
} from '../../lib/offline.js';

interface SessionValue {
  readonly user: SessionUser | null;
  readonly loading: boolean;
  readonly offline: boolean;
  login(email: string, password: string): Promise<void>;
  register(email: string, displayName: string, password: string): Promise<RegistrationResponse>;
  logout(): Promise<void>;
  /**
   * Refresca el usuario de la sesion tras editar el perfil.
   *
   * No vuelve a pedirlo al servidor: la ruta de perfil ya devuelve el usuario
   * actualizado, y quien lo tiene lo pasa. Asi el nombre cambia en la barra
   * superior sin una segunda vuelta.
   */
  actualizarUsuario(usuario: SessionUser): void;
}

const SessionContext = createContext<SessionValue | null>(null);

export function SessionProvider({ children }: { children: React.ReactNode }): React.JSX.Element {
  const [user, setUser] = useState<SessionUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [offline, setOffline] = useState(false);
  const revision = useRef(0);
  const currentUser = useRef(user);
  currentUser.current = user;
  const isOffline = useRef(offline);
  isOffline.current = offline;

  // Al arrancar se intenta renovar: el token de acceso vive en memoria y no
  // sobrevive a una recarga, pero la cookie de refresco si.
  useEffect(() => {
    let vigente = true;
    let checking = false;

    const restore = async (): Promise<void> => {
      if (checking || !vigente) return;
      const currentRevision = revision.current;
      const active = (): boolean => vigente && currentRevision === revision.current;
      checking = true;
      try {
        if (!navigator.onLine) {
          setUser(offlineUser());
          setOffline(true);
          return;
        }
        if (logoutPending()) {
          await logoutRequest();
          if (!active() || logoutPending()) return;
        }
        const renovado = await refreshSession();
        if (!active()) return;
        if (!renovado) {
          if (sessionRefreshUnavailable()) {
            setUser(offlineUser());
            setOffline(true);
          } else {
            forgetUser();
            setUser(null);
            setOffline(false);
          }
          return;
        }
        try {
          const perfil = await fetchMe(AbortSignal.timeout(8000));
          if (!active()) return;
          rememberUser(perfil);
          setUser(perfil);
          setOffline(false);
        } catch (error) {
          if (!active()) return;
          if (isConnectionUnavailable(error)) {
            setUser(offlineUser());
            setOffline(true);
          } else {
            forgetUser();
            setUser(null);
            setOffline(false);
          }
        }
      } finally {
        checking = false;
        if (active()) setLoading(false);
      }
    };
    void restore();
    const reconnect = (): void => {
      void restore();
    };
    const disconnect = (): void => {
      if (vigente) setOffline(true);
    };
    const retry = (): void => {
      if (isOffline.current && navigator.onLine) reconnect();
    };
    const changedAccount = (event: StorageEvent): void => {
      if (event.key !== OFFLINE_USER_KEY && event.key !== null) return;
      if (offlineUser()?.id === currentUser.current?.id) return;
      // A different tab cannot silently replace the author of this tab's drafts.
      revision.current += 1;
      setAccessToken(null);
      setUser(null);
      setLoading(false);
    };
    window.addEventListener('online', reconnect);
    window.addEventListener('offline', disconnect);
    window.addEventListener('storage', changedAccount);
    window.addEventListener('focus', retry);
    // navigator.onLine can remain true when the route to the server disappears.
    // Retry independently of the browser's connectivity events, without blocking edits.
    const timer = window.setInterval(retry, 5000);

    return () => {
      vigente = false;
      window.removeEventListener('online', reconnect);
      window.removeEventListener('offline', disconnect);
      window.removeEventListener('storage', changedAccount);
      window.removeEventListener('focus', retry);
      window.clearInterval(timer);
    };
  }, []);

  const value = useMemo<SessionValue>(
    () => ({
      user,
      loading,
      offline,
      login: async (email, password) => {
        revision.current += 1;
        const perfil = await loginRequest(email, password);
        rememberUser(perfil);
        setUser(perfil);
        setOffline(false);
      },
      register: registerRequest,
      logout: async () => {
        revision.current += 1;
        forgetUser();
        setAccessToken(null);
        setUser(null);
        await logoutRequest();
      },
      actualizarUsuario: (perfil) => {
        rememberUser(perfil);
        setUser(perfil);
      },
    }),
    [user, loading, offline],
  );

  return <SessionContext value={value}>{children}</SessionContext>;
}

export function useSession(): SessionValue {
  const value = use(SessionContext);
  if (value === null) throw new Error('useSession fuera de SessionProvider');
  return value;
}

export function useRequireSession(): SessionUser | null {
  const { user } = useSession();
  return user;
}

/** Envuelve una accion asincrona para mostrar su error sin repetir el try. */
export function useAsyncAction(): {
  error: string | null;
  pending: boolean;
  run(accion: () => Promise<void>): Promise<void>;
} {
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  const run = useCallback(async (accion: () => Promise<void>) => {
    setPending(true);
    setError(null);
    try {
      await accion();
    } catch (causa) {
      setError(causa instanceof Error ? causa.message : 'Algo salio mal.');
    } finally {
      setPending(false);
    }
  }, []);

  return { error, pending, run };
}
