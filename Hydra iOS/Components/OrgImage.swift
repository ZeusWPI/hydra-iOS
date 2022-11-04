//
//  OrgImage.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 28/10/2022.
//

import SwiftUI

struct OrgImage: View {
    var img: UIImage
    init(img: UIImage) {
        self.img = img
    }
    var body: some View {
        Image(uiImage: img)
            .resizable()
            .frame(width: 20, height: 20)
    }
}
