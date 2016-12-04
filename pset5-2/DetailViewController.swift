//
//  DetailViewController.swift
//  pset5-2
//
//  Created by Ayanna Colden on 03/12/2016.
//  Copyright © 2016 Ayanna Colden. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var addItemText: UITextField!
    @IBOutlet weak var addItem: UIButton!
    @IBOutlet weak var listTitle: UILabel!
    
    var currentNameList = String()
    var currentIdList = Int64()
    var completed = [Bool]()
    var taskStatus = Bool()
    
    
    private let db = DatabaseHelper()

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        listTitle.text = "\(currentNameList)"
        
        do {
            currentIdList = try db!.getListId(name: currentNameList)
        } catch {
            print("error getting current list")
        }
        
        readItem(id: currentIdList)
        tableView.reloadData()
        
        addItemText.placeholder = "Add todo item"
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func readItem(id: Int64) {
        
        do {
            Lists.currentList = try db!.readItem(id: currentIdList)
        } catch {
            print("error reading todo items")
        }
    }
    
    // Add button code.
    @IBAction func createItem(_ sender: Any) {
        
        do {
            try db!.createItem(todo: addItemText.text!, listId: currentIdList)
            self.readItem(id: currentIdList)
        } catch {
            print("error adding todo item")
        }
        
        self.tableView.reloadData()
        
        print(Lists.currentList)
        
        addItemText.text = ""
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Lists.currentList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "detailCell") as! TableViewCell
        
        cell.itemLabel.text = Lists.currentList[indexPath.row]
        
        do {
            if try db!.isCompleted(task: Lists.currentList[indexPath.row]) {
                cell.accessoryType = .checkmark
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
            } else {
                cell.accessoryType = .none
            }
           
        } catch {
            print("error checking state")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        do {
            taskStatus = try db!.isCompleted(task: Lists.currentList[indexPath.row])
            print(taskStatus)
            try db!.update(task: Lists.currentList[indexPath.row], update: !taskStatus)
            taskStatus = try db!.isCompleted(task: Lists.currentList[indexPath.row])
            print(taskStatus)
            readItem(id: currentIdList)
        } catch {
            print("error checking state")
        }
        
        
        if taskStatus == true {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        tableView.reloadData()
        
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let item = Lists.currentList[indexPath.row]
            
            do {
                try db!.deleteItem(task: item, id: currentIdList)
            } catch {
                print("error deleting todo item")
            }
            
            readItem(id: currentIdList)
            tableView.reloadData()
        }
    }
    
    


}

