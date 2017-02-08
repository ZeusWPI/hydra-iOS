//
//  RestoManager.swift
//  Hydra
//
//  Created by Simon Schellaert on 12/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import UIKit

let RestoKitErrorDomain = "com.zeus.RestoKit.ErrorDomain"

enum RestoKitError : Int {
    case loadDataFromFileFailed = -5
    case noData                 = -7
    case parseJSONFailed        = -8
}

class RestoManager: NSObject {
    
    // MARK: Initialization
    
    /**
    Returns the shared Resto manager object for the process.

    - returns: The shared RestoManager object.
    */
    class var sharedManager : RestoManager {
        struct Static {
            static let instance : RestoManager = RestoManager()
        }
        return Static.instance
    }
    
    override init() {
        // Limit the disk capacity of the shared URL cache to 4 MB
        URLCache.shared.diskCapacity = 4 * 1024 * 1024
    }
    
    
    // MARK: Public Methods

    /**
    Clears the shared URL cache, removing all stored cached URL responses.
    */
    func removeCachedResponses() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    /**
    Retrieves the menu for the given date in the background and caches it.
    If the menu is already in the cache, the cached menu is used and no request is made.
    
    - parameter date: The date of the menu you want to retrieve.
    
    - parameter completionHandler: A block that is executed on the main queue when the request has succeeded or failed.
                              The optional menu parameter holds the eventually retrieved menu.
                              The optional error parameter holds any error that caused the request to fail.
                              Either the menu or the error is not nil.
    */
    func retrieveMenuForDate(_ date: Date, completionHandler: @escaping (_ menu: Menu?, _ error: NSError?) -> ()) {
        // Construct the URL for the API request based on the year and week of the given date
        let dateComponents = (Calendar.current as NSCalendar).components([.weekOfYear, .year], from: date)
        let URL = Foundation.URL(string: "https://zeus.ugent.be/hydra/api/1.0/resto/menu/\(dateComponents.year)/\(dateComponents.weekOfYear).json")
        
        // We're relying on NSURLCache to cache the data for us when the user is offline
        let URLRequest = Foundation.URLRequest(url: URL!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 0)
        
        NSURLConnection.sendAsynchronousRequest(URLRequest, queue: OperationQueue.main) {
            (URLResponse, data, error) -> Void in
            
            if error != nil {
                completionHandler(nil, error as NSError?)
            } else {
                if data != nil {
                    /**do {
                    try completionHandler(self.menuForDate(date, withData: data!))
                    } catch _ {
                        let error = NSError(domain: RestoKitErrorDomain, code: RestoKitError.noData.rawValue, userInfo: nil)
                        completionHandler(nil, error)
                    }*/ //fix me
                } else {
                    let error = NSError(domain: RestoKitErrorDomain, code: RestoKitError.noData.rawValue, userInfo: nil)
                    completionHandler(nil, error)
                }
            }
        }
    }
    
    // MARK: Private Methods
    
    /**
    Creates a Menu for the given date based on the given JSON data.
    
    - parameter date: The date of the menu you want to parse.
    - parameter data: The NSData representation of the JSON containing the menu for the given date.
    
    - returns: A tuple consisting of an optional menu and an optional error.
              Either the menu or the error is not nil.
    */
    fileprivate func menuForDate(_ date : Date, withData data : Data) throws -> (menu: Menu?, error : NSError?) {
        let JSONDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : AnyObject]
        if let JSONDictionary = JSONDictionary {
            // Create a date string from the given date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            
            if let JSONMenu = JSONDictionary[dateString] as? [String : AnyObject] {
                var menuItems = [MenuItem]()
                
                let JSONMainMenuItems      = JSONMenu["meat"]       as? [[String : AnyObject]]
                let JSONSoupMenuItems      = JSONMenu["soup"]       as? [[String : AnyObject]]
                let JSONVegetableMenuItems = JSONMenu["vegetables"] as? [String]
                
                if JSONMainMenuItems != nil {
                    for JSONMainMenuItem in JSONMainMenuItems! {
                        let name = JSONMainMenuItem["name"] as! String
                        var type : MenuItemType = .main
                        
                        // Some soups are also passed as main menu items in the API.
                        // In the app, however, we consider them to be of the type .Soup.
                        if name.range(of: "soep ") != nil || name.hasSuffix("soep") {
                            type = .soup
                        }
                        
                        let menuItem = MenuItem(name: name.sentenceCapitalizedString as String, type: type, price: NSDecimalNumber(euroString: JSONMainMenuItem["price"] as! String))
                        menuItems.append(menuItem)
                    }
                }
                
                if JSONSoupMenuItems != nil {
                    for JSONSoupMenuItem in JSONSoupMenuItems! {
                        let menuItem = MenuItem(name: (JSONSoupMenuItem["name"] as! String).sentenceCapitalizedString as String, type: .soup, price: NSDecimalNumber(euroString: JSONSoupMenuItem["price"] as! String))
                        menuItems.append(menuItem)
                    }
                }
                
                if JSONVegetableMenuItems != nil {
                    for JSONVegetableMenuItem in JSONVegetableMenuItems! {
                        let menuItem = MenuItem(name: JSONVegetableMenuItem.sentenceCapitalizedString as String, type: .vegetable, price: nil)
                        menuItems.append(menuItem)
                    }
                }
                
                let menu = Menu(date: date, menuItems: menuItems, open: JSONMenu["open"] as! Bool)
                return (menu, nil)
            } else {
                let menu = Menu(date: date, menuItems: [], open: false)
                return (menu, nil)
            }
            
        }
        return (nil, nil) //TODO: shouldn't be reached, and needs to be rewritten to use standard hydra resto items
    }
}
