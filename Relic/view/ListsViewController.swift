//
//  ListsViewController.swift
//  Relic
//
//  Created by Didem Yakici on 11/12/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import UIKit
import Firebase

class ListsViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!

    private let mainSection = ListSection(title: "Main")
    private lazy var dataSource = makeDataSource()
    private var currentList: List?

    private let cellReuseId = "ListCell"
    private let repository = RelicRepository()
    private lazy var configurationRepository = ConfigurationRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lists"
        configurationRepository.setup()
        configurationRepository.fetchConfig()

        listTableView.dataSource = dataSource
        listTableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        //We want to make sure that user is anonymously signed in.
        Auth.auth().signInAnonymously { (authResult, error) in

            if let err = error {
                print("Error: \(String(describing: err))")
                return
            }
            
            guard let user = authResult?.user else { return }

            self.repository.registerListsListener { lists in
                var snapshot = NSDiffableDataSourceSnapshot<ListSection, List>()
                snapshot.appendSections([self.mainSection])
                snapshot.appendItems(lists)
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {

    }

    @IBSegueAction func makeListEditorViewController(_ coder: NSCoder) -> ListEditorViewController? {
        return ListEditorViewController(delegate: self, coder: coder)
    }

    @IBSegueAction func makeListViewController(_ coder: NSCoder) -> ListViewController? {

        guard let list = currentList else {
            fatalError()
        }

        return ListViewController(list: list, title: list.title,
                                  delegate: self,
                                  configuration: self.configurationRepository,
                                  coder: coder)
    }

}

extension ListsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath)  -> IndexPath? {
        
        guard let list = self.dataSource.itemIdentifier(for: indexPath) else { return nil }        
        self.currentList = list
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension ListsViewController {
    
    func makeDataSource() -> UITableViewDiffableDataSource<ListSection, List> {
     
        let dataSource = UITableViewDiffableDataSource<ListSection, List>(tableView: listTableView) { (tableView, indexPath, task) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseId, for: indexPath) as UITableViewCell?
            if let lists = self.repository.lists(from: self.mainSection) {
                let list = lists[indexPath.row]
                cell?.textLabel!.text = list.title                
            }
            return cell
        }

        return dataSource
    }
    
    
    func applySnapshot(animatingDifferences: Bool = true) {

        var snapshot = NSDiffableDataSourceSnapshot<ListSection, List>()

        snapshot.appendSections([mainSection])
        
        guard let lists = self.repository.lists(from: mainSection) else {
            return
        }
        
        snapshot.appendItems(lists, toSection: mainSection)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
   
}

extension ListsViewController: ListOperationDelegate {
    func listAdded(list: List) {
        repository.add(list: list, to: mainSection)
        self.dismiss(animated: true, completion: nil)
        self.currentList = nil
    }

    func listUpdated(list: List) {
        repository.update(list: list)
        self.dismiss(animated: true, completion: nil)
        self.currentList = nil
    }
}
