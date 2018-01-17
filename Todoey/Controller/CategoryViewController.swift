//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Andrew Jenson on 12/26/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    // MARK: - Properties

    var categoryArray = [Category]()    // initialize as an empty array
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        loadCategories()
    }

    // MARK: - Data Manipulation Methods

    // Save Data
    func saveCategories() {
        do {
            // try to commit whatever is in current context
            try context.save()
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

        let request: NSFetchRequest<Category> = Category.fetchRequest()

        do {
            // If the fetchRequest is successful, then save the data to the categoryArray property
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }

        tableView.reloadData()
    }

    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add", style: .default) { (action) in

            // Create a new NSManagedObject, newCategory
            // reference global variable 'context' insdie a closure with 'self'
            let newCategory = Category(context: self.context)

            // setup newCategory with whatever the user input in the textField
            newCategory.name = textField.text!

            // append newCategory to categoryArray
            self.categoryArray.append(newCategory)
            print("categoryArray: \(self.categoryArray)")

            // save to data model
            self.saveCategories()
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
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        // .attribute of Entity
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }

    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue "goToItems"
        // we need to intialize all of the items associated with the selected Category (in prepare(for segue))

        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController

        // What was the selected cell, we don't have that insight in this method, but we do in tableView didSelectRow At indexPath.
        // .indexPathForSelectedRow is an (optional) indexPath that will identify the current row that is selected. B/c optional, put it inside an if let statement.
        if let indexPath = tableView.indexPathForSelectedRow {
            // if not nil, then we are going to select destinationVC.selectedCategory from the ToDoListViewController. Before we wrote this if let statement, this property did not exsit. So, we need to create this property in the ToDoListViewController.
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }

}
