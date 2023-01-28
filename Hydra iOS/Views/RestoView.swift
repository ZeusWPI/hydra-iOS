//
//  RestoView.swift
//  Hydra
//
//  Created by Ieben Smessaert on 08/11/2022.
//  Copyright © 2022 Zeus WPI. All rights reserved.
//

import SwiftUI

struct RestoView: View {
    @Environment(\.managedObjectContext) private var viewContext;
    @ObservedObject var restoMenuStorage = RestoMenuStorage.shared;

    @State private var selectedTab: Int = 0
    let tabs: [MenuTab] = [
        .init(title: "Ma 1"),
        .init(title: "Di 2"),
        .init(title: "Wo 3"),
        .init(title: "Do 4"),
        .init(title: "Vr 5")
    ]

    init() {
        RestoMenuStorage.shared.refresh()
    }

    var body: some View {
        VStack(spacing: 0) {
            if (restoMenuStorage.loading) {
                ProgressView("Loading")
            } else {
                NavigationView {
                    GeometryReader { geo in
                        MenuTabs(tabs: tabs, geoWidth: geo.size.width, selectedTab: $selectedTab)
                        TabView(selection: $selectedTab, content: {
                            MenuView(menu: restoMenuStorage.menus[0])
                                .tag(0)
                            MenuView(menu: restoMenuStorage.menus[1])
                                .tag(1)
                            MenuView(menu: restoMenuStorage.menus[2])
                                .tag(2)
                            MenuView(menu: restoMenuStorage.menus[3])
                                .tag(3)
                            MenuView(menu: restoMenuStorage.menus[4])
                                .tag(4)
                        })
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
            }
        }
    }
}

struct RestoView_Previews: PreviewProvider {
    static var previews: some View {
        RestoView()
    }
}
