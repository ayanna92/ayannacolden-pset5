//
//  DatabaseHelper.swift
//  pset5-2
//
//  Created by Ayanna Colden on 03/12/2016.
//  Copyright © 2016 Ayanna Colden. All rights reserved.
//

import Foundation
import SQLite

struct Lists {
    static var lists = [String]()
    static var currentList = [String]()
}

class DatabaseHelper {
    
    // Tables for todo lists and todo items.
    private let todoList = Table("todoList")
    private let todoItem = Table("todoItem")
    
    private let id = Expression<Int64>("id")
    
    // TodoItem.
    private let listId = Expression<Int64>("listId")
    private let todo = Expression<String?>("todo")
    private let completed = Expression<Bool>("completed")
    
    // TodoList.
    private let nameList = Expression<String?>("nameList")
    
    private var db: Connection?
    
    init?() {
        do {
            try setupDatabase()
        } catch {
            print(error)
            return nil
        }
    }
    
    private func setupDatabase() throws {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            db = try Connection("\(path)/db.sqlite3")
            try createItemTable()
            try createListTable()
        } catch {
            throw error
        }
    }
    
    // Make tables.
    // Make todo item table.
    private func createItemTable() throws {
        
        do {
            try db!.run(todoItem.create(ifNotExists: true) {
                t in
                t.column(id, primaryKey: .autoincrement)
                t.column(listId)
                t.column(todo)
                t.column(completed)
            })
        } catch {
            throw error
        }
    }
    
    // Make todo list table.
    private func createListTable() throws {
        
        do {
            try db!.run(todoList.create(ifNotExists: true) {
                t in
                t.column(id, primaryKey: .autoincrement)
                t.column(nameList)
            })
        } catch {
            throw error
        }
    }
    
    // Create new row functions.
    // Create item.
    func createItem(todo: String, listId: Int64) throws {
        
        let insert = todoItem.insert(self.todo <- todo, self.listId <- listId, self.completed <- false)
        
        do {
            let rowId = try db!.run(insert)
            print("new item: \(rowId)")
        } catch {
            throw error
            
        }
    }
    
    // Create List.
    func createList(name: String) throws {
        
        let insert = todoList.insert(self.nameList <- name)
        
        do {
            let rowId = try db!.run(insert)
            print("new list: \(rowId)")
        } catch {
            throw error
            
        }
    }
    
    // Read functions.
    // Read todo items.
    func readItem(id: Int64) throws -> [String]{
        var array = [String]()
        
        do {
            
            for item in try db!.prepare(todoItem) {
                if item[listId] == id {
                    array.insert(item[todo]!, at: 0)
                }
            }
        } catch {
            throw error
        }
        
        return array
    }
    
    // Read todo list.
    func readList() throws -> [String]{
        var array = [String]()
        
        do {
            
            for item in try db!.prepare(todoList) {
                array.insert(item[nameList]!, at: 0)
            }
        } catch {
            throw error
        }
        
        return array
    }
    
    // Retrieve correct list id.
    func getListId(name: String) throws -> Int64 {
        
        var listId = Int64()
        
        do {
            for item in try db!.prepare(todoList) {
                if (item[nameList]! == name) {
                    listId = item[id]
                    break
                }
            }
        } catch {
            throw error
        }
        return listId
    }
    
    // Delete todo lists or items.
    // Delete todo items.
    func deleteItem(task: String, id: Int64) throws {
        let deletedRows = todoItem.filter(todo == task)
            
            .filter(listId == id)
        do {
            try db!.run(deletedRows.delete())
        } catch {
            throw error
        }
    }
    
    // Delete todo list.
    func deleteList(name: String, id: Int64) throws {
        
        // Delete all items.
        let deletedItems = todoItem.filter(listId == id)
        
        do {
            try db!.run(deletedItems.delete())
        } catch {
            throw error
        }
        
        // Delete list.
        let deletedList = todoList.filter(nameList == name)
        
        do {
            try db!.run(deletedList.delete())
            
        } catch {
            throw error
            
        }
    }
    
    // Check if item is completed or not.
    func isCompleted(task: String) throws -> Bool {
        let query = todoItem.select(completed)
            .filter(todo == task)
        
        do {
            var state = Bool()
            for user in try db!.prepare(query) {
                state = user[self.completed]
            }
            print("state is \(state)")
            return state
            
        } catch {
            throw error
        }
    }
    
    // Update status of item in row todoItem.
    func update(task: String, update: Bool) throws {
        let updateItem = todoItem.filter(todo == task)
        
        do {
            try db!.run(updateItem.update(completed <- update))
            print("update:\(try db!.run(updateItem.update(completed <- update)))")
        } catch {
            throw error
        }
    }
}
