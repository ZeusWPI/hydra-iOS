//
//  NewsItemStorage.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 25/10/2022.
//

import Foundation
import Combine
import CoreData

class NewsItemStorage: ObservableObject {
    @Published var newsItems = [UgentNewsItem]()
    @Published var loading: Bool
    @Published var failed: Bool;
    private let endpointURL: URL
    
    static let shared: NewsItemStorage = NewsItemStorage()
    
    private init() {
        endpointURL = URL(string: "\(EndPoints.ZEUS_V2)/news/nl.json")!
        loading = false
        failed = false
    }
    
    func refresh() {
        if (self.loading) { return }
        self.loading = true
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
        print("Doing items refresh")
        
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
            
            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decResponse = try decoder.decode(EntriesResponseData<UgentNewsItem>.self, from: content)
                    self.newsItems = decResponse.entries ?? []
                    self.failed = false
                    self.loading = false
                } catch {
                    print("Failed to decode newsItem: \(error)")
                }
            }
        }.resume()
    }
}
