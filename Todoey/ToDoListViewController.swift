//
//  ViewController.swift
//  Todoey
//
//  Created by Andrew Jenson on 12/24/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    let itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
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




}

