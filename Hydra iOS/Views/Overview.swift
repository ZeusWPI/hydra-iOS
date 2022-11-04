//
//  Overview.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 21/10/2022.
//

import SwiftUI
import SwiftUIPullToRefresh

struct Overview: View {
    @Environment(\.managedObjectContext) private var viewContext;
    @ObservedObject var newsItemStorage = NewsItemStorage.shared;
    
    init() {
        NewsItemStorage.shared.refresh()
    }
    
    var body: some View {
        GeometryReader { geometry in
            RefreshableScrollView(showsIndicators: false, loadingViewBackgroundColor: Color.white, onRefresh: {done in
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    newsItemStorage.refresh()
                    done()
                }
            }) {
                NavigationView {
                    VStack {
                        if (newsItemStorage.loading) {
                            ProgressView("Loading")
                        } else {
                            List (newsItemStorage.newsItems) {
                                item in NewsEntry(title: item.title, link: item.link)
                            }
                        }
                    }
                    .navigationTitle(Text("Hydra"))
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
    }
}

struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        Overview()
    }
}
