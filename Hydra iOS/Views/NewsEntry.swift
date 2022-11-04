//
//  NewsEntry.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 27/10/2022.
//

import SwiftUI

private struct Entry {
    var image: String?
    var title: String
    var link: URL
    var orgImg: OrgImage?
}

private struct _NewsEntry: View {
    @Environment(\.openURL) var openURL
    var entry: Entry
    init(entry: Entry) {
        self.entry = entry
    }
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                AnyView(entry.orgImg)
                Text(entry.title)
                    .fontWeight(.semibold)
            }
            URLImageView(url: entry.image)
                .frame(width: 200, height: 200)
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 40, alignment: .leading)
        .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
        .background(Color(UIColor.systemFill))
        .cornerRadius(7)
        .onTapGesture {
            openURL(self.entry.link)
        }
    }
}

struct NewsEntry: View {
    fileprivate var entry: Entry
    init (image: String? = nil, title: String, link: String) {
        entry = Entry (
            image: image,
            title: title,
            link: URL(string: link)!,
            orgImg: nil
        )
    }
    init (orgImg: String? = nil, image: String? = nil, title: String, link: String) {
        entry = Entry (
            image: image,
            title: title,
            link: URL(string: link)!,
            orgImg: nil
        )
        if (orgImg != nil) {
            entry.orgImg = OrgImage(img: URLImageView(url: orgImg).image)
        }
    }
    init( orgPath: String? = nil, image: String? = nil, title: String, link: String){
        entry = Entry (
            image: image,
            title: title,
            link: URL(string: link)!,
            orgImg: nil
        )
        if (orgPath != nil) {
            entry.orgImg = OrgImage(img: UIImage(named: orgPath!)!)
        }
    }
    var body: some View {
        _NewsEntry(entry: entry)
    }
}

struct NewsEntry_Previews: PreviewProvider {
    static var previews: some View {
        NewsEntry(orgPath:"logo-ugent-en", title: "Hydra test", link: "zeus.gent")
    }
}
