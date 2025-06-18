// RootTabView.swift
import SwiftUI

struct RootTabView: View {
    let isAdmin: Bool
    
    var body: some View {
        if isAdmin {
            AdminTabView()
        } else {
            UserTabView()
        }
    }
}
