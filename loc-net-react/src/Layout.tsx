import { Link, Outlet } from "react-router";

const Layout = () => {
    return <div>
        <div>Header
            <Link to="/">Root</Link>
            <Link to="/login">Login</Link>
            <Link to="/register">Register</Link>
        </div>
        <Outlet />
    </div>
};

export default Layout;
