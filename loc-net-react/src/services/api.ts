export const API_URL = import.meta.env.VITE_API_URL || "http://localhost:5297";

export const AuthError: Error = {
  name: "Unauthorized",
  message: "",
};

export const GenericError: Error = {
  name: "GenericError",
  message: "Something went wrong",
};

const jsonHeaders = new Headers({
  "Content-Type": "application/json",
  Accept: "application/json",
});

export type Tokens = {
  tokenType: string;
  accessToken: string;
  refreshToken: string;
};

export async function commonJsonFetch(req: Request): Promise<Response> {
  for (const [key, val] of jsonHeaders.entries()) {
    req.headers.set(key, val);
  }
  return await fetch(req);
}

async function apiLogin(email: string, password: string): Promise<Tokens> {
  const loginUrl = API_URL + "/login";
  const req = new Request(loginUrl, {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
  var res = await commonJsonFetch(req);
  var tokens: Tokens = await res.json();
  if (!tokens.tokenType || !tokens.accessToken || !tokens.refreshToken)
    throw GenericError;
  return tokens;
}

export { apiLogin };
