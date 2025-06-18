import FirebaseFirestore
import FirebaseAuth

enum ReportLogger {
    static func log(_ category: ReportCategory, message: String) {
        let db = Firestore.firestore()
        let report: [String: Any] = [
            "category": category.rawValue,
            "message": message,
            "date": Timestamp(date: Date())
        ]
        db.collection("reports").addDocument(data: report) { error in
            if let error = error {
                print("Logging error: \(error.localizedDescription)")
            } else {
                print("Logged: \(category.rawValue) – \(message)")
            }
        }
    }
}
