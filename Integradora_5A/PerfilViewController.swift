//
//  PerfilViewController.swift
//  Integradora_5A
//
//  Created by imac on 02/04/24.
//

import UIKit

class PerfilViewController: UIViewController {

    var hasErrors = true
    var usuario =  Usuario.sharedData()
    @IBOutlet weak var btnGuardar: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var Errores_lbl: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txfApellidos: UITextField!
    @IBOutlet weak var txfNombre: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
        print("ID: \(usuario.id)")
        txfNombre.text = usuario.name
        txfApellidos.text = usuario.lastname
        lblEmail.text = usuario.email
        Errores_lbl.isHidden = true
        
        txfNombre.addTarget(self, action: #selector(habilitarEditar(_:)), for: .editingDidBegin)
        txfApellidos.addTarget(self, action: #selector(habilitarEditar(_:)), for: .editingDidBegin)
    }
    
    @objc func habilitarEditar(_ sender: Any) {
        btnGuardar.isEnabled = true
    }
    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }
    
    
    func editarDatos()
    {

        let idUser = usuario.id
        print(idUser)
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/user/update/\(idUser)")!
        let token = usuario.access_token
        print(token)
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        
        
        let requestBody: [String: Any] = [
            "name": txfNombre.text!,
            "last_name": txfApellidos.text!
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("Error al convertir el cuerpo del request a JSON: \(error)")
            return
        }
          
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en el request: \(error)")
                self.hasErrors = true
                return
            }
              
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No se recibió una respuesta HTTP válida")
                
                self.hasErrors = true
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("Código de estado HTTP recibido: \(statusCode)")
            
            if statusCode == 200 {
                self.showSuccess(message: "Editado correctamente")
                
                DispatchQueue.main.async {
                    
                   print(requestBody)
                    if let data = data,
                       let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let signedRoute = jsonDict["url"] as? String {
                        self.hasErrors = false
                    }
                }
            } else if statusCode == 400 {
                if let data = data {
                    do {
                        print(response)
                        let errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let errors = errorJSON?["errors"] as? [String: Any],
                           let emailErrors = errors["email"] as? [String],
                           let errorMessage = emailErrors.first {
                            if errorMessage.contains("taken") {
                              
                                return
                            }
                        }
                    } catch {
                        print("Error al procesar el JSON de error: \(error)")
                    }
                }
                self.showError(message: "Error en los datos. No se pudo editar")
                self.hasErrors = true
            } else {
                print("Error en la solicitud: Código de estado HTTP \(statusCode)")
                self.hasErrors = true
            }
        }
        
        task.resume()
    }
    
    func showSuccess(message: String) {
            DispatchQueue.main.async {
                self.Errores_lbl.isHidden = false
                self.Errores_lbl.textColor = .green
                self.Errores_lbl.text = message
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.Errores_lbl.isHidden = true
                }
            }
    }
    
    func showError(message: String) {
            DispatchQueue.main.async {
                self.Errores_lbl.isHidden = false
                self.Errores_lbl.textColor = .red
                self.Errores_lbl.text = message
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.Errores_lbl.isHidden = true
                }
            }
    }
    
    func logOut(){
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/auth/logout")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "POST"
        do {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
        print("Error al convertir el cuerpo del request a JSON: \(error)")
        return
        }
      
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error en el request: \(error)")

            return
        }
          
        guard let httpResponse = response as? HTTPURLResponse else {
            print("No se recibió una respuesta HTTP válida")
            
            return
        }
        
        let statusCode = httpResponse.statusCode
        print("Código de estado HTTP recibido: \(statusCode)")
        
        if statusCode == 200 {
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "sgLogOut", sender: self)
                    Usuario()
            }
        } else if statusCode == 400 {
            if let data = data {
                do {
                    let errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let errors = errorJSON?["errors"] as? [String: Any],
                       let emailErrors = errors["email"] as? [String],
                       let errorMessage = emailErrors.first {
                        if errorMessage.contains("taken") {
                          
                            return
                        }
                    }
                } catch {
                    print("Error al procesar el JSON de error: \(error)")
                }
            }
           
        } else {
            print("Error en la solicitud: Código de estado HTTP \(statusCode)")
            print(response)
        
        }
    }
    
    task.resume()
}
    

    @IBAction func LogOut(_ sender: UIButton) {
        logOut()
    }
    
    @IBAction func guardaDatos(_ sender: UIButton) {
        editarDatos()
    }
   

}
