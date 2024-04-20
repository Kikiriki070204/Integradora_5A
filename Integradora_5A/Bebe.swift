//
//  Bebe.swift
//  Integradora_5A
//
//  Created by imac on 10/04/24.
//

import UIKit

class Bebe: NSObject {
    var id: Int
    var nombre: String
    var apellido: String
    var sexo: String
    var fecha_nacimiento: String
    var edad: Int
    var peso: Double
    var id_estado: Int
    var id_incubadora: Int
    var estado: String
    var hospital: String
    
    
    init(id: Int, nombre: String, apellido: String, sexo: String, fecha_nacimiento: String, edad: Int, peso: Double, id_estado: Int, id_incubadora: Int, estado: String, hospital: String) {
        self.id = id
        self.nombre = nombre
        self.apellido = apellido
        self.sexo = sexo
        self.fecha_nacimiento = fecha_nacimiento
        self.edad = edad
        self.peso = peso
        self.id_estado = id_estado
        self.id_incubadora = id_incubadora
        self.estado = estado
        self.hospital = hospital
        
    }
}

