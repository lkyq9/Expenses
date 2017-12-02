//
//  ExpensesViewController.swift
//  Expenses
//
//  Created by Tech Innovator on 11/30/17.
//  Copyright © 2017 Tech Innovator. All rights reserved.
//

import UIKit
import CoreData

class ExpensesViewController: UIViewController {
    
    @IBOutlet weak var expensesTableView: UITableView!
    
    let dateFormatter = DateFormatter()
    
    var expense = [Expense]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.timeStyle = .long
        dateFormatter.dateStyle = .long
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        do{
            
            expense = try managedContext.fetch(fetchRequest)
         
            expensesTableView.reloadData()
        }catch{
            print("Fetch could not be performed")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewExpense(_ sender: Any) {
        performSegue(withIdentifier: "showExpense", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        guard let destination = segue.destination as? SingleExpenseViewController,
            let selectedRow = self.expensesTableView.indexPathForSelectedRow?.row else{
                return
        }
        
        destination.exisitingExpense = expense[selectedRow]
    }

    func deleteExpense(at indexPath: IndexPath){
        let expenses = expense[indexPath.row]
        
        if let managedContext = expenses.managedObjectContext{
            
            managedContext.delete(expenses)
            
            do{
                try managedContext.save()
                
                self.expense.remove(at: indexPath.row)
                
                expensesTableView.deleteRows(at: [indexPath], with: .automatic)
                
            }catch{
                print("Delete failed")
                
                expensesTableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension ExpensesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expense.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expensesTableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        
        let expenses = expense[indexPath.row]
        
        cell.textLabel?.text = expenses.name
        
        if let date = expenses.date{
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            deleteExpense(at: indexPath)
        }
    }
    
}

extension ExpensesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showExpense", sender: self)
    }
}
