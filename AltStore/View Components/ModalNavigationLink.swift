//
//  ModalNavigationLink.swift
//  SideStore
//
//  Created by Fabian Thies on 03.02.23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import SwiftUI

struct ModalNavigationLink<Label: View, Modal: View>: View {
    let modal: () -> Modal
    let label: () -> Label

    @State var isPresentingModal: Bool = false

    var body: some View {
        SwiftUI.Button {
            self.isPresentingModal = true
        } label: {
            self.label()
        }
        .sheet(isPresented: self.$isPresentingModal) {
            self.modal()
        }
    }
}

//struct ModalNavigationLink_Previews: PreviewProvider {
//    static var previews: some View {
//        ModalNavigationLink()
//    }
//}
