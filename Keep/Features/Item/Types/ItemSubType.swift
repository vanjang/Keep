//
//  ItemSubType.swift
//  Keep
//
//  Created by myung hoon on 23/03/2024.
//

import Foundation

enum ItemSubType: String, Codable {
    case title = "Title", memo = "Memo", email = "Email", username = "Username", password = "Password", longNumber = "Card Long Number", startFrom = "Start from", expireBy = "Expire by", securityCode = "Security Code", sortCode = "Sort Code", accountNumber = "Account Number", none = "", dateCreated = "Created Date", dateModified = "Modified Date"
}
