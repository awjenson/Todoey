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

    // use NSCoder (Coder) to encode and decode our data to a pre-specified a file path and our code converted our array of items (var itemArray = [Item]()) into a plist file that we can save and retrieve from.
    // set as global constant to use within other methods or do-try-catch statements
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()

        print(dataFilePath)

        // load up our "Items.plist"
        loadItems()

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

        saveItems()

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

            // add to our "Items.plist"
            self.saveItems()
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

    func saveItems() {

        // encode the data fro our app into our plist
        // encoder is going to be a new object of type PropertyListEncoder
        // initalize it with ()
        let encoder = PropertyListEncoder()

        do {
            // encode our data
            let data = try encoder.encode(itemArray)
            // write our data to the data file path
            try data.write(to: dataFilePath!)
        } catch {
            print("error with encorder \(error)")
        }
        self.tableView.reloadData()
    }

    func loadItems() {

        // decode from our plist to diplay in our app
        // Tap into our data and set it equal to contentsOf: URL
        if let data = try? Data(contentsOf: dataFilePath!) {
            // Decode our data from the "Items.plist" to display in app
            let decoder = PropertyListDecoder()
            // add .self to [Item] and because we are not specifying its data type, we need to use .self
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("decode error: \(error)")
            }
        }
    }






}

