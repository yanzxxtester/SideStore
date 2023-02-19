//
//  SwiftUIView.swift
//  SideStore
//
//  Created by Fabian Thies on 18.11.22.
//  Copyright © 2022 Fabian Thies. All rights reserved.
//

import SwiftUI
import AsyncImage

struct AppIconView: View {
    let iconUrl: URL?
    var size: CGFloat = 64
    var cornerRadius: CGFloat {
        size * 0.234
    }
    
    var body: some View {
        if let iconUrl {
            AsyncImage(url: iconUrl) { image in
                image
                    .resizable()
            } placeholder: {
                Color(UIColor.secondarySystemBackground)
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension AppIconView: Equatable {
    /// Prevent re-rendering of the view if the parameters didn't change
    static func == (lhs: AppIconView, rhs: AppIconView) -> Bool {
        lhs.iconUrl == rhs.iconUrl && lhs.cornerRadius == rhs.cornerRadius
    }
}


import AltStoreCore

struct AppIconView_Previews: PreviewProvider {

    static let context = DatabaseManager.shared.viewContext
    static let app = StoreApp.makeAltStoreApp(in: context)

    static var previews: some View {
        HStack {
            AppIconView(iconUrl: app.iconURL)

            VStack(alignment: .leading) {
                Text(app.name)
                    .bold()
                Text(app.developerName)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
}
