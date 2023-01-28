//
//  MenuView.swift
//  Hydra
//
//  Created by Ieben Smessaert on 27/01/2023.
//  Copyright © 2023 Zeus WPI. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack {
            Text("Soep").font(.title).padding(.top, 75)
            ForEach(menu.meals, id: \.self) {
                item in
                if item.type == .Side {
                    HStack {
                        Image(item.kind.rawValue).padding([.leading])
                        Text(item.name)
                        Spacer()
                        Text(item.price ?? "").padding([.trailing])
                    }
                }
            }
            Text("Groenten").font(.title).padding(.top, 10)
            ForEach(menu.vegetables, id: \.self) {
                item in
                HStack {
                    Image("vegetables").padding([.leading])
                    Text(item)
                    Spacer()
                }
            }
            Text("Hoofdgerechten").font(.title).padding(.top, 10)
            ForEach(menu.meals, id: \.self) {
                item in
                if item.type == .Main || item.type == .Other {
                    HStack {
                        Image(item.kind.rawValue).padding([.leading])
                        Text(item.name)
                        Spacer()
                        Text(item.price ?? "").padding([.trailing])
                    }
                }
            }
            if menu.meals.contains(where: {$0.type == .Cold }) {
                Text("Koude gerechten").font(.title).padding(.top, 10)
                ForEach(menu.meals, id: \.self) {
                    item in
                    if item.type == .Cold {
                        HStack {
                            Image(item.kind.rawValue).padding([.leading])
                            Text(item.name)
                            Spacer()
                            Text(item.price ?? "").padding([.trailing])
                        }
                    }
                }
            } else {
                EmptyView()
            }
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    var menu: RestoMenu
    init(menu: RestoMenu) {
        self.menu = menu
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(menu: RestoMenu(message: nil, date: Date(), meals: [RestoMenuItem(kindVar: "meat", name: "Spaghetti", price: "€3,80", typeVar: "main")], open: true, vegetables: ["Salad"], lastUpdated: nil))
    }
}
