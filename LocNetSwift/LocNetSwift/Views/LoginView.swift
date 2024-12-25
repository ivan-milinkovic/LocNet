import SwiftUI

struct LoginView: View {
    
    let session: Session
    @State var username: String = "user1@test"
    @State var password: String = "1234"
    
    var body: some View {
        VStack {
            Group {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
            }
            .frame(maxWidth: 200)
            Button("Log In") {
                Task {
                    await session.login(LoginCredentials(email: username, password: password))
                }
            }
        }
    }
}

//#Preview {
//    let di = DI()
//    LoginView(session: di.session)
//        .frame(width: 300, height: 200)
//}
