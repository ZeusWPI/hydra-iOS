//
//  RestoMenuStorage.swift
//  Hydra
//
//  Created by Ieben Smessaert on 27/01/2023.
//  Copyright © 2023 Zeus WPI. All rights reserved.
//

import Foundation

class RestoMenuStorage: ObservableObject {
    @Published var menus = [RestoMenu]()
    @Published var loading: Bool
    @Published var failed: Bool
    private let endpointURL: URL
    
    static let shared: RestoMenuStorage = RestoMenuStorage()
    
    let selectedResto = "nl"
    
    private init() {
        endpointURL = URL(string: "\(EndPoints.ZEUS_V2)resto/menu/\(selectedResto)/overview.json")!
        loading = false
        failed = false
    }
    
    func refresh() {
        if (self.loading) { return }
        self.loading = true
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
        print("Doing resto menus refresh")
        
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard error == nil else {
                print("error: \(error!)\n")
                DispatchQueue.main.sync {
                    self.failed = true
                    self.loading = false
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               !(200..<300).contains(response.statusCode) {
                print("http error: \(response.statusCode)\(response.description)\n")
                DispatchQueue.main.sync {
                    self.failed = true
                    self.loading = false
                }
                return
            }
            
            guard let content = data else {
                print("no data")
                DispatchQueue.main.sync {
                    self.failed = true
                    self.loading = false
                }
                return
            }
            
            DispatchQueue.main.sync {
                do {
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
                    let dds = JSONDecoder.DateDecodingStrategy.formatted(df)
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = dds
                    let menus = try decoder.decode([RestoMenu].self, from: content)
                    self.menus = menus
                    for (index, _) in self.menus.enumerated() {
                        self.menus[index].lastUpdated = Date()
                    }
                    
                    self.failed = false
                    self.loading = false
                } catch {
                    print("Failed to decode resto menus: \(error)")
                }
            }
        }.resume()
    }
}
