//
//  AppTabNavigation.swift
//  Hydra
//
//  Created by Ieben Smessaert on 07/11/2022.
//  Copyright © 2022 Zeus WPI. All rights reserved.
//

import SwiftUI

struct AppTabNavigation: View {
    
    enum Tab {
        case feed
        case resto
    }
    
    @State private var selection: Tab = .feed
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                Overview()
            }
            .tabItem {
                let menuText = Text("Feed", comment: "Feed menu tab title")
                Label {
                    menuText
                } icon: {
                    Image(systemName: "doc.richtext")
                }.accessibility(label: menuText)
            }
            .tag(Tab.feed)
            
            NavigationView {
                RestoView()
            }
            .tabItem {
                let menuText = Text("Resto", comment: "Resto menu tab title")
                Label {
                    menuText
                } icon: {
                    Image(systemName: "fork.knife")
                }.accessibility(label: menuText)
            }
            .tag(Tab.resto)
        }
    }
}

struct AppTabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppTabNavigation()
    }
}
