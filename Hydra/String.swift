//
//  String.swift
//  OAuthTest
//
//  Created by Feliciaan De Palmenaer on 28/02/2016.
//  Copyright © 2016 Zeus WPI. All rights reserved.
//

import Foundation

extension String {
    func contains(_ query: String) -> Bool {
        let opts: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        return self.range(of: query, options: opts) != nil
    }

    var html2AttributedString: NSMutableAttributedString? {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil) else { return nil }
        return html
    }

    var html2String: String {
        return html2AttributedString?.string ?? ""
    }

    var stripHtmlTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    func html2AttributedString(_ font: UIFont) -> NSMutableAttributedString? {
        if let attributedString = html2AttributedString {
            attributedString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attributedString.length))
            return attributedString
        }
        return nil
    }

    func boundingHeight(_ size: CGSize, font: UIFont = UIFont.systemFont(ofSize: 12)) -> CGFloat {
        let attributedText = NSAttributedString(string: self, attributes: [NSFontAttributeName: font])
        return attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).height
    }
}
