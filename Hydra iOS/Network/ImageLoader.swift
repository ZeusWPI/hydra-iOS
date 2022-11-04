//
//  ImageLoader.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 27/10/2022.
//

import Foundation
import Combine

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error != nil else {
                print("error while fetching image: \(error)\n")
                return
            }
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}
