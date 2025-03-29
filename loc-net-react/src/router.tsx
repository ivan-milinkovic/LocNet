import { createBrowserRouter } from "react-router";
import Layout from "./Layout";
import Login from "./auth/Login";
import Register from "./auth/Register";

const router = createBrowserRouter([
    {
        path: "/",
        element: <Layout />,
        errorElement: <>Root error</>,
        hasErrorBoundary: true,
        children: [
            {
                path: "/login",
                element: <Login />,
            },
            {
                path: "/register",
                element: <Register />,
            },
            {
                path: "/",
                element: <div>Main</div>,
                children: [
                    {
                        path: "/:projectId",
                        element: <div>Project</div>,
                    }
                ]
            },
        ]
    }
]);

export default router;
