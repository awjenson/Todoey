//
//  Item.swift
//  Todoey
//
//  Created by Andrew Jenson on 1/17/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    // When creating properties using Realm, you need to add "@objc dynamic"
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?

    // Inverse relationship (opposite of a forward relationship), that links each Item to a parentCategory that is of the type Category and comes from that property called "items"
    // fromType: requires the class and .self (the type)
    // property: name of the forward relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")

}
