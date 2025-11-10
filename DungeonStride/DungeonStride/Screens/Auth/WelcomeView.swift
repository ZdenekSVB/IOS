//
//  WelcomeView.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 03.11.2025.
//

import SwiftUI
import GoogleSignIn
import FirebaseFirestore

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    @EnvironmentObject var authViewModel: AuthViewModel

    // Debug režim
    @State private var debugClickCount = 0
    @State private var showDebugButton = false
    @State private var isUploading = false
    @State private var uploadMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color("Paleta3")
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Logo
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 280)
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Login tlačítka
                    VStack(spacing: 16) {
                        Button(action: { showLogin = true }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Login")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("Paleta2"))
                            .cornerRadius(12)
                        }

                        Button(action: {
                            Task { await authViewModel.signInWithGoogle() }
                        }) {
                            HStack(spacing: 12) {
                                Image("Google")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20)
                                    .frame(height: 20)
                                Text("Login with Google")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal, 40)

                    // Registrace
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(Color("Paleta4"))
                        Button("Sign up") {
                            showRegister = true
                        }
                        .foregroundColor(Color("Paleta2"))
                        .fontWeight(.semibold)
                    }

                    Spacer()

                    // Footer — 5x tap = debug
                    VStack {
                        Text("Embark on your adventure")
                            .font(.caption)
                            .foregroundColor(Color("Paleta4"))
                            .padding(.bottom, 10)
                            .onTapGesture {
                                debugClickCount += 1
                                if debugClickCount >= 5 {
                                    withAnimation { showDebugButton = true }
                                }
                            }

                        // Debug tlačítko
                        if showDebugButton {
                            Button {
                                Task { await uploadQuestTemplates() }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.up.doc")
                                    Text("Upload Quests to Firestore")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.red)
                                .cornerRadius(10)
                                .padding(.horizontal, 40)
                            }

                            if let message = uploadMessage {
                                Text(message)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.top, 5)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showLogin) {
                LoginView()
            }
            .fullScreenCover(isPresented: $showRegister) {
                RegisterView(onSwitchToLogin: {
                    showRegister = false
                    showLogin = true
                })
                .environmentObject(authViewModel)
            }
        } // NavigationView
    }
}

// MARK: - Firestore upload
extension WelcomeView {
    /// Nahraje ~50 questů do Firestore (kolekce "quests").
    /// Smaže staré dokumenty v kolekci a přidá nové.
    func uploadQuestTemplates() async {
        let db = Firestore.firestore()
        isUploading = true
        uploadMessage = "Uploading quests..."

        do {
            // Smazat staré dokumenty (pokud nějaké jsou)
            let snapshot = try await db.collection("quests").getDocuments()
            for doc in snapshot.documents {
                try await db.collection("quests").document(doc.documentID).delete()
            }

            // Vygenerovat nové questy
            let quests = QuestTemplates.generateQuests()

            for quest in quests {
                try await db.collection("quests").document(quest.id).setData(quest.toFirestore())
            }

            uploadMessage = "✅ Uploaded \(quests.count) quests successfully!"
        } catch {
            uploadMessage = "❌ Error uploading quests: \(error.localizedDescription)"
            print("Upload error:", error)
        }

        isUploading = false
    }
}
