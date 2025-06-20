//
// AOrderViewModel.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import FirebaseFirestore
import Combine

class AOrdersViewModel: ObservableObject {
    @Published var orders: [OrderRecord] = []
    @Published var orderCounts: [OrderCount] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var usersCache: [String: String] = [:]

    var filteredOrders: [OrderRecord] {
        searchText.isEmpty ? orders : orders.filter { $0.userName.localizedCaseInsensitiveContains(searchText) }
    }

    func loadOrders() {
        isLoading = true
        errorMessage = ""

        loadUsers { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.listenOrders()
                } else {
                    self.isLoading = false
                    self.errorMessage = "Failed to load users"
                }
            }
        }
    }

    private func loadUsers(completion: @escaping (Bool) -> Void) {
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let self = self else {
                completion(false)
                return
            }
            if let error = error {
                print("Error loading users: \(error)")
                completion(false)
                return
            }

            self.usersCache.removeAll()
            snapshot?.documents.forEach { doc in
                let data = doc.data()
                let userId = doc.documentID
                let userName = (data["username"] as? String)
                    ?? ((data["firstname"] as? String).map { firstName in
                        let lastName = (data["lastname"] as? String) ?? ""
                        return firstName + (lastName.isEmpty ? "" : " \(lastName)")
                    }) ?? "Unknown User"

                self.usersCache[userId] = userName
            }
            completion(true)
        }
    }

    private func listenOrders() {
        listener = db.collection("orders")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = "Error loading orders: \(error.localizedDescription)"
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        self.errorMessage = "No orders found"
                        return
                    }

                    var tempOrders: [OrderRecord] = []
                    var errorCount = 0

                    for doc in documents {
                        do {
                            var order = try doc.data(as: OrderRecord.self)
                            order.userName = self.usersCache[order.userId] ?? "Unknown User"
                            tempOrders.append(order)
                        } catch {
                            print("Failed to decode order \(doc.documentID): \(error)")
                            errorCount += 1
                        }
                    }

                    self.orders = tempOrders
                    self.errorMessage = errorCount > 0 ? "\(errorCount) orders failed to load" : ""

                    self.updateOrderCounts()
                }
            }
    }

    func updateOrderStatus(orderId: String?, newStatus: String) {
        guard let orderId else { return }
        db.collection("orders").document(orderId).updateData(["status": newStatus]) { error in
            if let error = error {
                print("Failed to update status: \(error)")
            } else {
                print("Order status updated to \(newStatus)")
                ReportLogger.log(.nameChange, message: "Order \(orderId) status changed to \(newStatus)")
            }
        }
    }

    private func updateOrderCounts() {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: orders) { calendar.startOfDay(for: $0.createdAt) }
        orderCounts = grouped.map { OrderCount(date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    deinit {
        listener?.remove()
    }
}
