import "./Header.css"
import { Link } from "react-router";
import Logout from "./auth/Logout";
import { useAuth } from "./auth/AuthProvider";

export default function Header() {
    const { hasAuth } = useAuth();
    return <div className="header">
        <span className="header-start">
            <Link to="/" className="font-larger font-bold">SocNet</Link>
        </span>
        <span className="header-mid"> </span>
        <span className="header-end">
            {(hasAuth)
                ? <Logout />
                : <>
                    <Link to="/login" className="pad-x-4">Login</Link>
                    <Link to="/register" className="pad-x-4">Register</Link>
                </>
            }

        </span>
    </div>;
}
