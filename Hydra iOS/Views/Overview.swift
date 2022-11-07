//
//  Overview.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 21/10/2022.
//

import SwiftUI
import RefreshableScrollView

struct Overview: View {
    @Environment(\.managedObjectContext) private var viewContext;
    @ObservedObject var newsItemStorage = NewsItemStorage.shared;
    
    init() {
        NewsItemStorage.shared.refresh()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if (newsItemStorage.loading) {
                    ProgressView("Loading")
                } else {
                    ScrollView {
                        ForEach(newsItemStorage.newsItems) {
                            item in NewsEntry(orgPath: item.orgPath, title: item.title, link: item.link)
                        }
                    }.onRefresh(spinningColor: Color(UIColor.systemGray), text: "Pull to refresh", textColor: Color(UIColor.systemGray), backgroundColor: Color(UIColor.systemBackground)) { refreshControl in
                        DispatchQueue.main.async {
                            newsItemStorage.refresh()
                            refreshControl.endRefreshing()
                        }
                    }
                }
            }
            .navigationTitle(Text("Hydra"))
        }
    }
}

struct Overview_Previews: PreviewProvider {
    static var previews: some View {
        Overview()
    }
}
