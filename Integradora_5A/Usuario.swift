//
//  Usuario.swift
//  Integradora_5A
//
//  Created by imac on 02/04/24.
//

import UIKit

class Usuario: NSObject {
    
    var id: Int
    var name: String
    var lastname: String
    var email: String
    var password: String
    var is_active: Bool
    var id_rol: Int
    var id_hospital: Int
    
    static var usuario: Usuario!
    
    override init() {
        id = 0
        name = ""
        lastname = ""
        email = ""
        password = ""
        is_active = false
        id_rol = 5
        id_hospital = 1
    }
    static func sharedData()->Usuario {
        if usuario == nil {
            usuario = Usuario.init()
        }
        
        return usuario
    }
    

}
