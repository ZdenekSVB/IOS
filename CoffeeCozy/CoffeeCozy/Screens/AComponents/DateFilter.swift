//
//  DateFilterView.swift
//  CoffeeCozy
//
//  Created by Zdeněk Svoboda on 23.06.2025.
//
import SwiftUI

struct DateFilter: View {
    @Binding var from: Date
    @Binding var to: Date
    var onFilterChange: () -> Void

    let maxWidth: CGFloat = 140

    var body: some View {
        HStack(spacing: 24) {
            VStack(spacing: 6) {
                DatePicker(
                    "",
                    selection: $from,
                    in: ...to,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .frame(height: 36)
                .padding(.horizontal, 12)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .frame(maxWidth: maxWidth)

                Text("From")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: maxWidth)
            }

            VStack(spacing: 6) {
                DatePicker(
                    "",
                    selection: $to,
                    in: from...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .frame(height: 36)
                .padding(.horizontal, 12)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .frame(maxWidth: maxWidth)

                Text("To")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: maxWidth)
            }
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .onChange(of: from) { newValue, oldValue in
            onFilterChange()
        }
        .onChange(of: to) { newValue, oldValue in
            onFilterChange()
        }
    }
}
