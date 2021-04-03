//
//  NewListViewController.swift
//  Relic
//
//  Created by Didem Yakici on 11/12/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import UIKit

protocol ListOperationDelegate {
    func listAdded(list: List)
    func listUpdated(list: List)
}

class ListEditorViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var goalTextField: UITextField!
    
    var delegate: ListOperationDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: is not implemented")
    }
    
    init?(delegate: ListOperationDelegate?, coder: NSCoder) {
        super.init(coder: coder)
        self.title = title
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func editList(_ sender: Any) {
        guard let m_goal = goalTextField.text, let name = titleTextField.text else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let list = List(title: name, goal: m_goal)
        delegate?.listAdded(list: list)
    }
    
}
