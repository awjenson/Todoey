//
//  ViewController.swift
//  Todoey
//
//  Created by Andrew Jenson on 12/24/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()

    // create an object
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // create data from model
        // Our new item is a new object of the type Item
        let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)

        let newItem2 = Item()
        newItem2.title = "Buy Eggos"
        itemArray.append(newItem2)

        let newItem3 = Item()
        newItem3.title = "Destry Demogorgon"
        itemArray.append(newItem3)

        // display data stored in UserDefaults
        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            // if successful, then set our itemArray to equal items
            itemArray = items
        }

    }

    // MARK: - DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)

        // reduce clutter of repeating itemArray[indexPath.row]
        let item = itemArray[indexPath.row]

        // itemArray[indexPath.row] is going to return an item object
        // We want to tap into its title property in order to display the 'title' of each object
        cell.textLabel?.text = item.title

        // use ternary operator to cut down code
        // value = condition ? valueIfTrue : valueIfFalse
        // Set the cell's accessoryType depending on whether the item.done is equal to true.
        // If it is true then set it to .checkmark, if it is false then set it to .none.
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Tells the delegate which is this class, ToDoListViewController

        // set the done property of the selected item to the opposite of whatever it was prior to selecting the cell using !
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        // force the table view to call its data source methods again
        tableView.reloadData()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        // create any local variables that will be accessable to all properties and methods inside this IBAction
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user clicks the add item button on the UIAlert

            // create a new item that is of the class Item
            let newItem = Item()
            // set the title property to textField.text (the done property is set to false by default).
            newItem.title = textField.text!

            // only append newItem to our itemArray
            self.itemArray.append(newItem)

            // save updated itemArray to UserDefaults
            // UserDefaults stores data in info.plist which uses key value pairs
            self.defaults.set(self.itemArray, forKey: "TodoListArray")

            self.tableView.reloadData()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }

        // add the button to the UIAlert
        alert.addAction(action)

        // Display UIAlertController
        present(alert, animated: true, completion: nil)
    }






}

