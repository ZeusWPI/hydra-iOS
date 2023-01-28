//
//  RestoSandwichStorage.swift
//  Hydra
//
//  Created by Ieben Smessaert on 28/01/2023.
//  Copyright © 2023 Zeus WPI. All rights reserved.
//

import Foundation

class RestoSandwichStorage: ObservableObject {
    @Published var sandwiches = [RestoSandwich]()
    @Published var loading: Bool
    @Published var failed: Bool
    private let endpointURL: URL
    
    static let shared: RestoSandwichStorage = RestoSandwichStorage()
        
    private init() {
        endpointURL = URL(string: "\(EndPoints.ZEUS_V2)resto/sandwiches.json")!
        loading = false
        failed = false
    }
    
    func refresh() {
        if (self.loading) { return }
        self.loading = true
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
        print("Doing resto sandwiches refresh")
        
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
                    let decoder = JSONDecoder()
                    let sandwiches = try decoder.decode([RestoSandwich].self, from: content)
                    self.sandwiches = sandwiches
                    
                    self.failed = false
                    self.loading = false
                } catch {
                    print("Failed to decode resto sandwiches: \(error)")
                }
            }
        }.resume()
    }
}
