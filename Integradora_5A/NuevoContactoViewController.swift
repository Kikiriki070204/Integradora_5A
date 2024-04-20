//
//  NuevoContactoViewController.swift
//  Integradora_5A
//
//  Created by imac on 19/04/24.
//

import UIKit

class NuevoContactoViewController: UIViewController {

    var idbebe: Int!
    var hasErrors = true
    let usuario = Usuario.sharedData()
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfTelefono: UITextField!
    @IBOutlet weak var Errores_lbl: UILabel!
    @IBOutlet weak var txfApellido: UITextField!
    @IBOutlet weak var txfNombre: UITextField!
    @IBOutlet weak var btnCrear: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Errores_lbl.isHidden = true
        print("ID DEL BEBE: \(idbebe!)")
        
   
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }


    @IBAction func Crear(_ sender: UIButton) {
        registrarContacto()
    }
    
    func registrarContacto() {
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/contactoFamiliar/create")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "POST"
        
        let name = txfNombre.text!
        let lastname = txfApellido.text!
        let email = txfEmail.text!
        let telefono = txfTelefono.text!
        let bebe = idbebe!
        
        let requestBody: [String: Any] = [
            "nombre": name,
            "apellido": lastname,
            "email": email,
            "telefono": telefono,
            "id_bebe": bebe
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
            
            if statusCode == 201 {
                self.showSuccess(message: "Paciente creado correctamente")
                
                DispatchQueue.main.async {
                    
                   print(requestBody)
                    self.performSegue(withIdentifier: "sgTabBebe2", sender: self)
                    if let data = data,
                       let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let signedRoute = jsonDict["url"] as? String {
                        self.hasErrors = false
                    }
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
                self.showError(message: "Error en los datos. No se pudo editar")
                self.hasErrors = true
            } else {
                print("Error en la solicitud: Código de estado HTTP \(statusCode)")
                print(response)
                self.hasErrors = true
            }
        }
        
        task.resume()
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
}
