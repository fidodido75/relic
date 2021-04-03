//
//  List.swift
//  Relic
//
//  Created by Didem Yakici on 09/12/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Diffable Data Source

struct List: Hashable, Identifiable, Codable {

    @DocumentID var id: String?
    var title: String
    var goal: String?
    
    init(title: String, goal: String?) {
        self.title = title
        self.goal = goal
    }
    
    static func ==(lhs: List, rhs: List) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
