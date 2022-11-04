//
//  URLImageView.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 27/10/2022.
//

import SwiftUI

struct URLImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()
    var hasImage: Bool
    
    init(url: String?) {
        imageLoader = ImageLoader(urlString: url ?? "")
        hasImage = url != nil
    }
    
    var body: some View {
        if (hasImage) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage()
                }
        } else {
            EmptyView()
        }
    }
}

struct URLImageView_Previews: PreviewProvider {
    static var previews: some View {
        URLImageView(url: "https://pics.zeus.gent/ctfchallenge.jpg")

    }
}
