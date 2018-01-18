//
//  Category.swift
//  Todoey
//
//  Created by Andrew Jenson on 1/17/18.
//  Copyright © 2018 Andrew Jenson. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {

    // When creating properties using Realm, you need to add "@objc dynamic"
    @objc dynamic var name: String = ""

    // Forward relationship, each Category has a list of Items
    // Realm uses List is like a Swift Array [], we create items property and it will hold a List of Item objects and we initalize it as an empty List
    let items = List<Item>()
}
