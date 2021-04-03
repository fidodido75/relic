//
//  ListSection.swift
//  Relic
//
//  Created by Didem Yakici on 10/12/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import Foundation

class ListSection: Hashable {
    
    var id = UUID()
    var title : String
    
    init(title: String) {
        self.title = title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ListSection, rhs: ListSection) -> Bool {
        lhs.id == rhs.id
    }
    
}
