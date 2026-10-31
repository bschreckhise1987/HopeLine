//
//  HomeView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var auth: AuthManager
    @State private var isSigningOut = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Spacer()

                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Welcome to HopeLine")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("You are logged in.")
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    signOut()
                } label: {
                    HStack {
                        if isSigningOut {
                            ProgressView()
                        }

                        Text(
                            isSigningOut
                            ? "Signing Out..."
                            : "Sign Out"
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSigningOut)

            }
            .padding()
            .navigationTitle("HopeLine")
        }
    }

    private func signOut() {
        isSigningOut = true

        Task {
            await auth.signOut()
            isSigningOut = false
        }
    }
}
