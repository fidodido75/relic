//
//  ListViewController.swift
//  Relic
//
//  Created by Didem Yakici on 04/11/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let mainSection = ListSection(title: "Main")
    private lazy var dataSource = makeDataSource()
    private var currentTask: Task?

    private let cellReuseId = "TaskCell"
    private let repository = RelicRepository()

    var delegateList: ListOperationDelegate?
    var list: List
    var remoteConfiguration: ConfigurationRepository

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    init?(list: List, title: String,
          delegate: ListOperationDelegate?,
          configuration: ConfigurationRepository,
          coder: NSCoder) {
        self.list = list
        self.remoteConfiguration = configuration
        super.init(coder: coder)
        self.title = title
        self.delegateList = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {

        self.repository.registerListener(list: self.list) { (tasks) -> (Void) in

            var snapshot = NSDiffableDataSourceSnapshot<ListSection, Task>()
            snapshot.appendSections([self.mainSection])
            snapshot.appendItems(tasks)
            self.dataSource.apply(snapshot, animatingDifferences: true)

        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.repository.deregisterListListener()
    }

    @IBSegueAction func makeNewTaskViewController(_ coder: NSCoder) -> TaskEditorViewController? {
        let shouldDisableControls = (self.repository.tasksCache.count >= remoteConfiguration.maxNumTasks())

        return TaskEditorViewController(delegate: self, shouldDisableControls: shouldDisableControls,  coder: coder)
    }
    
    
    @IBSegueAction func makeUpdateTaskViewController(_ coder: NSCoder) -> TaskEditorViewController? {
    
        guard let task = currentTask else { return nil }
        
        return TaskEditorViewController(task: task, delegate: self, coder: coder)
    }
    
    
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let task = self.dataSource.itemIdentifier(for: indexPath) else { return nil }        
        self.currentTask = task
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Data Sources
extension ListViewController {
    
    func makeDataSource() -> UITableViewDiffableDataSource<ListSection, Task> {
        let dataSource = UITableViewDiffableDataSource<ListSection, Task>(tableView: tableView) { (tableView, indexPath, task) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseId, for: indexPath) as! TaskTableViewCell
            if let tasks = self.repository.tasks(from: self.mainSection) {
                cell.task = tasks[indexPath.row]
            }
            return cell
        }
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {        
        var snapshot = NSDiffableDataSourceSnapshot<ListSection, Task>()
        snapshot.appendSections([mainSection])
        
        guard let tasks = self.repository.tasks(from: mainSection) else {
            return
        }
        
        snapshot.appendItems(tasks, toSection: mainSection)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

extension ListViewController: TaskOperationDelegate {

    func taskAdded(task: Task) {
        repository.add(task: task, to: mainSection, to: list)
        self.dismiss(animated: true, completion: nil)
        self.currentTask = nil
    }

    func taskUpdated(task: Task) {

        if task.isComplete ?? false {
            repository.delete(task: task, in: list)
        } else {
            repository.update(task: task, in: list)
        }

        self.navigationController?.popViewController(animated: true)
        self.currentTask = nil
    }

}
