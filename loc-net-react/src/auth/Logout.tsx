import { useAuth } from "./AuthProvider";

export default function Logout() {
    const auth = useAuth();

    async function logoutAction() {
        await auth.logout();
    }

    return <>
        <button onClick={logoutAction} className="button-link">Logout</button>
    </>;
};
