//
//  TimeInterval.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 12.12.2025.
//

import SwiftUI

extension TimeInterval {
    func stringFormat() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? "00:00:00"
    }
}
