//
//  RegistroViewController.swift
//  Integradora_5A
//
//  Created by imac on 25/03/24.
//

import UIKit

class RegistroViewController: UIViewController {

    @IBOutlet weak var Nombre: UITextField!
    @IBOutlet weak var Apellidos: UITextField!
    
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Correo: UITextField!
    @IBOutlet weak var Password_conf: UITextField!
    
    @IBOutlet weak var btnRegistrar: UIButton!
    @IBOutlet weak var hospital: UIPickerView!
    


    @IBOutlet weak var Errores_lbl: UILabel!
    var hasErrors = true
    let usuario = Usuario.sharedData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
        
     
    }

    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }
    
    @IBAction func Register(_ sender: UIButton) {
        validateAndRegister()
    }
    func registrar()
    {
        let conexion = URLSession(configuration: .default)
        let url = URL(string: "http://192.168.80.101:8000/api/auth/register")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.httpMethod = "POST"
        
        let name = Nombre.text!
        let last_name = Apellidos.text!
        let email = Correo.text!
        let password =  Password.text!
        let password_confirmation = Password_conf.text!
        
        let requestBody: [String: Any] = [
            "name": name,
            "last_name":last_name,
            "email": email,
            "password": password,
            "confirm_password": password_confirmation
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
                self.showSuccess(message: "Registrado correctamente")
                DispatchQueue.main.async {
                    self.showWelcomeNotification()
                    self.performSegue(withIdentifier: "sgRegister", sender: self)
                    if let data = data,
                       let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let signedRoute = jsonDict["url"] as? String {
                        self.hasErrors = false
                        self.usuario.name = name
                        self.usuario.lastname = last_name
                        self.usuario.email = email
                        self.usuario.password = password
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
                                self.showError(message: "El correo electrónico ya ha sido tomado.")
                                return
                            }
                        }
                    } catch {
                        print("Error al procesar el JSON de error: \(error)")
                    }
                }
                self.showError(message: "Error en el registro: \(statusCode)")
                self.hasErrors = true
            } else {
                print("Error en la solicitud: Código de estado HTTP \(statusCode)")
                self.hasErrors = true
            }
        }
        
        task.resume()
    }
    
    
    
    
    
    
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "sgRegister" {
            if !hasErrors {
                return true
            }
            
            return false
        }
            
        return false
    }


    func validateAndRegister() {
        guard let name = Nombre.text, !name.isEmpty,
              let email = Correo.text, !email.isEmpty,
              let password = Password.text, !password.isEmpty,
              let confirmPassword = Password_conf.text, !confirmPassword.isEmpty else {
            showError(message: "Por favor, completa todos los campos.")
            return
        }

        if let nameError = validateName(name) {
            showError(message: nameError)
            return
        }

        if let emailError = validateEmail(email) {
            showError(message: emailError)
            return
        }

        if let passwordError = validatePassword(password) {
            showError(message: passwordError)
            return
        }

        if let confirmPasswordError = validateConfirmPassword(password, confirmPassword) {
            showError(message: confirmPasswordError)
            return
        }
        registrar()
    }

    func validateEmail(_ email: String) -> String? {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            return "Formato de correo electrónico inválido."
        }
        return nil
    }

    func validatePassword(_ password: String) -> String? {
        if password.count < 8 {
            return "La contraseña debe tener al menos 8 caracteres."
        }
        let digitRegex = ".*[0-9]+.*"
        let digitPredicate = NSPredicate(format: "SELF MATCHES %@", digitRegex)
        if !digitPredicate.evaluate(with: password) {
            return "La contraseña debe contener al menos un dígito."
        }
        return nil
    }

    func validateConfirmPassword(_ password: String, _ confirmPassword: String) -> String? {
        if password != confirmPassword {
            return "Las contraseñas no coinciden."
        }
        return nil
    }

    func validateName(_ name: String) -> String? {
        if name.count < 3 {
            return "El nombre debe tener al menos 3 caracteres."
        }
        if name.count > 40 {
            return "El nombre debe tener como máximo 40 caracteres."
        }
        return nil
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
    func showWelcomeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "¡Bienvenido a SmartNest!"
        content.body = "¡Te has registrado con éxito! Favor de verificar tu bandeja de correo."
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

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
}

     
     
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


