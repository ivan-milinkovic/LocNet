import { Outlet } from "react-router";
import { AuthProvider } from "./auth/AuthProvider";
import { QueryClientProvider } from "@tanstack/react-query";
import { ErrorBoundary, FallbackProps } from "react-error-boundary";
import { Suspense } from "react";
import queryClient from "./services/queryClient";
import Header from "./Header";

const Layout = () => {
    function errorView(props: FallbackProps) {
        return <>Error: {props.error.name} {props.error.message}</>
    }

    return <AuthProvider>
        <QueryClientProvider client={queryClient}>
            <Header />
            <ErrorBoundary fallbackRender={errorView}>
                <Suspense fallback={<>Loading...</>}>
                    <Outlet />
                </Suspense>
            </ErrorBoundary>
        </QueryClientProvider>
    </AuthProvider>
};

export default Layout;
