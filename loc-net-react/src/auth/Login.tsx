import { useAuth } from "./AuthProvider";

const Login = () => {
    const auth = useAuth();

    async function loginAction(formData: FormData) {
        var email = formData.get("email")!.toString().trim();
        var password = formData.get("password")!.toString().trim();
        await auth.login(email, password);
    }

    return <div className="center-x">
        <form action={loginAction} className="">
            <input type="email" name="email" id="email" required={true} className="block" defaultValue="user1@test" />
            <input type="password" name="password" id="password" required={true} className="block" defaultValue="1234" />
            <button className="block">Login</button>
        </form>
    </div>;
};

export default Login;
