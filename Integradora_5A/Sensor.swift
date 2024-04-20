//
//  Sensor.swift
//  Integradora_5A
//
//  Created by imac on 20/04/24.
//

import UIKit

class Sensor: NSObject {
        let id: String
        let name: String
        let unit: String
        let value: Double

        init(id: String, name: String, unit: String, value: Double) {
            self.id = id
            self.name = name
            self.unit = unit
            self.value = value
        }
    }

