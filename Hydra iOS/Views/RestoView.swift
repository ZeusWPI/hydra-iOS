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

    init() {
        RestoMenuStorage.shared.refresh()
    }
    
    func getTabs(menus: [RestoMenu]) -> [MenuTab] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "EE d"
        print(restoMenuStorage.menus)
        return menus.map {
            MenuTab(title: dateFormatter.string(from: $0.date))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if (restoMenuStorage.loading) {
                ProgressView("Loading")
            } else {
                NavigationView {
                    GeometryReader { geo in
                        MenuTabs(tabs: getTabs(menus: restoMenuStorage.menus), geoWidth: geo.size.width, selectedTab: $selectedTab)
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
