//
//  RootTabView.swift
//  CoffeeCozy
//
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//  Created by Vít Čevelík on 12.06.2025.
//

import SwiftUI
import Foundation

struct RootTabView: View {
    var isAdmin: Bool

    var body: some View {
        if isAdmin {
            AdminTabView()
        } else {
            UserTabView()
        }
    }
}
