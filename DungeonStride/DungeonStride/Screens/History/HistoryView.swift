import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userService: UserService
    
    @StateObject private var viewModel = HistoryViewModel()
    
    // Pomocná proměnná pro "právě teď", aby se zamezilo budoucnosti
    private let now = Date()
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // --- DATE FILTER SECTION ---
                VStack {
                    Button(action: {
                        withAnimation {
                            viewModel.isFilterExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(themeManager.accentColor)
                            Text("Filtrovat podle data")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)
                            Spacer()
                            Image(systemName: viewModel.isFilterExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .padding()
                        .background(themeManager.cardBackgroundColor)
                    }
                    
                    if viewModel.isFilterExpanded {
                        VStack(spacing: 12) {
                            
                            // Omezení pro "OD":
                            // Max = buď "DO" (aby se nekřížilo), nebo "TEĎ" (aby nešlo do budoucna)
                            let maxStartDate = min(viewModel.filterEndDate, now)
                            
                            DatePicker(
                                "Od:",
                                selection: $viewModel.filterStartDate,
                                in: ...maxStartDate, // Zakáže vše po maxStartDate
                                displayedComponents: .date
                            )
                            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
                            // Pojistka: Když změníš OD, zkontroluj, jestli nepřeskočilo DO
                            .onChange(of: viewModel.filterStartDate) { _, newDate in
                                if newDate > viewModel.filterEndDate {
                                    viewModel.filterEndDate = newDate
                                }
                            }
                            
                            // Omezení pro "DO":
                            // Min = "OD" (aby se nekřížilo)
                            // Max = "TEĎ" (žádná budoucnost)
                            let minEndDate = viewModel.filterStartDate
                            
                            DatePicker(
                                "Do:",
                                selection: $viewModel.filterEndDate,
                                in: minEndDate...now, // Rozsah od "Start" do "Teď"
                                displayedComponents: .date
                            )
                            .environment(\.colorScheme, themeManager.isDarkMode ? .dark : .light)
                            // Pojistka: Když změníš DO, zkontroluj, jestli není před OD
                            .onChange(of: viewModel.filterEndDate) { _, newDate in
                                if newDate < viewModel.filterStartDate {
                                    viewModel.filterStartDate = newDate
                                }
                            }
                            
                            // Reset Tlačítko
                            Button("Zobrazit vše (Reset)") {
                                if let oldest = viewModel.activities.last?.timestamp {
                                    viewModel.filterStartDate = oldest
                                }
                                viewModel.filterEndDate = Date()
                            }
                            .font(.caption)
                            .foregroundColor(themeManager.accentColor)
                            .padding(.top, 5)
                        }
                        .padding()
                        .background(themeManager.cardBackgroundColor)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(themeManager.secondaryTextColor.opacity(0.1)),
                            alignment: .top
                        )
                    }
                }
                .cornerRadius(viewModel.isFilterExpanded ? 0 : 12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                .zIndex(1)
                
                // --- LIST ---
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(themeManager.accentColor)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.activities.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "figure.run.circle")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.secondaryTextColor)
                        Text("Zatím žádné aktivity.")
                            .font(.headline)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            let items = viewModel.filteredActivities
                            
                            if items.isEmpty {
                                Text("V tomto rozmezí nejsou žádné aktivity.")
                                    .foregroundColor(themeManager.secondaryTextColor)
                                    .padding(.top, 40)
                            } else {
                                ForEach(items) { activity in
                                    NavigationLink(destination: HistoryDetailView(activity: activity)) {
                                        HistoryRow(activity: activity)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Historie") // Počeštěno
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let uid = authViewModel.currentUserUID {
                if viewModel.activities.isEmpty {
                    Task {
                        await viewModel.fetchHistory(for: uid)
                    }
                }
            }
        }
    }
}
