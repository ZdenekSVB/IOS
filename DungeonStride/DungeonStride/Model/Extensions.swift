    //
    //  Extensions.swift
    //  DungeonStride
    //
    //  Created by Zdeněk Svoboda on 09.12.2025.
    //


    //
    // Extensions.swift
    //
    import Foundation

    extension TimeInterval {
        func stringFormat() -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter.string(from: self) ?? "00:00:00"
        }
    }
