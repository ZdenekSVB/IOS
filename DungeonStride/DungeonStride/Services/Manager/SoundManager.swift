//
//  SoundManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//


//
//  SoundManager.swift
//  DungeonStride
//
//  Created by Zdeněk Svoboda on 26.01.2026.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {}
    
    // Přehrát systémový zvuk (kliknutí, potvrzení)
    // ID 1104 je "Tock", 1103 je "Tink", 1004 je "Press"
    func playSystemClick() {
        // Zkontrolujeme, zda má uživatel zapnuté zvuky (to by mělo být v UserSettings, 
        // ale pro jednoduchost to voláme vždy a kontrolu uděláme ve View)
        AudioServicesPlaySystemSound(1104)
    }
    
    func playSystemSuccess() {
        AudioServicesPlaySystemSound(1001) // Mail Sent / Success sound
    }
    
    // Přehrát vlastní zvuk (pokud přidáš mp3 do projektu)
    func playSound(named soundName: String, extension ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: ext) else { return }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            audioPlayers[soundName] = player // Uložíme referenci, aby se zvuk neutnul
        } catch {
            print("Chyba při přehrávání zvuku: \(error.localizedDescription)")
        }
    }
}