import { Tokens } from "../services/api";

const TokensStoreKey = "LocNetTokens";

export function storeTokens(tokens: Tokens) {
    const json = JSON.stringify(tokens);
    window.localStorage.setItem(TokensStoreKey, json);
}

export function loadStoredTokens(): Tokens | undefined {
    const json = window.localStorage.getItem(TokensStoreKey);
    if (!json) return;
    var tokens: Tokens = JSON.parse(json);
    if (!tokens.tokenType || !tokens.accessToken) {
        removeStoredTokens()
        return;
    }
    return tokens;
}

export function removeStoredTokens() {
    window.localStorage.removeItem(TokensStoreKey);
}
