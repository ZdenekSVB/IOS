//
//  RevivalView.swift
//  DungeonStride
//
//  Created by Vít Čevelík on 27.01.2026.
//

import SwiftUI

struct RevivalView: View {
    @Binding var user: User

    var onRevive: () -> Void

    var progress: Double {
        guard let death = user.deathStats else { return 0 }
        if death.requiredDistance == 0 { return 1.0 }
        return min(death.distanceRunSoFar / death.requiredDistance, 1.0)
    }

    var isReadyToRevive: Bool {
        guard let death = user.deathStats else { return false }
        return death.distanceRunSoFar >= death.requiredDistance
    }

    var body: some View {
        ZStack {
            // Poloprůhledné černé pozadí, aby to vypadalo jako overlay
            Color.black.opacity(0.90).ignoresSafeArea()

            VStack(spacing: 30) {

                Image(
                    systemName: isReadyToRevive
                        ? "figure.walk.motion" : "ghost.fill"
                )
                .font(.system(size: 80))
                .foregroundColor(isReadyToRevive ? .green : .gray)
                .shadow(
                    color: isReadyToRevive ? .green.opacity(0.5) : .clear,
                    radius: 20
                )

                VStack(spacing: 10) {
                    Text(isReadyToRevive ? "DUŠE JE PŘIPRAVENA" : "JSI MRTVÝ")
                        .font(.largeTitle).bold()
                        .foregroundColor(isReadyToRevive ? .green : .red)

                    if let cause = user.deathStats?.causeOfDeath {
                        Text(cause)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                Divider().background(Color.gray)

                // Progress Bar
                if let death = user.deathStats {
                    VStack(spacing: 15) {
                        // ZMĚNA TEXTU: Instrukce pro uživatele
                        Text(
                            isReadyToRevive
                                ? "Cíl splněn!"
                                : "Pro oživení musíš v reálu uběhnout:"
                        )
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 20)
                                    .cornerRadius(10)

                                Rectangle()
                                    .fill(
                                        isReadyToRevive
                                            ? Color.green : Color.blue
                                    )
                                    .frame(
                                        width: geo.size.width * progress,
                                        height: 20
                                    )
                                    .cornerRadius(10)
                                    .animation(.spring(), value: progress)
                            }
                        }
                        .frame(height: 20)

                        HStack {
                            Text(
                                String(
                                    format: "%.2f km",
                                    death.distanceRunSoFar / 1000.0
                                )
                            )
                            .bold()
                            .foregroundColor(.white)
                            Spacer()
                            Text(
                                String(
                                    format: "%.2f km",
                                    death.requiredDistance / 1000.0
                                )
                            )
                            .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }

                Spacer()

                // Tlačítka
                if isReadyToRevive {
                    Button(action: onRevive) {
                        Text("RESPAWN (OŽIVIT)")
                            .font(.title3).bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .shadow(color: .green.opacity(0.5), radius: 15)
                    }
                } else {
                    // Místo tlačítka jen instrukce
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.down.circle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.bottom, 5)

                        Text(
                            "Přepni se do záložky Aktivita\na splň úkol pro návrat."
                        )
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding(30)
        }
    }
}
