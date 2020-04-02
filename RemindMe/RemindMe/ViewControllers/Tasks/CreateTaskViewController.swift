//
//  CreateTaskViewController.swift
//  RemindMe
//
//  Created by Xcode User on 2020-03-28.
//  Copyright © 2020 BBQS. All rights reserved.
//

import UIKit

class CreateTaskViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tfTitle : UITextField!
    @IBOutlet var sgmPriority : UISegmentedControl!
    @IBOutlet var swStatus : UISwitch!
    @IBOutlet var lbStatus : UILabel!
    @IBOutlet var btnNote : UIButton!
    
    @IBOutlet var dpDeadline :  UIDatePicker!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch : UITouch = touches.first!
        let touchPoint : CGPoint = touch.location(in: self.view!)
        
        let noteFrame : CGRect = btnNote.frame
        
        if noteFrame.contains(touchPoint) {
            let mainDelegate = UIApplication.shared.delegate as! AppDelegate
            var currentUser = mainDelegate.currentUser
            
            //TODO: Update the task
            var currentTask : Task? = mainDelegate.currentTask
            if currentTask?.note == nil {
                currentTask = Task(user_id: currentUser!.id!, title: "Testing Create Note from Create Task", status: true, priority: 0, taskDueDate: "04-01-2020 15:30", daysInAdvance: 3, note: nil)
                mainDelegate.currentTask = currentTask
                performSegue(withIdentifier: "CreateTaskToCreateNoteSegue", sender: self)
            } else {
                currentTask!.title = "Testing Edit Note from Create Task"
                currentTask!.priority = 1
                currentTask!.taskDueDate = "04-01-2020 16:30"
                currentTask!.daysInAdvance = 2
                performSegue(withIdentifier: "CreateTaskToEditNoteSegue", sender: self)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var currentTask = mainDelegate.currentTask
        
        // Set label for note
        if currentTask?.note == nil {
            btnNote.titleLabel!.text = "Add Note"
        } else {
            var tempNote = mainDelegate.currentTask!.note
            btnNote.titleLabel!.text = tempNote!.content
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let mainDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //TODO: Update Task fields
        var currentTask = mainDelegate.currentTask
        
        if currentTask != nil {
            btnNote.titleLabel!.text = currentTask!.note?.content
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
