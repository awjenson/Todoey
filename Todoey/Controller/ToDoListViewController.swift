//
//  ViewController.swift
//  Todoey
//
//  Created by Andrew Jenson on 12/24/17.
//  Copyright © 2017 Andrew Jenson. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

// searchBar: Step 1/4 - add delegate to class (see extension)
class ToDoListViewController: SwipeTableViewController {

    // MARK: - IBOutlets

    // searchBar: Step 2/4 - add IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: - Properties

    // Because we are using Realm, we need to create a new instance of Realm.
    let realm = try! Realm()

    var todoItems: Results<Item>?

    // Optional: will initially be nil until we set it in perform(for segue:) with destinationVC.selectedCategory = categories[indexPath.row].
    // Once we set this property (from the prior VC), then we want to call loadItems() to update the tableview with the items related to the selectedCategory from the prior VC.
    // didSet specifies what should happen when variable gets set with a new value
    var selectedCategory: Category? {
        didSet{
            // all code in this body will be called once selectedCategory gets a value (!= nil)
            // when we call loadItems() we are confident that we already have a value for selected category
            // all we want to do is load up the items that fit the current selected category
            // We no longer need to call loadItems() in viewDidLoad b/c we now call it here when we set the value for selectedCategory.
            // Load new todoList items when we select any category.
            loadItems()
        }
    }


    // MARK: - Lifecycle

    // viewDidLoad gets called before the Navigation Controller gets called
    override func viewDidLoad() {
        super.viewDidLoad()

        // We want to get a path of where our current data is being stored.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        tableView.separatorStyle = .none



    }

    // viewDidLoad gets called before the Navigation Controller gets called
    override func viewWillAppear(_ animated: Bool) {

        // When code is not inside an if-let block, then it is safer to use a ? (rather than a !).
        title = selectedCategory?.name

        guard let colorHex = selectedCategory?.color else { fatalError("viewWillAppear: colorHex")}

        updateNavBar(withHexCode: "1D9BF6")
    }

    override func viewWillDisappear(_ animated: Bool) {
        // don't carry over colors, return back to original color

        updateNavBar(withHexCode: "1D9BF6")
    }

    // MARK: - Nav Bar Setup Methods

    func updateNavBar(withHexCode colorHexCode: String) {

        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }

        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError("viewWillAppear: navBarColor")}

        navBar.barTintColor = navBarColor

        // ConstrastColorOf requires a non-optional type UIColor.
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)

        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]

        searchBar.barTintColor = navBarColor
    }

    // MARK: - DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // link to Super Class's cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        // Optional binding (if let) for todoItems
        // reduce clutter of repeating itemArray[indexPath.row]
        if let item = todoItems?[indexPath.row] {

            // itemArray[indexPath.row] is going to return an item object
            // We want to tap into its title property in order to display the 'title' of each object
            cell.textLabel?.text = item.title

            // currently on row 5
            // there's a total of 10 items in todoItems
            // OK to Force Unwrap todoItems because we checked if todoItems is not nil above and it will only enter this block if not nil.
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {

                // .darken returns an optional
                cell.backgroundColor = color
                // change contrasting color text
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }


            // use ternary operator to cut down code
            // value = condition ? valueIfTrue : valueIfFalse
            // Set the cell's accessoryType depending on whether the item.done is equal to true.
            // If it is true then set it to .checkmark, if it is false then set it to .none.
            cell.accessoryType = item.done ? .checkmark : .none

        } else {
            // If there are no todoItems in todoItems?[indexPath.row]
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Tells the delegate which is this class, ToDoListViewController

        // UPDATE (U in CRUD)
        // If we select any of the cells then we grab a reference to the 'item' property at the selected indexPath row.
        if let item = todoItems?[indexPath.row] {
            // if not nil then we can access this item object
            do {
                // calling 'realm.write' will try to update our Realm database with whatever is inside the block of code below.
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }

        // After update, reload table view in order to call the method 'cellForRowAt indexPath' to update the cells based on the done property (checkmark).
        tableView.reloadData()

        tableView.deselectRow(at: indexPath, animated: true)
    }




    // MARK: - IBAction

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        // create any local variables that will be accessable to all properties and methods inside this IBAction
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user clicks the add item button on the UIAlert

            // ADD new items
            // create a new item that is of the class Item
            // We can specify the context of where this item is going to exist (which is going to be the viewContext of the persistentContainer in the appDelegate).
            // But inside this VC, we need to create an object of AppDelegate so that we can access its properties (We don't want the class, we want to create an object of the class). We do this by creating a singleton above called 'context'.

            // IMPORTANT: At the point where we create a new item, we need to specify its parent category (see code below)

            // Unwrapp self.selectedCategory
            if let currentCategory = self.selectedCategory {

                // realm.write can throw an error, so put it inside a do-try-catch block
                do {
                    // commit to realm database
                    try self.realm.write {
                        // Initialize newItem
                        let newItem = Item()
                        // set the title property to textField.text (the done property is set to false by default).
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()

                        // IMPORTANT. Instead of setting the newItem's parentCategory here, we are going to go the other direction, we are going to append the newItem to the list of Items of the currentCategory.
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }

            // After we have written the new data to our realm, we need to reload tableView with the new item.
            self.tableView.reloadData()

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


    // How is our TodoListViewController loading up all of the items in the table view?
    // 1. The items come from the itemArray
    // 2. The itemArry comes from the loadItems()
    // 3. The loadItems() fetches all of the NSManagedObjects that belong in the <Item> Entity.
    // 4. But in order to only load the items that have the parent category matching the selectedCategory, we need to (1) query our database and we need to (2) filter our results.
    // 5. We need to create a predicate that is an NSPredicate and initialize it with the formt that the parent category of all of the items that we want back must have its .name property matching (MATCHES %@) the current selectedCategory!.name.
    // 6. Then we need to add this predicate to the request (request.predicate = predicate).
    // 7. Add another parameter to the loadItems() method, called predicate which is a search query that we want to make in order to load up our items. It will be of data type NSPredicate.
    // Method with Default Value listed inside loadItems(): = Item.fetchRequest() in case not parameter passed in (see viewDidLoad).

    func loadItems() {
        // R of CRUD = READ. Fetching items is "READ"

        // Looks at the current selectedCategory and pulls out the items, sorted by the title in ascending order.
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }

    // MARK: - Delete Data From Swipe

    // Method created in Super Class. 
    override func updateModel(at indexPath: IndexPath) {

        // Because 'categories' is optional, we need to safely unwrap it.
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }

}

// MARK: - Search Bar Delegate Methods

extension ToDoListViewController: UISearchBarDelegate {

    // searchBar: Step 4/4 - add delegate methods
    // This method will be triggered once the user taps the search button on the search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        print("Anything?")

        // Filter todoList items based on a predicate that states the items to display must CONTAIN a title text entered in teh searchBar.text. Also, sort by "dateCreated". %@ == searchBar.text!.
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
        print("did we reload tableView?")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // every single letter is going to trigger this delegate method
        if searchBar.text?.count == 0 {
            print("Anything here too?")
            // which has a default request that fetches all of the items from the persitence store
            loadItems()

            DispatchQueue.main.async {
                // tell searchBar to resignFirstResponder
                searchBar.resignFirstResponder()
            }
        }
    }

}

