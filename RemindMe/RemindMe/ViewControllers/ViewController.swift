//
//  ViewController.swift
//  RemindMe
//
//  Created by Xcode User on 2020-03-14.
//  Copyright © 2020 BBQS. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var segmentControl : UISegmentedControl!
    @IBOutlet var btnCreate : UIBarButtonItem!
    @IBOutlet var btnLogOut : UIBarButtonItem!
    @IBOutlet var tableView : UITableView!
    
    var indexPath : IndexPath?
    
    @IBAction func btnLogOutTriggered(sender: UIBarButtonItem) {
        // Cancel object selection
        if btnLogOut.title == "Cancel" {
            var cell = self.tableView.cellForRow(at: indexPath!)
            cell?.isSelected = false
            
            btnLogOut.title = "Log Out"
            btnCreate.title = "+"
            
            indexPath = nil
        } else {
            let mainDelegate = UIApplication.shared.delegate as! AppDelegate
            mainDelegate.logOut()
            
            
            let alertController = UIAlertController(title: "Warning", message: "Do you want to log out ?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "Confirm", style: .default)  { (_)-> Void in   self.performSegue(withIdentifier: "logOutSegue", sender: self) }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            
            present(alertController,animated: true)
        }
    }
    
    @IBAction func btnCreateTriggered(sender: UIBarButtonItem) {
        // Create new object
        if btnCreate.title == "+" {
            switch segmentControl.selectedSegmentIndex {
            case 0:
                performSegue(withIdentifier: "HomeToCreateDueDateSegue", sender: nil)
                break
            case 1:
                // Display Create New Task ViewController
                let mainDelegate = UIApplication.shared.delegate as! AppDelegate
                mainDelegate.currentTask = nil
                performSegue(withIdentifier: "HomeToCreateNewTaskSegue", sender: nil)
                break
            case 2:
                break
            default:
                break
            }
        } else {
            // Delete object
            let mainDelegate = UIApplication.shared.delegate as! AppDelegate
            var row = indexPath!.row
            
            var currentUser : User = mainDelegate.currentUser!
            
            switch segmentControl.selectedSegmentIndex {
            case 0:
                let duedates = mainDelegate.duedates
                var returnCode = mainDelegate.deleteDueDate(id: duedates[row].id!)
                
                if returnCode {
                    mainDelegate.getDueDatesByUserId(userId: currentUser.id!)
                    tableView.reloadData()
                }
                break
            case 1:
                // Delete selected task
                let alert = UIAlertController(title: "Confirmation", message: "Do you want to delete the task?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
                    (action) in
                    
                    //TODO: Change user id
                    var tasks = mainDelegate.getTasksByUser(user_id: currentUser.id!)
                    var task = tasks[row]
                    
                    let returnCode = mainDelegate.deleteTask(id: task.id!)
                    
                    var title : String = ""
                    var message : String = ""
                    var action = UIAlertAction()
                    
                    if returnCode == true {
                        // Successfully delete task
                        title = "Successfully"
                        message = "Deleted \(task.title!)"
                        action = UIAlertAction(title: "OK", style: .default) {
                            (action) in
                            self.tableView.reloadData()
                        }
                    } else {
                        // Delete task failed
                        title = "Error"
                        message = "Could not delete \(task.title!)"
                        action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    }
                    
                    var deleteAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    deleteAlert.addAction(action)
                    
                    self.present(deleteAlert, animated: true)
                }
                
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                
                self.present(alert, animated: true)
                break
            case 2:
                break
            default:
                break
            }
            
            self.btnCreate.title = "+"
            self.btnLogOut.title = "Log Out"
        }
    }
    
    @IBAction func segmentSelectValueChanged(sender:UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        var count : Int = 0
        
        var currentUser : User = mainDelegate.currentUser!
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            mainDelegate.getDueDatesByUserId(userId: currentUser.id!)
            let duedates = mainDelegate.duedates
            count = duedates.count
            break
        case 1:
            //TODO: Change UserId
            let tasks = mainDelegate.getTasksByUser(user_id: currentUser.id!)
            count = tasks.count
            break
        case 2:
            break
        default:
            break
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            height = 110
            break
        case 1:
            height = 95
            break
        case 2:
            break
        default:
            break
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DueDateCell ?? DueDateCell(style: .default,reuseIdentifier : "cell")
            
            let rowNum = indexPath.row
            (cell as! DueDateCell).primaryLabel.text = "Event: " + mainDelegate.duedates[rowNum].name!
            (cell as! DueDateCell).secondaryLabel.text = "Category: \(mainDelegate.duedates[rowNum].category!)"
            (cell as! DueDateCell).thirdLabel.text = "Sub Category: \(mainDelegate.duedates[rowNum].subCategory!)"
            (cell as! DueDateCell).fourthLabel.text = "Priority: " + mainDelegate.duedates[rowNum].priority!
            (cell as! DueDateCell).fifthLabel.text = "Due Date: " + mainDelegate.duedates[rowNum].date!
            
            cell.accessoryType = .disclosureIndicator
            break
        case 1:
            //TODO: Change UserId
            var tasks = mainDelegate.getTasksByUser(user_id: 1)
            
            cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TaskCell ?? TaskCell(style: .default, reuseIdentifier: "cell")
            
            // Populate cell
            let row = indexPath.row
            (cell as! TaskCell).lbTitle.text = tasks[row].title
            
            var priority : String = "Priority: "
            if tasks[row].priority == 0 {
                priority += "Low"
            } else if tasks[row].priority == 1 {
                priority += "Medium"
            } else {
                priority += "High"
            }
            (cell as! TaskCell).lbPriority.text = priority
            
            let dueDate = "Due date: \(tasks[row].taskDueDate!)"
            (cell as! TaskCell).lbTaskDueDate.text = dueDate

            break
        case 2:
            break
        default:
            break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            // Peofrm the segue to Edit the selected duedate
            
            let mainDelegate = UIApplication.shared.delegate as! AppDelegate
            var currentUser : User = mainDelegate.currentUser!
            mainDelegate.getDueDatesByUserId(userId: currentUser.id!)
            let duedates = mainDelegate.duedates
            
            let row = indexPath.row
            mainDelegate.currentDueDate = duedates[row]
            
            performSegue(withIdentifier: "HomeToEditDueDatesSegue", sender: nil)
            break
        case 1:
            let mainDelegate = UIApplication.shared.delegate as! AppDelegate
            let tasks = mainDelegate.getTasksByUser(user_id: 1)
            
            let row = indexPath.row
            mainDelegate.currentTask = tasks[row]
            
            performSegue(withIdentifier: "HomeToEditTaskSegue", sender: nil)
            break
        case 2:
            break
        default:
            break
        }
    }

    @IBAction func unwindToHomeVC(sender:UIStoryboardSegue){
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Long Press Gesture
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    // swiping functions
    //method:1
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //method:2 left to right
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // If user clicks Modify-> go to the corresponding Edit View
        let modify = UIContextualAction(style: .normal, title: "Modify") { (action, view, success) in
            
            switch self.segmentControl.selectedSegmentIndex
            {
            case 0:
                // Perform segue to go to EditDueDateVC
                break
            case 1:
                // Perform segue to go to EditTaskVC
                break
            case 2:
                // Perform segue to go to EditContactVC
                break
            default:
                break
            }
            success(true)
        }
        modify.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [modify])
    }
    
    // Swipe from right to left
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .normal, title: "Delete", handler: {
            action, index in
            
            let mainDelegate = UIApplication.shared.delegate as! AppDelegate
            let row = indexPath.row
            
            let currentUser : User = mainDelegate.currentUser!
            switch self.segmentControl.selectedSegmentIndex
            {
            case 0:
                // Delete the selected due date
                let alertController = UIAlertController(title: "Warning", message: "Do you want to delete the due date ?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: "Confirm", style: .default)  { (_)-> Void in
                    
                    let duedates = mainDelegate.duedates
                    let returnCode = mainDelegate.deleteDueDate(id: duedates[row].id!)
                    if returnCode
                    {
                        mainDelegate.getDueDatesByUserId(userId: currentUser.id!)
                        tableView.reloadData()
                    }}
                
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                
                    self.present(alertController,animated: true)
            
                break
            case 1:
                // Delete the selected task
                break
            case 2:
                // Delete the selected contact
                break
            default:
                break
            }

        })
        delete.backgroundColor = .red
        return [delete]
    }
    
    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)

            if let selectedIndexPath = tableView.indexPathForRow(at: touchPoint) {
                btnLogOut.title = "Cancel"
                btnCreate.title = "Delete"
                
                var cell = tableView.cellForRow(at: selectedIndexPath)
                cell?.isSelected = true
                //cell?.backgroundColor = UIColor.lightGray
                indexPath = selectedIndexPath
                
                print("Row \(selectedIndexPath.row)")
            }
        }
    }
}

