//
//  TableViewCell.swift
//  Relic
//
//  Created by Didem Yakici on 06/11/2020.
//  Copyright © 2020 Didem Yakici. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    var task: Task? {
        didSet {
            self.textLabel?.text = task?.title
            self.detailTextLabel?.text = task?.description
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
