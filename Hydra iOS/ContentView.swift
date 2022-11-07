//
//  ContentView.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 21/10/2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext;
   
    var body: some View {
        AppTabNavigation()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView();
    }
}
