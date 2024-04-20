//
//  RegistrarBebeViewController.swift
//  Integradora_5A
//
//  Created by imac on 15/04/24.
//

import UIKit

class RegistrarBebeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    var hasErrors = true
    var incubadoras: [Incubadora] = []
    var incubadorasId: [Int] = []
    var incubadorasNombre: [String] = []
    let usuario = Usuario.sharedData()
    @IBOutlet weak var sgmSexo: UISegmentedControl!
    @IBOutlet weak var txfApellido: UITextField!
    @IBOutlet weak var pkIncubadora: UIPickerView!
    @IBOutlet weak var txfPeso: UITextField!
    @IBOutlet weak var dpFecha: UIDatePicker!
    @IBOutlet weak var btnRegistrar: UIButton!
    @IBOutlet weak var Errores_lbl: UILabel!
    @IBOutlet weak var sgmEstado: UISegmentedControl!
    @IBOutlet weak var btnCrear: UIButton!
    @IBOutlet weak var txfNombre: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        Errores_lbl.isHidden = true
        incubadorasDisponibles()


        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }
    
    
    @IBAction func Crear(_ sender: UIButton) {
        registrarBebe()
    }
    
    func registrarBebe()
    {
        
            let conexion = URLSession(configuration: .default)
            let url = URLManager.sharedInstance.getURL(path: "/api/bebes/create")!
            let token = usuario.access_token
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = "POST"
            let incubadoraSeleccionada = incubadoras[pkIncubadora.selectedRow(inComponent: 0)]
            var sex: String
            
            let name = txfNombre.text!
            let last_name = txfApellido.text!
            let sexo = sgmSexo.selectedSegmentIndex
        if sexo == 0 {
            sex = "F"
        }
        else {
            sex = "M"
        }
            let fecha = dpFecha.date
            let peso = txfPeso.text!
            let estado = sgmEstado.selectedSegmentIndex + 1
            let incubadora = incubadoraSeleccionada.id
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fechaNacimientoString = dateFormatter.string(from: dpFecha.date)
            
            let requestBody: [String: Any] = [
                "nombre": name,
                "apellido": last_name,
                "sexo": sex,
                "fecha_nacimiento": fechaNacimientoString,
                "edad": 0,
                "peso": peso,
                "id_estado": estado,
                "id_incubadora": incubadora
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
                    self.performSegue(withIdentifier: "sgTabBebe", sender: self)
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
   
    func incubadorasDisponibles()
    {
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/incubadora/incubadorasDisponibles")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        func crearIncubadora(desde diccionario: [String: Any]) -> Incubadora {
            let id = diccionario["id"] as! Int
            let folio = diccionario["folio"] as! String
           return Incubadora(id: id, folio: folio)
        }
        
        conexion.dataTask(with: request) { datos, respuesta, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = respuesta as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error en la respuesta del servidor")
                print("ROOOOOLLLL")
                print(self.usuario.id_rol)
                print(respuesta)
                return
            }

            guard let datos = datos else {
                print("No se recibieron datos del servidor")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: datos, options: []) as? [String: Any]
                if let json = json, let resultados = json["Incubadoras"] as? [[String: Any]] {
                    for bebe in resultados {
                        let nuevaIncubadora = crearIncubadora(desde: bebe)
                        self.incubadoras.append(nuevaIncubadora)
                    }
                    DispatchQueue.main.async {
                        print(json)
                        print(self.incubadoras.count)
                        
                        self.pkIncubadora.reloadAllComponents()
                        
                        if self.incubadoras.count == 0 {
                            self.pkIncubadora.isUserInteractionEnabled = false
                            self.btnCrear.isEnabled = false
                        } else {
                            self.pkIncubadora.isUserInteractionEnabled = true
                        }
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return self.incubadoras.count
        
    }
  
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let incubadora = incubadoras[row]
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
            
        ]
        let attributedString = NSAttributedString(string: "\(incubadora.folio)", attributes: attributes)
        
        return attributedString
    }


    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedIncubadora = incubadoras[row]
        print("ID de la incubadora: \(selectedIncubadora.id)")
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
