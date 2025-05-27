import SwiftUI
import FirebaseFirestore // Importujte Firestore

struct ContentView: View {
    @State private var message: String = ""
    @State private var fetchedMessage: String = "Žádná zpráva z Firebase"

    var body: some View {
        VStack(spacing: 20) {
            Text("Firebase Test")
                .font(.largeTitle)
                .padding()

            TextField("Zadejte zprávu", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Uložit do Firebase") {
                saveMessageToFirestore()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text(fetchedMessage)
                .font(.headline)
                .padding()

            Button("Načíst z Firebase") {
                fetchMessageFromFirestore()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            // Můžete načíst zprávu hned po načtení pohledu
            fetchMessageFromFirestore()
        }
    }

    func saveMessageToFirestore() {
        let db = Firestore.firestore() // Získáme instanci databáze

        // Vytvoříme referenci na dokument v kolekci "zpravy" s ID "testovaciZprava"
        db.collection("zpravy").document("testovaciZprava").setData([
            "obsah": message,
            "cas": Date() // Uložíme i čas pro zajímavost
        ]) { err in
            if let err = err {
                print("Chyba při ukládání dokumentu: \(err)")
            } else {
                print("Dokument úspěšně uložen!")
                self.message = "" // Vymažeme textové pole
                self.fetchMessageFromFirestore() // Znovu načteme, aby se aktualizoval UI
            }
        }
    }

    func fetchMessageFromFirestore() {
        let db = Firestore.firestore()

        // Získáme referenci na dokument
        db.collection("zpravy").document("testovaciZprava").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let obsah = data?["obsah"] as? String ?? "N/A"
                self.fetchedMessage = "Poslední zpráva: \(obsah)"
                print("Dokument data: \(data ?? [:])")
            } else {
                print("Dokument neexistuje nebo chyba: \(error?.localizedDescription ?? "Neznámá chyba")")
                self.fetchedMessage = "Žádná zpráva nalezena."
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
