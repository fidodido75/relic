//
//  Task.swift
//  Relic
//
//  Created by Didem Yakici on 03/11/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Task : Hashable, Identifiable, Codable {
    
    @DocumentID var id: String?
    var title : String
    var description : String
    var isComplete: Bool?
        
    init(title: String = "", description: String = "", completed: Bool = false) {
        self.title = title
        self.description = description
        self.isComplete = completed
    }

    static func ==(lhs:Task, rhs:Task) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
