import FirebaseFirestore
import Combine

class AOrdersViewModel: ObservableObject {
    @Published var orders: [OrderRecord] = []
    @Published var orderCounts: [OrderCount] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage = ""

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Cache uživatelů: [userId: userName]
    private var usersCache: [String: String] = [:]

    var filteredOrders: [OrderRecord] {
        searchText.isEmpty
            ? orders
            : orders.filter { $0.displayUserName.localizedCaseInsensitiveContains(searchText) }
    }

    func loadOrders() {
        isLoading = true
        errorMessage = ""
        
        // Nejprve načti uživatele, aby jména byla dostupná
        loadUsers { [weak self] success in
            guard let self = self else { return }
            if success {
                self.listenOrders()
            } else {
                DispatchQueue.main.async {
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
            if let documents = snapshot?.documents {
                for doc in documents {
                    let data = doc.data()
                    let userId = doc.documentID
                    let userName = data["displayName"] as? String ?? "Unknown User"
                    self.usersCache[userId] = userName
                }
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
                            // doplnit userName z cache podle userId
                            if let cachedName = self.usersCache[order.userId] {
                                order.userName = cachedName
                            }
                            tempOrders.append(order)
                        } catch {
                            print("Failed to decode order \(doc.documentID): \(error)")
                            errorCount += 1
                        }
                    }

                    self.orders = tempOrders

                    if errorCount > 0 {
                        self.errorMessage = "\(errorCount) orders failed to load but others succeeded"
                    } else {
                        self.errorMessage = ""
                    }

                    self.updateOrderCounts()
                }
            }
    }

    private func updateOrderCounts() {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: orders) {
            calendar.startOfDay(for: $0.createdAt)
        }
        orderCounts = grouped.map { OrderCount(date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }

    deinit {
        listener?.remove()
    }
}
