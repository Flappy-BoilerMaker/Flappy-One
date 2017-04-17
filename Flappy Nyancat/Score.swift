//
//  Score.swift
//  Flappy Nyancat
//
//  Created by Bconsatnt on 16/04/2017.
//  Copyright © 2017 Heng Li. All rights reserved.
//

import UIKit

class Score: NSObject {
    var name: String?
    var score: Int?
    init(player: String, score: Int) {
        self.name = player
        self.score = score
    }
}
