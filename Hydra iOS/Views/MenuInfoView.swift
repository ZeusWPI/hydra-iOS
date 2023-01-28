//
//  MenuInfoView.swift
//  Hydra
//
//  Created by Ieben Smessaert on 28/01/2023.
//  Copyright © 2023 Zeus WPI. All rights reserved.
//

import SwiftUI

struct MenuInfoView: View {
    var body: some View {
        VStack {
            Text("De resto's van de UGent zijn elke weekdag open van 11u15 tot 14u. 's Avonds kan je ook terecht in resto De Brug van 17u30 tot 21u.").padding(.top, 75)
            Text("Broodjes").font(.title).padding(.top, 10)
            ForEach(sandwiches, id: \.self) {
                item in
                HStack {
                    Text(item.name).padding([.leading])
                    Spacer()
                    Text("€ " + item.price).padding([.trailing])
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    var sandwiches: [RestoSandwich]
    init(sandwiches: [RestoSandwich]) {
        self.sandwiches = sandwiches
    }
}

struct MenuInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MenuInfoView(sandwiches: [RestoSandwich(name: "Kaas", price: "2.80", ingredients: ["Kaas", "Mayonaise"])])
    }
}
