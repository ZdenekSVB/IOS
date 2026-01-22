//
//  AuthViewModel.swift
//  DungeonStride
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    // UI State (tohle patří sem)
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // Pro zpětnou kompatibilitu s View (aby ContentView věděl, kdy přepnout)
    // Tuto hodnotu budeme zrcadlit z AuthService
    @Published var isLoggedIn = false
    @Published var currentUserUID: String?
    
    // Závislosti
    private var authService: AuthService { DIContainer.shared.resolve() }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Sledujeme AuthService a aktualizujeme UI stav
        authService.$isLoggedIn
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)
        
        authService.$user
            .receive(on: DispatchQueue.main)
            .map { $0?.uid }
            .assign(to: \.currentUserUID, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - UI Actions (Proxy to AuthService)
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                // isLoggedIn se aktualizuje automaticky přes listener v initu
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func register() {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Vyplňte všechna pole"
            return
        }
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authService.signUp(email: email, password: password, username: username)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = ""
        Task {
            do {
                try await authService.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func logout() {
        do {
            try authService.signOut()
            email = ""
            password = ""
            username = ""
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Metody pro EditProfileViewModel mohou volat přímo AuthService,
    // nebo můžeme nechat tuto proxy metodu:
    func updatePassword(oldPassword: String, newPassword: String) async throws {
        try await authService.updatePassword(oldPassword: oldPassword, newPassword: newPassword)
    }
    
    func deleteAccount() async throws {
        try await authService.deleteAccount()
    }
}
