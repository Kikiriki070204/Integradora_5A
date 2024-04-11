//
//  Bebe.swift
//  Integradora_5A
//
//  Created by imac on 10/04/24.
//

import UIKit

class Bebe: NSObject {
    var nombre: String
    var apellido: String
    var sexo: String
    var fecha_nacimiento: Date
    var edad: Int
    var peso: Double
    var id_estado: Int
    var id_incubadora: Int
    
    init(nombre: String, apellido: String, sexo: String, fecha_nacimiento: Date, edad: Int, peso: Double, id_estado: Int, id_incubadora: Int) {
        self.nombre = nombre
        self.apellido = apellido
        self.sexo = sexo
        self.fecha_nacimiento = fecha_nacimiento
        self.edad = edad
        self.peso = peso
        self.id_estado = id_estado
        self.id_incubadora = id_incubadora
    }
    
}

