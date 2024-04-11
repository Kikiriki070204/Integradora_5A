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
    var access_token: String

    //var rememberMe: Bool
    
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
        access_token = ""
        //rememberMe = false
    }
    static func sharedData()->Usuario {
        if usuario == nil {
            usuario = Usuario.init()
        }
        
        return usuario
    }
    
    func save() {
           let userDefaults = UserDefaults.standard
        userDefaults.set(id, forKey: "userId")
        userDefaults.set(name, forKey: "name")
        userDefaults.set(email, forKey: "email")
        userDefaults.set(password, forKey: "password")
        userDefaults.set(is_active, forKey: "is_active")
        userDefaults.set(id_rol, forKey: "id_rol")
        userDefaults.set(id_hospital, forKey: "id_hospital")
        userDefaults.set(access_token, forKey: "access_token")
   
        //userDefaults.set(rememberMe, forKey: "rememberMe")
        userDefaults.synchronize()
       }
       
       func load() {
           let userDefaults = UserDefaults.standard
           id = userDefaults.integer(forKey: "userId")
           name = userDefaults.string(forKey: "name") ?? ""
           email = userDefaults.string(forKey: "email") ?? ""
           password = userDefaults.string(forKey: "password") ?? ""
           is_active = userDefaults.bool(forKey: "is_active")
           id_rol = userDefaults.integer(forKey: "id_rol")
           id_hospital = userDefaults.integer(forKey: "id_hospital")
           access_token = userDefaults.string(forKey: "access_token") ?? ""
           //rememberMe = userDefaults.bool(forKey: "rememberMe")
       }
    

}
