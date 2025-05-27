//
//  LoginView.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import SwiftUI
import Observation

struct LoginView: View {
    
    @EnvironmentObject var userSession: UserSession
    @State var viewModel = LoginViewModel()
    
    var body: some View {
        Text("LocNet").font(.title)
        Form {
            Grid {
                GridRow(alignment: .firstTextBaseline) {
                    Text("E-Mail")
                        .foregroundStyle(Color.secondary)
                        .gridColumnAlignment(.trailing)
                    TextField("E-Mail", text: $viewModel.email)
                }
                GridRow {
                    Text("Password")
                        .foregroundStyle(Color.secondary)
                        .gridColumnAlignment(.trailing)
                    SecureField("Password", text: $viewModel.password)
                }
            }
            Button {
                Task {
                    await viewModel.login()
                }
            } label: {
                HStack {
                    Text("Log In")
                    if (viewModel.isLoading) {
                        ProgressView()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .gridColumnAlignment(.center)
        }
        .multilineTextAlignment(.leading)
        .disabled(viewModel.isLoading)
        .task {
            viewModel.userSession = userSession
        }
    }
}

@MainActor
@Observable
class LoginViewModel {
    @ObservationIgnored
    var userSession: UserSession!
    
    var email: String = "user1@test"
    var password: String = "1234"
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    func login() async {
        isLoading = true; defer { isLoading = false }
        do {
            try await userSession.login(credentials: Credentials(email: email, password: password))
        } catch {
            print(error)
        }
    }
}

#Preview {
    let router = Router()
    let httpClient = HttpClient(urlSession: URLSession.shared)
    LoginView()
        .environment(router)
        .environmentObject(UserSession(httpClient: httpClient))
}
