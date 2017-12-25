//
//  ViewController.swift
//  Todoey
//
//  Created by Andrew Jenson on 12/24/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]

    override func viewDidLoad() {
        super.viewDidLoad()

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

        cell.textLabel?.text = itemArray[indexPath.row]

        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Tells the delegate which is this class, ToDoListViewController
        print(itemArray[indexPath.row])

        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            // change it to none
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            // add checkmark
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }



        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        // create any local variables that will be accessable to all properties and methods inside this IBAction
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user clicks the add item button on the UIAlert

            self.itemArray.append(textField.text!)

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

