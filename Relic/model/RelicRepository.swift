//
//  TaskRepository.swift
//  Relic
//
//  Created by Didem Yakici on 05/11/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class RelicRepository {

    let db = Firestore.firestore()

    //MARK: - Firestore Listeners

    var listListener: ListenerRegistration?
    var listsListener: ListenerRegistration?

    //MARK: - Cache
    
    var tasksCache = [Task]()
    var listsCache = [List]()
    
    //MARK: - List Methods

    func lists(from listsection: ListSection) -> [List]? {
        return self.listsCache
    }

    func add(list: List, to listSection: ListSection) {
        let dic = ["title" : list.title,
                   "goal": list.goal ?? ""] as [String : Any]

        var ref: DocumentReference? = nil
        if let userId = Auth.auth().currentUser?.uid {
            ref = db.collection("users")
                .document(userId)
                .collection("lists")
                .addDocument(data: dic) { error in
                    if let err = error {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID))")
                    }
                }
            }
    }
    
    func update(list: List) {
        guard let listId = list.id else {
            return
        }

        let dict = ["title" : list.title,
                    "goal": list.goal ?? ""] as [String : Any]

        if let userId = Auth.auth().currentUser?.uid {

            let docRef = db.collection("users")
                .document(userId)
                .collection("lists")
                .document(listId)

            docRef.setData(dict) { (error) in
                if let err = error {
                    print("Error updating list: \(err)")
                } else {
                    print("Document succesfully updated")
                }

            }
        }

    }

    func delete(list: List) {
        guard let listId = list.id else {
            return
        }

        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users")
                .document(userId)
                .collection("lists").document(listId)

            docRef.delete { error in
                if let err = error {
                    print("Error updating list: \(err)")
                } else {
                    print("Document succesfully updated")
                }
            }
        }
    }
    
    func registerListsListener(handler:@escaping (([List]) -> (Void))) {

        if let userId = Auth.auth().currentUser?.uid {
            self.listsListener = db.collection("users")
                .document(userId)
                .collection("lists")
                .addSnapshotListener { (querySnapshot, error) in

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                DispatchQueue.main.async {

                    let lists = documents.compactMap { queryDocumentSnapshot -> List? in
                        var list: List?

                        do {
                            list = try queryDocumentSnapshot.data(as: List.self)
                        } catch {
                            print("Unexpected error: \(error).")
                        }

                        return list
                    }

                    self.listsCache = lists
                    handler(lists)

                }
            }
        }
    }

    func deregisterListsListener() {
        self.listsListener?.remove()
    }

    //MARK: - Task Methods

    func tasks(from section: ListSection) -> [Task]? {
        self.tasksCache
    }

    func add(task: Task, to section: ListSection, to list: List) {
        let dic = ["title" : task.title,
                   "description" : task.description,
                   "isCompleted": task.isComplete ?? false] as [String : Any]
        
        guard let listId = list.id else { return }

        var ref: DocumentReference? = nil
        if let userId = Auth.auth().currentUser?.uid {
            ref = db.collection("users")
                .document(userId)
                .collection("lists")
                .document(listId)
                .collection("tasks").addDocument(data: dic) { error in
                if let err = error {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID))")
                }
            }
        }

    }
    
    func update(task: Task, in list: List) {
        guard let docId = task.id,
              let listId = list.id else { return }

        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users")
                .document(userId)
                .collection("lists")
                .document(listId)
                .collection("tasks").document(docId)

            docRef.setData(["title" : task.title,
                            "description" : task.description,
                            "isCompleted": task.isComplete ?? false]) { (error) in
                if let err = error {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }

        }
    }

    func delete(task: Task, in list: List) {
        guard let docId = task.id,
              let listId = list.id else { return }

        if let userId = Auth.auth().currentUser?.uid {
            let docRef = db.collection("users")
                .document(userId)
                .collection("lists")
                .document(listId)
                .collection("tasks").document(docId)

            docRef.delete { (error) in
                if let err = error {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }

    }

    func deregisterListListener() {
        self.listListener?.remove()
    }

    func registerListener(list: List, handler: @escaping ([Task]) -> (Void)) {
        guard let listId = list.id else { return }

        if let userId = Auth.auth().currentUser?.uid {
            self.listListener = db.collection("users")
                .document(userId)
                .collection("lists")
                .document(listId)
                .collection("tasks").addSnapshotListener { (querySnapshot, error) in

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                DispatchQueue.main.async {

                    let tasks = documents.compactMap { queryDocumentSnapshot -> Task? in
                        var task: Task?
                        do {
                            task = try queryDocumentSnapshot.data(as: Task.self)
                        } catch {
                            print("Unexpected error: \(error).")
                        }

                        return task
                    }

                    self.tasksCache = tasks
                    handler(tasks)

                }
            }
        }

    }
    
}

