//
//  Contacto.swift
//  Integradora_5A
//
//  Created by imac on 15/04/24.
//

import UIKit

class Contacto: NSObject {
    var id: Int
    var nombre: String
    var apellido: String
    var telefono: String
    var email: String
    
    init(id: Int, nombre: String, apellido: String, telefono: String, email: String) {
        self.id = id
        self.nombre = nombre
        self.apellido = apellido
        self.telefono = telefono
        self.email = email
    }
}
