//
//  Item.swift
//  CopiPasta
//
//  Created by Сергей Лукичев on 20.10.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
