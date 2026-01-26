//
//  HistoryView.swift
//  DungeonStride
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authViewModel: AuthViewModel
    // UserService zde není přímo potřeba, pokud ho používají až child views,
    // ale necháváme ho v environmentu pro potomky.
    
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Sekce Filtrace
                DateFilterSection(viewModel: viewModel)
                    .zIndex(1) // Aby stín filtru překrýval seznam
                
                // 2. Sekce Seznamu (Loading / Empty / Data)
                HistoryListContent(viewModel: viewModel)
            }
        }
        .navigationTitle("Historie")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        if let uid = authViewModel.currentUserUID {
            if viewModel.activities.isEmpty {
                Task {
                    await viewModel.fetchHistory(for: uid)
                }
            }
        }
    }
}
