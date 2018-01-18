//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Andrew Jenson on 12/26/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    // MARK: - Properties

    // the reason why this inialization could throw an error is that the first time you create a new realm instance it can fail if your resources are contstained, but this can only happen the first time a realm instance is created on a give thread.
    // A collection of Results of Category objects
    let realm = try! Realm()

    // When using Realm, the data type of the objects that we get back are of type Results which is an auto-updating container type that comes from RealmSwift.
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    // MARK: - Data Manipulation Methods

    // Save Data
    // Pass in the new category that we created
    func save(category: Category) {
        do {
            // try to commit changes to Realm
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("saveCategories(): Error saving context \(error)")
        }
        // After save, update tableView
        tableView.reloadData()
    }


    // Load Data
    // Read data here
    // Method with Default Value listed inside loadItems(): = Item.fetchRequest() in case not parameter passed in (see viewDidLoad).
    func loadCategories() {

        // We specify the type (Category.self), this will pull out all of items inside Realm that are of Category objects. The data type of the objects that we get back are of type Results which is a container type that comes from RealmSwift.
        categories = realm.objects(Category.self)

        // Call all data source methods to update table view
        tableView.reloadData()
    }

    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        // new data (Category) gets created when we tap the "Add" button.
        let action = UIAlertAction(title: "Add", style: .default) { (action) in

            // Create a new Category object
            let newCategory = Category()

            // setup newCategory with whatever the user input in the textField
            newCategory.name = textField.text!

            // save to Realm database
            self.save(category: newCategory)
        }

        // add the button to the UIAlert
        alert.addAction(action)

        // In action, setup textField
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            textField.placeholder = "Add a New Category"
        }

        // Display UIAlert
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - TableView Extension
extension CategoryViewController {

    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ?? Nil Coalescing Operator - If categories is not nil then return its count. If categories is nil then use 1.
        return categories?.count ?? 1

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        // .attribute of Entity, use the 'name' property to fill up the textLabel's .text property
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        return cell
    }

    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue "goToItems"
        // we need to intialize all of the items associated with the selected Category (in prepare(for segue))

        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // create a new instance of ToDoListViewController
        let destinationVC = segue.destination as! ToDoListViewController

        // What was the selected cell, we don't have that insight in this method, but we do in tableView didSelectRow At indexPath.
        // .indexPathForSelectedRow is an (optional) indexPath that will identify the current row that is selected. B/c optional, put it inside an if let statement.
        if let indexPath = tableView.indexPathForSelectedRow {
            // if not nil, then we are going to select destinationVC.selectedCategory from the ToDoListViewController. Before we wrote this if let statement, this property did not exsit. So, we need to create this property in the ToDoListViewController.
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

}
