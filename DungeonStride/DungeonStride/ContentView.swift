//
//  ContentView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 14.10.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainAppView() // Tady bude hlavní obsah aplikace
            } else {
                LoginView()
            }
        }
    }
}



#Preview {
    //ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
