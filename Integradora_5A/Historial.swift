//
//  Historial.swift
//  Integradora_5A
//
//  Created by imac on 15/04/24.
//

import UIKit

class Historial: NSObject {
    var id: Int
    var id_bebe: Int
    var diagnostico: String
    var medicamentos: String
    var created_at: String
    
    init(id: Int, id_bebe: Int, diagnostico: String, medicamentos: String, created_at: String) {
        self.id = id
        self.id_bebe = id_bebe
        self.diagnostico = diagnostico
        self.medicamentos = medicamentos
        self.created_at = created_at
    }
   
}
