//
//  MasterViewController.swift
//  pset5-2
//
//  Created by Ayanna Colden on 03/12/2016.
//  Copyright © 2016 Ayanna Colden. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    private let db = DatabaseHelper()
    
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        readList()
        tableView.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newList(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readList() {
        do {
            Lists.lists = try db!.readList()
        } catch {
            print("error showing todo lists")
        }
    }
    
    // Make alert to add new list.
    func newList(_ sender: Any) {
        let alert = UIAlertController(title: "New list", message: "Enter a list name", preferredStyle: .alert)
        
        alert.addTextField {
            (textField) in textField.text = ""
            textField.placeholder = "Type a list name"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text!)")
            
            if textField.text == "" {
                print("Error: must fill in list name")
            }
            else {
                
                if Lists.lists.contains(textField.text!) {
                    print("Error: this list already exists")
                }
                else {
                    do {
                        try self.db!.createList(name: textField.text!)
                    } catch {
                        print("error creating list")
                    }
                    
                    self.readList()
                    self.tableView.reloadData()
                }
                textField.text = ""
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = Lists.lists[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.currentNameList = object
                controller.detailItem = object as AnyObject?
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Lists.lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        readList()
        let object = Lists.lists[indexPath.row]
        
        cell.textLabel!.text = object.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try db!.deleteList(name: Lists.lists[indexPath.row], id: try db!.getListId(name: Lists.lists[indexPath.row]))
            } catch {
                print("error deleting list")
            }
            readList()
            tableView.reloadData()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

