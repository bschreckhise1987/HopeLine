//
//  RegisterView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI

// The account creation screen. Validates the form locally before
// handing the new account to AuthManager.
struct RegisterView: View {

    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) private var dismiss

    // The new account's credentials and form state.
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isCreatingAccount = false

    var body: some View {
        Form {

            Section("Create Your HopeLine Account") {

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)

                SecureField(
                    "Confirm Password",
                    text: $confirmPassword
                )
            }

            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            if !successMessage.isEmpty {
                Section {
                    Text(successMessage)
                        .foregroundStyle(.green)
                }
            }

            Section {
                Button {
                    createAccount()
                } label: {
                    HStack {
                        Spacer()

                        if isCreatingAccount {
                            ProgressView()
                        } else {
                            Text("Create Account")
                        }

                        Spacer()
                    }
                }
                .disabled(
                    email.isEmpty ||
                    password.isEmpty ||
                    confirmPassword.isEmpty ||
                    isCreatingAccount
                )
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Validates that the passwords match and meet the minimum length,
    // then creates the account. Shows a success message for a moment
    // before popping back to the login screen.
    private func createAccount() {

        errorMessage = ""
        successMessage = ""

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        isCreatingAccount = true

        Task {
            do {
                try await auth.signUp(
                    email: email,
                    password: password
                )

                successMessage = "Account created successfully!"
                isCreatingAccount = false

                try? await Task.sleep(
                    for: .seconds(1)
                )

                dismiss()

            } catch {
                errorMessage = error.localizedDescription
                isCreatingAccount = false
            }
        }
    }
}
