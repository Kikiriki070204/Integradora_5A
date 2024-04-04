//
//  LogInViewController.swift
//  Integradora_5A
//
//  Created by imac on 25/03/24.
//

import UIKit

class LogInViewController: UIViewController {
    var hasErrors = true
    let usuario = Usuario.sharedData()
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    var maxLenghts = [UITextField: Int]()
    
    @IBOutlet weak var Errores_lbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
    }
    
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let vc = segue.destination as! VerificarViewController
        
        vc.email = txtCorreo.text
        vc.password = txtPassword.text
        
    }
    */
    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }
    
    
    
    func validaCorreo(_ correo:String) -> Bool
    {
        let expReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", expReg)
            
        return emailPred.evaluate(with: correo)
    }
    
    @IBAction func LogIn(_ sender: UIButton) {
        guard let email = txtCorreo.text, !email.isEmpty else {
              showError(message: "Por favor, ingresa tu correo electrónico.")
              return
          }
          
          guard let password = txtPassword.text, !password.isEmpty else {
              showError(message: "Por favor, ingresa tu contraseña.")
              return
          }
          
          if email.isEmpty && password.isEmpty {
              showError(message: "Por favor, llenar todos los campos.")
              return
          }
          
          if validaCorreo(email) {
              Errores_lbl.isHidden = true
              login()
          } else {
              showError(message: "Por favor, ingresa un correo electrónico válido.")
          }
    }
    
    
    func showError(message: String) {
        Errores_lbl.isHidden = false
        Errores_lbl.textColor = .red
        Errores_lbl.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.Errores_lbl.isHidden = true
        }
    }
    
    func login() {
        let url = URL(string: "http://192.168.80.101:8000/api/auth/logCode")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.httpMethod = "POST"
        
        let email = txtCorreo.text!
        let password = txtPassword.text!
          
        let requestBody: [String: Any] = [
            "email": email,
            "password": password
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
                    
                    if httpResponse.statusCode == 200 {  DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "sgVerify", sender: self)
                    }
                      
                    } else if httpResponse.statusCode == 401 {
                        DispatchQueue.main.async {
                            self.showError(message: "Credenciales incorrectas")
                        }
                    } else if httpResponse.statusCode == 403 {
                        DispatchQueue.main.async {
                         self.showError(message: "Correo no verificado")
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
                } catch {
                    print("Error al convertir la respuesta a JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
 

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "sgVerify" {
            if !hasErrors {
                return true
            }
            
            return false
        }
            
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtCorreo{
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            txtPassword.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLenght = maxLenghts[textField] ?? Int.max
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
    
        return newString.length <= maxLenght
    }
    
    func showWelcomeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "¡Bienvenido a SmartNest!"
        content.body = "¡Gracias por iniciar sesión!"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "welcomeNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error al agregar la solicitud de notificación de bienvenida: \(error.localizedDescription)")
            }
        }
    }
    

}
