//
//  EditTaskViewController.swift
//  RemindMe
//
//  Created by Xcode User on 2020-03-29.
//  Copyright © 2020 BBQS. All rights reserved.
//

import UIKit

class EditTaskViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tfTitle : UITextField!
    @IBOutlet var sgmPriority : UISegmentedControl!
    @IBOutlet var swStatus : UISwitch!
    @IBOutlet var lbStatus : UILabel!
    @IBOutlet var btnNote : UIButton!
    @IBOutlet var btnUpdate : UIButton!
    @IBOutlet var btnDelete : UIButton!
    
    @IBOutlet var dpDeadline :  UIDatePicker!
    
    @IBAction func btnDeleteClicked(sender: UIButton) {
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        var currentTask = mainDelegate.currentTask
        
        let alert = UIAlertController(title: "Confirmation", message: "Do you want to delete the task?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
            (action) in
            
            let returnCode = mainDelegate.deleteTask(id: currentTask!.id!)
            
            var title : String = ""
            var message : String = ""
            var action = UIAlertAction()
            
            if returnCode == true {
                // Successfully delete task
                title = "Successfully"
                message = "Deleted"
                action = UIAlertAction(title: "OK", style: .default) {
                    action in
                    self.performSegue(withIdentifier: "UnwindFromEditTaskToHomeVCSegue", sender: nil)
                }
            } else {
                // Delete task failed
                title = "Error"
                message = "Could not delete the task"
                action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            }
            
            var deleteAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            deleteAlert.addAction(action)
            
            self.present(deleteAlert, animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        self.present(alert, animated: true)
    }
    
    @IBAction func btnUpdateClicked(sender: UIButton) {
        if (tfTitle.text == "" || tfTitle.text == nil) {
            var alert = UIAlertController(title: "Warning", message: "Please enter required field(s)!", preferredStyle: .alert)
            var cancelAction  = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Confirmation", message: "Do you want to update the task?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) {
                (action) in
                
                let mainDelegate = UIApplication.shared.delegate as! AppDelegate
                var currentUser = mainDelegate.currentUser
                var currentTask : Task? = mainDelegate.currentTask

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                var date = dateFormatter.string(from: self.dpDeadline.date)
                
                currentTask!.title = self.tfTitle.text
                currentTask!.status = self.swStatus.isOn
                currentTask!.priority = self.sgmPriority.selectedSegmentIndex
                currentTask!.taskDueDate = date
                currentTask!.daysInAdvance = 2
                
                
                var title : String = ""
                var message : String = ""
                var action = UIAlertAction()
                
                var note = currentTask!.note
                var noteReturnCode : Bool = true
                
                if (note != nil) {
                    if (note!.id == nil) {
                        let note_id = mainDelegate.insertNote(note: note!)

                        if(note_id != nil) {
                            note!.id = note_id
                            noteReturnCode = true
                            currentTask!.note = note
                        } else {
                            noteReturnCode = false
                        }
                    } else {
                        if (note!.content == nil) {
                            noteReturnCode = mainDelegate.deleteNote(id: note!.id!)
                            currentTask!.note = nil
                        } else {
                            noteReturnCode = mainDelegate.updateNote(note: note!)
                        }
                    }
                }

                if noteReturnCode {
                    let taskReturnCode = mainDelegate.updateTask(task: currentTask!)
                    
                    if taskReturnCode {
                        title = "Successfully"
                        message = "Updated \(currentTask!.title!)"
                        action = UIAlertAction(title: "OK", style: .default) {
                            action in
                            self.performSegue(withIdentifier: "UnwindFromEditTaskToHomeVCSegue", sender: nil)
                        }
                    } else {
                        title = "Error"
                        message = "Could not update \(currentTask!.title!). Please try again!"
                        action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    }
                } else {
                    title = "Error"
                    message = "Could not update \(currentTask!.title!). Please try again!"
                    action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                }

                var updateAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                updateAlert.addAction(action)
                
                self.present(updateAlert, animated: true)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func btnNoteClicked(sender : UIButton) {
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        var currentUser = mainDelegate.currentUser
        var currentTask : Task? = mainDelegate.currentTask
        var note : Note?  =  currentTask?.note
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var date = dateFormatter.string(from: dpDeadline.date)
        
        currentTask!.title = self.tfTitle.text
        currentTask!.status = self.swStatus.isOn
        currentTask!.priority = self.sgmPriority.selectedSegmentIndex
        currentTask!.taskDueDate = date

        mainDelegate.currentTask = currentTask
        
        // Check if task contains a note
        if note?.content == nil {
            // Create new note
            performSegue(withIdentifier: "EditTaskToCreateNoteSegue", sender: self)
        } else {
            // Update the note
            performSegue(withIdentifier: "EditTaskToEditNoteSegue", sender: self)
        }
    }
    
    // Unwind from CreateNoteViewController
    @IBAction func unwindFromCreateNote(sender: UIStoryboardSegue) {}
    
    // Unwind form EditNoteViewController
    @IBAction func unwindFromEditNote(sender: UIStoryboardSegue) {}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Set original data of the task before loading the view
    override func viewWillAppear(_ animated: Bool) {
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        var currentTask = mainDelegate.currentTask
        
        tfTitle.text = currentTask!.title
        swStatus.isOn = currentTask!.status!
        if swStatus.isOn {
            lbStatus.text = "Active"
        } else {
            lbStatus.text = "Inactive"
        }
        sgmPriority.selectedSegmentIndex = currentTask!.priority!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let date = dateFormatter.date(from: currentTask!.taskDueDate!)
        dpDeadline.date = date!
        
        if currentTask!.note?.content == nil {
            btnNote.setTitle("Add Note", for: .normal)
        } else {
            var tempNote = mainDelegate.currentTask!.note
            btnNote.setTitle("\u{2022} \(tempNote!.content!)", for: .normal)
        }
    }
}
