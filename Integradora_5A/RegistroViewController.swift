//
//  RegistroViewController.swift
//  Integradora_5A
//
//  Created by imac on 25/03/24.
//

import UIKit

class RegistroViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var hospitales: [Hospital] = []
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
        
        Errores_lbl.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
        Hospitaless()
        
     
    }
    func Hospitaless()
    {
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/hospital/listNtoken")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        func crearHospital(desde diccionario: [String: Any]) -> Hospital {
            let id = diccionario["id"] as! Int
            let nombre = diccionario["nombre"] as! String
            return Hospital(id: id, nombre: nombre)
        }
        conexion.dataTask(with: request) { datos, respuesta, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = respuesta as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error en la respuesta del servidor")
                //print("ROOOOOLLLL")
                //print(self.usuario.id_rol)
                print(respuesta)
                return
            }

            guard let datos = datos else {
                print("No se recibieron datos del servidor")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: datos, options: []) as? [String: Any]
                if let json = json, let resultados = json["Hospitales"] as? [[String: Any]] {
                    for hospital in resultados {
                        let nuevoHospital = crearHospital(desde: hospital)
                        self.hospitales.append(nuevoHospital)
                    }
                    DispatchQueue.main.async {
                        print(json)
                        //print(self.hospitales.count)
                        
                        self.hospital.reloadAllComponents()
                        
                        /*if self.hospitales.count == 0 {
                            self.hospital.isUserInteractionEnabled = false
                            self.btnCrear.isEnabled = false
                        } else {
                            self.pkIncubadora.isUserInteractionEnabled = true
                        }*/
                    }
                } else {
                    print("El formato de los datos recibidos no es el esperado")
                    print(json)
                }
            } catch {
                print("Error al decodificar los datos JSON: \(error.localizedDescription)")
            }
        }.resume()
        
        
    }
    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }
    
    @IBAction func Register(_ sender: UIButton) {
        self.showSuccess(message: "Espera...")
        validateAndRegister()
    }
    func registrar()
    {
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/auth/register")!
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
                       let id = jsonDict["id"] as? Int{
                        self.hasErrors = false
                        self.usuario.id = id
                        self.usuario.name = name
                        self.usuario.lastname = last_name
                        self.usuario.email = email
                        self.usuario.password = password
                        self.usuario.save()
                        
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

    @IBAction func login(_ sender: UIButton) {
        performSegue(withIdentifier: "LOGIN", sender: sender)
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.hospitales.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let hos = hospitales[row]
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
            
        ]
        let attributedString = NSAttributedString(string: "\(hos.nombre)", attributes: attributes)
        
        return attributedString
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedHospital = hospitales[row]
        print("ID del hospital: \(selectedHospital.id)")
    }
}

