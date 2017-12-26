//
//  Item.swift
//  Todoey
//
//  Created by Andrew Jenson on 12/25/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import Foundation

// title and done/notDone Boolean
// Conform class to the protocols of encodable and decodable
class Item: Codable {

    var title: String = ""
    var done: Bool = false
}
