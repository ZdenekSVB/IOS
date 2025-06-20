//
// ReportLogger.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 29.05.2025.
//

import FirebaseFirestore
import FirebaseAuth

enum ReportLogger {
    static func log(_ category: ReportCategory, message: String) {
        let report: [String: Any] = [
            "category": category.rawValue,
            "message": message,
            "date": Timestamp(date: Date())
        ]

        Firestore.firestore().collection("reports").addDocument(data: report) { error in
            if let error = error {
                print("Logging error: \(error.localizedDescription)")
            } else {
                print("Logged: \(category.rawValue) – \(message)")
            }
        }
    }
}
