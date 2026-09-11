import { createContext, use, useCallback, useEffect, useMemo, useState } from 'react';
import {
  fetchMe,
  login as loginRequest,
  logout as logoutRequest,
  refreshSession,
  register as registerRequest,
  setAccessToken,
  type SessionUser,
} from '../../lib/api.js';

interface SessionValue {
  readonly user: SessionUser | null;
  readonly loading: boolean;
  login(email: string, password: string): Promise<void>;
  register(email: string, displayName: string, password: string): Promise<void>;
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

  // Al arrancar se intenta renovar: el token de acceso vive en memoria y no
  // sobrevive a una recarga, pero la cookie de refresco si.
  useEffect(() => {
    let vigente = true;

    void (async () => {
      const renovado = await refreshSession();
      if (!vigente) return;

      if (renovado) {
        const perfil = await fetchMe().catch(() => null);
        if (vigente) setUser(perfil);
      }
      if (vigente) setLoading(false);
    })();

    return () => {
      vigente = false;
    };
  }, []);

  const value = useMemo<SessionValue>(
    () => ({
      user,
      loading,
      login: async (email, password) => setUser(await loginRequest(email, password)),
      register: async (email, displayName, password) =>
        setUser(await registerRequest(email, displayName, password)),
      logout: async () => {
        await logoutRequest();
        setAccessToken(null);
        setUser(null);
      },
      actualizarUsuario: setUser,
    }),
    [user, loading],
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
