//
//  DungeonMapViewModel.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 09.12.2025.
//

import Foundation
import SwiftUI

class DungeonMapViewModel: ObservableObject {
    let mapImageName: String = "isle_of_the_ancients"
    let initialZoomScale: CGFloat = 0.2
    let characterPosition: CGPoint = CGPoint(x: 1000, y: 2000)
    let characterSize: CGFloat = 40
    let mapSize: CGSize = CGSize(width: 4095, height: 4095)
    let bottomSheetText: String = "Toto som ja"
    
    var characterFrame: CGRect {
        CGRect(
            x: characterPosition.x - characterSize / 2,
            y: characterPosition.y - characterSize / 2,
            width: characterSize,
            height: characterSize
        )
    }
    
    func handleCharacterTap() {
        print("MVVM: Postavička kliknuta.")
    }
}
