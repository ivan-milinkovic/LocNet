import { createContext, useContext, useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router";
import { apiLogin, AuthError, commonJsonFetch, GenericError, Tokens } from "../services/api";
import { loadStoredTokens, removeStoredTokens, storeTokens } from "./tokenStorage";

type Auth = {
    tokens: Tokens | undefined,
    hasAuth: boolean
    login: (email: string, password: string) => Promise<void>,
    logout: () => void,
    refresh: () => Promise<void>,
    authorizedFetch: (req: Request) => Promise<any>
}

const AuthContext = createContext<Auth>({
    tokens: undefined,
    hasAuth: false,
    login: async () => { },
    logout: () => { },
    refresh: async () => { },
    authorizedFetch: async (_: Request) => { }
});

export function useAuth() {
    return useContext(AuthContext);
}

type ResolveFunction = (value: any) => void
type RejectFunction = (reason?: any) => void

type PendingInfo = {
    resolve: ResolveFunction,
    reject: RejectFunction,
    request: Request
}

type Props = {
    children: React.ReactNode
}

export function AuthProvider({ children }: Props) {
    const [tokens, setTokens] = useState<Tokens | undefined>(loadStoredTokens());
    const pendingRequests = useRef<PendingInfo[]>([]);
    const [isRefreshingToken, setIsRefreshingToken] = useState(false);
    const navigate = useNavigate();

    async function login(email: string, password: string) {
        var newTokens: Tokens = await apiLogin(email, password)
        // var newTokens: Tokens = {type: "Bearer", accessToken: "123 234" }
        setTokens(newTokens);
        storeTokens(newTokens);
        navigate("/")
    }

    function logout() {
        pendingRequests.current = [];
        removeStoredTokens();
        setTokens(undefined);
        navigate("/login")
    }

    async function refresh() {
        console.log("refresh");
        // setIsRefreshingToken(true);
        // setIsRefreshingToken(false);
    }

    async function setAuthorizationHeader(req: Request) {
        req.headers.append("Authorization", auth.tokens!.tokenType + " " + auth.tokens!.accessToken);
    }

    async function authorizedFetch<T>(req: Request): Promise<T> {
        if (!auth.hasAuth) {
            logout();
            throw AuthError;
        }
        return await authorizedFetchOnce(req);
        // return await authorizedFetchWithRefresh(req);
    }

    async function authorizedFetchOnce<T>(req: Request): Promise<T> {
        setAuthorizationHeader(req);
        var res = await commonJsonFetch(req);
        if (!res.ok) {
            if (res.status === 401) {
                logout();
                throw AuthError;
            } else {
                throw GenericError;
            }
        }
        var data: T = await res.json();
        return data;
    }

    async function authorizedFetchWithRefresh<T>(req: Request): Promise<T> {
        if (req.method !== "GET") {
            failAllPending()
            auth.refresh(); // no await
            throw AuthError;
        }
        const wrapperPromise = new Promise<T>(async (resolve, reject) => {
            if (isRefreshingToken) {
                addToPending(req, resolve, reject);
                return;
            }
            setAuthorizationHeader(req);
            var res = await commonJsonFetch(req);
            if (!res.ok) {
                if (res.status === 401) {
                    addToPending(req, resolve, reject);
                    await auth.refresh();
                    await runAllPending();
                } else {
                    reject(GenericError);
                }
            }
            var data: T = await res.json();
            return data;
        });
        return wrapperPromise;
    }

    function addToPending(req: Request, resolve: ResolveFunction, reject: RejectFunction) {
        // avoid non GET requests
        const pending: PendingInfo = {
            resolve: resolve,
            reject: reject,
            request: req
        }
        pendingRequests.current = [...pendingRequests.current, pending];
    }

    async function runAllPending() {
        const req = pendingRequests.current;
        for (const pending of req) {
            try {
                var data = await authorizedFetchOnce(pending.request)
                pending.resolve(data);
            } catch (e) {
                pending.reject(e);
            }
        }
    }

    async function failAllPending() {
        const req = pendingRequests.current;
        for (const pending of req) {
            pending.reject(AuthError);
        }
    }

    const auth: Auth = {
        tokens: tokens,
        hasAuth: !!tokens,
        login: login,
        logout: logout,
        refresh: refresh,
        authorizedFetch: authorizedFetch
    }

    return <AuthContext.Provider value={auth}>{children} </AuthContext.Provider>
}
