//
//  VerificarViewController.swift
//  Integradora_5A
//
//  Created by imac on 04/04/24.
//

import UIKit

class VerificarViewController: UIViewController {
    var email: String!
    var password: String!
    let usuario = Usuario.sharedData()

    @IBOutlet weak var Errores_lbl: UILabel!
    @IBOutlet weak var Code: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    print("Correo: \(email!)\nContraseña: \(password!)")
        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
    }
    
    func showError(message: String) {
        Errores_lbl.isHidden = false
        Errores_lbl.textColor = .red
        Errores_lbl.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.Errores_lbl.isHidden = true
        }
    }
    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }
    
    @IBAction func Verify(_ sender: UIButton) {
        guard let codigo = Code.text, !codigo.isEmpty else {
              showError(message: "Por favor, ingrese el código.")
              return
          }
        if Code.text?.count == 6
        {
            verificar()
        }
        else {
            showError(message: "Por favor, ingrese el código.")
        }
    }
    
    func verificar()
    {
        let url = URLManager.sharedInstance.getURL(path: "/api/auth/verifyCode")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.httpMethod = "POST"
        
        let correo = email
        let contra = password
        let code = Code.text
        
        let requestBody: [String: Any] = [
            "email": correo,
            "password": contra,
            "codigo": code
        ]
        
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("Error de JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error en el request: \(error)")
                return
            }
            
            guard let data = data else {
                print("No se recibió data en la respuesta")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP recibido: \(httpResponse.statusCode)")
                
                do {
                            let responseJSON = try JSONSerialization.jsonObject(with: data, options: [])
                            print("Respuesta JSON: \(responseJSON)")
                            
                            if httpResponse.statusCode == 200 {
                                if let jsonDict = responseJSON as? [String: Any],
                                   let token = jsonDict["access_token"] as? String
                                {
                                    DispatchQueue.main.async {
                                        self.usuario.access_token = token
                                        //print("USER DATA: \(self.usuario.access_token)")
                                        if self.usuario.id_rol != 5
                                        {
                                            self.performSegue(withIdentifier: "sgTab", sender: self)
                                            
                                            self.usuario.save()
                                        }
                                        else
                                        {
                                            self.performSegue(withIdentifier: "sg401", sender: self)
                                            print(self.usuario.id_rol)
                                        }
                                            
                                    }
                                }
                                    
                            } else {
                                if httpResponse.statusCode == 401 {
                                    DispatchQueue.main.async {
                                        self.showError(message: "Credenciales incorrectas")
                                    }
                                } else if httpResponse.statusCode == 404 {
                                    DispatchQueue.main.async {
                                        self.showError(message: "Usuario no encontrado")
                                    }
                                } else if httpResponse.statusCode == 400 {
                                    DispatchQueue.main.async {
                                        self.showError(message: "Código incorrecto")
                                    }
                                } else {
                                    if let jsonDict = responseJSON as? [String: Any],
                                       let message = jsonDict["message"] as? String {
                                        DispatchQueue.main.async {
                                            let error = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                                            let ok = UIAlertAction(title: "Aceptar", style: .default)
                                            error.addAction(ok)
                                            self.present(error, animated: true)
                                        }
                                    }
                                }
                            }
                } catch {
                    print("Error al convertir la respuesta a JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
