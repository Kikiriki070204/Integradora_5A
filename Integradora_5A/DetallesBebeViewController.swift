//
//  DetallesBebeViewController.swift
//  Integradora_5A
//
//  Created by imac on 12/04/24.
//

import UIKit

class DetallesBebeViewController: UIViewController {
    let usuario =  Usuario.sharedData()
    
    @IBOutlet weak var btnEditar: UIButton!
    
    @IBOutlet weak var txfApellido: UITextField!
    @IBOutlet weak var txfNombre: UITextField!
    @IBOutlet weak var sgmSexo: UISegmentedControl!
    @IBOutlet weak var sgmEstado: UISegmentedControl!
    @IBOutlet weak var txfPeso: UITextField!
    
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var Errores_lbl: UILabel!
    var hasErrors = true
    
    var idbebe: Int!
    var nombre: String!
    var apellido: String!
    var sexo: String!
    @IBOutlet weak var lblFecha: UILabel!
    var fecha_nacimiento: String!
    var edad: Int!
    var peso: Double!
    var estado: Int!
    var hospital: String!
    var indice = 0
    
    var incubadora: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Errores_lbl.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
                view.addGestureRecognizer(tapGesture)
        
        txfNombre.addTarget(self, action: #selector(habilitarEditar(_:)), for: .editingDidBegin)
        txfApellido.addTarget(self, action: #selector(habilitarEditar(_:)), for: .editingDidBegin)
           sgmSexo.addTarget(self, action: #selector(habilitarEditar(_:)), for: .valueChanged)
           sgmEstado.addTarget(self, action: #selector(habilitarEditar(_:)), for: .valueChanged)
           txfPeso.addTarget(self, action: #selector(habilitarEditar(_:)), for: .editingDidBegin)
        
        background.layer.cornerRadius = 15
        Fondo()
        detalles()
        Estado()
        print(sgmEstado.selectedSegmentIndex)
        
        
    }
    
    @IBAction func ocultarTeclado()
    {
        view.endEditing(true)
    }
    
    @objc func habilitarEditar(_ sender: Any) {
        btnEditar.isEnabled = true
    }
    
    func Fondo(){
        if sexo == "F"
        {
            view.backgroundColor = UIColor(red: 255.0/255.0, green: 188.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            sgmSexo.selectedSegmentIndex = indice
            
        }
        else {
            view.backgroundColor = UIColor(red: 177.0/255.0, green: 223.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            sgmSexo.selectedSegmentIndex = indice + 1
        }
    }
    
    func detalles()
    {
        txfNombre.text = nombre
        txfPeso.text = String(format: "%.2f", peso)
        txfApellido.text = apellido
        lblFecha.text = fecha_nacimiento
        
        
    }
    
    func Estado()
    {
        if estado == 1
        {
            sgmEstado.selectedSegmentIndex = indice
        }
        else if estado == 2
        {
            sgmEstado.selectedSegmentIndex = indice + 1
        }
        else
        {
            sgmEstado.selectedSegmentIndex = indice + 2
        }
    }

    
    @IBAction func Editar(_ sender: UIButton) {
    editarDatos()
    }
    
    
    func editarDatos()
    {
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/bebes/update/\(idbebe!)")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        
        let name = nombre
        let last_name = apellido
        let weight = peso
        let idEstado = sgmEstado.selectedSegmentIndex + 1
        
        let requestBody: [String: Any] = [
            "nombre": txfNombre.text!,
            "apellido": txfApellido.text!,
            "peso": Double(txfPeso.text!),
            "id_estado": sgmEstado.selectedSegmentIndex + 1,
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
                    self.performSegue(withIdentifier: "sgEditar", sender: self)
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
                self.hasErrors = true
            }
        }
        
        task.resume()
    }
    
    @IBAction func contactos(_ sender: UIButton) {
        performSegue(withIdentifier: "sgContactos", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgContactos"
        {
            let vc = segue.destination as! ContactosViewController
            vc.idbebe = idbebe
        }
        else if segue.identifier == "sgHistorial"
        {
            let vc = segue.destination as! HistorialViewController
            vc.idbebe = idbebe
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
    

    

}
