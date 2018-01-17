//
//  ViewController.swift
//  Todoey
//
//  Created by Andrew Jenson on 12/24/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit
import CoreData

// searchBar: Step 1/4 - add delegate to class (see extension)
class ToDoListViewController: UITableViewController {

    // MARK: - IBOutlets

    // searchBar: Step 2/4 - add IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: - Properties

    var itemArray = [Item]()

    // Data Model
    // (UIApplication.shared.delegate as! AppDelegate) gives us access to the AppDelegate object. We can not tap into its property 'persistentContainer and we are going to grab the 'viewContext' of the persistentContainer.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // Optional: will initially be nil until we set it in perform(for segue:) with destinationVC.selectedCategory = categories[indexPath.row].
    // Once we set this property (from the prior VC), then we want to call loadItems() to update the tableview with the items related to the selectedCategory from the prior VC.
    // didSet specifies what should happen when variable gets set with a new value
    var selectedCategory: Category? {
        didSet{
            // all code in this body will be called once selectedCategory gets a value (!= nil)
            // when we call loadItems() we are confident that we already have a value for selected category
            // all we want to do is load up the items that fit the current selected category
            // We no longer need to call loadItems() in viewDidLoad b/c we now call it here when we set the value for selectedCategory.
            loadItems()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // We want to get a path of where our current data is being stored.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        // searchBar: Step 3/4 - add delegate to viewDidLoad
        // searchBar delegate
        searchBar.delegate = self

    }

    // MARK: - DataSource

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

//        // Deleting a row (order of code is important)
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

        // set the done property of the selected item to the opposite of whatever it was prior to selecting the cell using !
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        saveItems()

        tableView.deselectRow(at: indexPath, animated: true)
    }





    // MARK: - IBAction

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        // create any local variables that will be accessable to all properties and methods inside this IBAction
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user clicks the add item button on the UIAlert



            // create a new item that is of the class Item
            // We can specify the context of where this item is going to exist (which is going to be the viewContext of the persistentContainer in the appDelegate).
            // But inside this VC, we need to create an object of AppDelegate so that we can access its properties (We don't want the class, we want to create an object of the class). We do this by creating a singleton above called 'context'.

            // IMPORTANT: At the point where we create a new item, we need to specify its parent category (see code below)

            let newItem = Item(context: self.context)
            // set the title property to textField.text (the done property is set to false by default).
            newItem.title = textField.text!
            newItem.done = false

            // IMPORTANT
            newItem.parentCategory = self.selectedCategory

            // only append newItem to our itemArray
            self.itemArray.append(newItem)

            // add to our "Items.plist"
            self.saveItems()
        }

        alert.addTextField { (alertTextField) in
            // add to the textField property created above
            textField = alertTextField
            textField.placeholder = "Create New Item"
        }

        // add the button to the UIAlert
        alert.addAction(action)

        // Display UIAlertController
        present(alert, animated: true, completion: nil)
    }

    func saveItems() {
        // no matter how you decide to update your NSManagedObject, you still need to call context.save()
        // because we're doing all of the CRUD changes inside the context (temp area). And it's only after we are happy with our changes do we call context.save() to COMMIT our changes to our preminent container.
        do {
            // Take the current state of the context and save (COMMIT) changes to our persistantContainer.
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        // after saving/committing data, reload the tableView
        self.tableView.reloadData()
    }

    // How is our TodoListViewController loading up all of the items in the table view?
    // 1. The items come from the itemArray
    // 2. The itemArry comes from the loadItems()
    // 3. The loadItems() fetches all of the NSManagedObjects that belong in the <Item> Entity.
    // 4. But in order to only load the items that have the parent category matching the selectedCategory, we need to (1) query our database and we need to (2) filter our results.
    // 5. We need to create a predicate that is an NSPredicate and initialize it with the formt that the parent category of all of the items that we want back must have its .name property matching (MATCHES %@) the current selectedCategory!.name.
    // 6. Then we need to add this predicate to the request (request.predicate = predicate).
    // 7. Add another parameter to the loadItems() method, called predicate which is a search query that we want to make in order to load up our items. It will be of data type NSPredicate.
    // Method with Default Value listed inside loadItems(): = Item.fetchRequest() in case not parameter passed in (see viewDidLoad).
    // NSPredicate? Optional b/c
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        // R of CRUD = READ. Fetching items is "READ"

        // In order to only display filtered selected category results we need to create a predicate
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        // Because we made predicate Optional, add if let to categoryPredicate and request

        if let additionalPredicate = predicate {
            // new unwrapped additionalPredicate
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            // if not true then,
            request.predicate = categoryPredicate
        }


        // our app has to speak to the context before we can speak to our persistantContainer
        // we want to fetch our current request, which is basically a blank request that returns everything in our persistantContainer, it can throw an error so put it inside a do-try-catch statement.
        do {
            // fetch(T) returns NSFetchRequestResult, which is an array of objects / of 'Items' that is stored in our persistantContainer
            // save results in the itemArray which is what was used to load up the tableView.
            // TRY using our context to '.fetch' these results from our persistent store ('request')
            itemArray = try context.fetch(request)
        } catch {
            print("loadItems(): Error fetching data from context \(error)")
        }

        tableView.reloadData()
    }


}

// MARK: - Search Bar Delegate Methods
extension ToDoListViewController: UISearchBarDelegate {

    // searchBar: Step 4/4 - add delegate methods
    // This method will be triggered once the user taps the search button on the search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // Create a new request.
        // This is a good point to query our database
        // In order to READ from the context, we need to create a request.
        let request: NSFetchRequest<Item> = Item.fetchRequest()

        // Modify the new request with our query.
        // in order to query objects using Core Data, we need to need to use NSPredicate
        // Whatever we search in searchBar is going to replace %@.
        // For all of the items in the array, look for the ones where the "title" contains the seaerchBar text (%@).
        // String comparisons are by default case and diacritic sensitive (c and d)
        // [cd]:  means that your search is NOT sensitive to case and diacritic
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        // Modify the new request with our sort descriptor.
        // Next, sort our query results
        // Now we can add our sortDescriptor to our request. store one search query into array
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        // pass request into the loadItems method as an NSFetchRequest<Item>
        // run our request and fetch results
        loadItems(with: request, predicate: predicate)

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // every single letter is going to trigger this delegate method
        if searchBar.text?.count == 0 {
            loadItems() // which has a default request that fetches all of the items from the persitence store

            DispatchQueue.main.async {
                // tell searchBar to resignFirstResponder
                searchBar.resignFirstResponder()
            }

        }
    }




}



