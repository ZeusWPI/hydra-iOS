//
//  String.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

extension String {
    func contains(query: String) -> Bool {
        let opts: NSStringCompareOptions = [.CaseInsensitiveSearch, .DiacriticInsensitiveSearch]
        return self.rangeOfString(query, options: opts) != nil
    }

    var html2AttributedString: NSMutableAttributedString? {
        guard
            let data = dataUsingEncoding(NSUTF8StringEncoding)
            else { return nil }
        do {
            return try NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }

    var html2String: String {
        return html2AttributedString?.string ?? ""
    }

    var stripHtmlTags: String {
        return self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
    }
    
    func html2AttributedString(font: UIFont) -> NSMutableAttributedString? {
        if let attributedString = html2AttributedString {
            attributedString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attributedString.length))
            return attributedString
        }
        return nil
    }

    func boundingHeight(size: CGSize) -> CGFloat {
        let attributedText = NSAttributedString(string: self)
        return attributedText.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, context: nil).height
    }
}