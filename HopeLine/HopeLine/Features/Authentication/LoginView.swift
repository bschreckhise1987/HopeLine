//
//  LoginView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var auth: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggingIn = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Welcome to HopeLine") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                }

                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        login()
                    } label: {
                        HStack {
                            Spacer()

                            if isLoggingIn {
                                ProgressView()
                            } else {
                                Text("Log In")
                            }

                            Spacer()
                        }
                    }
                    .disabled(
                        email.isEmpty ||
                        password.isEmpty ||
                        isLoggingIn
                    )
                }

                Section {
                    NavigationLink("Create an Account") {
                        RegisterView()
                    }
                }
            }
            .navigationTitle("HopeLine")
        }
    }

    private func login() {
        errorMessage = ""
        isLoggingIn = true

        Task {
            do {
                try await auth.signIn(
                    email: email,
                    password: password
                )

                isLoggingIn = false
            } catch {
                errorMessage = error.localizedDescription
                isLoggingIn = false
            }
        }
    }
}
