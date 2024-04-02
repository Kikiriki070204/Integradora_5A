//
//  LogInViewController.swift
//  Integradora_5A
//
//  Created by imac on 25/03/24.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }
    
    @IBAction func iniciaSesion()
    {
        if validaCorreo(txtCorreo.text!) && txtPassword.text?.count == 8
        {
            //logica pa cuando inice sesion
        }
        else
        {
            let alerta = UIAlertController(title: "ERROR", message: "Debes proporcionar un correo y una contraseña válidos", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Aceptar", style: .default)
            alerta.addAction(ok)
            present(alerta, animated: true)
        }
    }
    
    func validaCorreo(_ correo:String) -> Bool
    {
        let expReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", expReg)
            
        return emailPred.evaluate(with: correo)
    }
    
    func apiCall(){
        let conexion =  URLSession(configuration: .default)

                let url = URL(string: "https://192.168.80.116:8000/api/auth/")!
    }

}
