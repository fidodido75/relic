//
//  DetailViewController.swift
//  Relic
//
//  Created by Didem Yakici on 04/11/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import UIKit

protocol TaskOperationDelegate {
    func taskAdded(task: Task)
    func taskUpdated(task: Task)
}

/// Create and Adds a new Task
class TaskEditorViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var isCompletedSwitch: UISwitch!
    
    var delegate: TaskOperationDelegate?
    var task: Task?
    let shouldDisableControls: Bool
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    init?(task: Task? = nil, delegate: TaskOperationDelegate?, shouldDisableControls: Bool = false, coder: NSCoder) {
        self.task = task
        self.shouldDisableControls = shouldDisableControls
        super.init(coder: coder)
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldDisableControls {
            //self.button.isEnabled = false
            self.titleTextField.isEnabled = false
            self.descriptionTextField.isEnabled = false
            self.button.setTitle("Max Limit Reached", for: .normal)
        } else {
            if let task = task {
                self.button.setTitle("Update", for: .normal)
                self.titleTextField.text = task.title
                self.descriptionTextField.text = task.description
                self.isCompletedSwitch.isOn = task.isComplete ?? false
            } else {
                self.button.setTitle("Add", for: .normal)
            }
        }
    }

    @IBAction func switchTriggered(_ sender: Any) {
        let button = sender as! UISwitch
        if button.isOn {
            self.task?.isComplete = true
        } else {
            self.task?.isComplete = false
        }
    }

    @IBAction func editTask(_ sender: Any) {

        if let m_title =  titleTextField.text,
           let m_subtitle = descriptionTextField.text,
           !m_title.isEmpty && !m_subtitle.isEmpty {
            var task = Task(title: m_title, description: m_subtitle, completed: isCompletedSwitch.isOn)
            if let currentTask = self.task {
                task.id = currentTask.id
                delegate?.taskUpdated(task: task)
            } else {
                delegate?.taskAdded(task: task)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }

    }
    
}

