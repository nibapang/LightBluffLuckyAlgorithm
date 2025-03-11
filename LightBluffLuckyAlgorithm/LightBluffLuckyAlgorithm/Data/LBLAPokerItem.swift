//
//  PokerItem.swift
//  LightBluffLuckyAlgorithm
//
//  Created by jin fu on 2025/3/11.
//

import UIKit

enum LBLAPokerItem: String {
    case heart, diamond, club, spade
    
    var image: UIImage? {
        return UIImage(named: self.rawValue)
    }
    
    var isRed: Bool {
        return self == .heart || self == .diamond
    }
    
    static func random() -> LBLAPokerItem {
        return [LBLAPokerItem.heart, .diamond, .club, .spade].randomElement()!
    }
}
