import { createBrowserRouter } from "react-router";
import Layout from "./Layout";
import Login from "./auth/Login";
import Register from "./auth/Register";
import Projects from "./content/Projects";
import ProjectRoute from "./content/ProjectRoute";

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
                element: <Projects />,
            },
            {
                path: "/:projectId",
                element: <ProjectRoute />,
            }
        ]
    }
]);

export default router;
