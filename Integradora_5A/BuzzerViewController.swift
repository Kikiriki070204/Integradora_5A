//
//  BuzzerViewController.swift
//  Integradora_5A
//
//  Created by imac on 20/04/24.
//

import UIKit

class BuzzerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pkIncubadora: UIPickerView!
    @IBOutlet weak var btnApagar: UIButton!
    @IBOutlet weak var btnEncender: UIButton!
    
    var incubadoras: [Incubadora] = []
    var incubadorasId: [Int] = []
    var incubadorasNombre: [String] = []
    let usuario = Usuario.sharedData()
    var estado: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        incubadorasDisponibles()
        
    }
    
    func incubadorasDisponibles()
    {
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/incubadora/incubadorasOcupadas")!
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
                            self.btnEncender.isEnabled = false
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
    
    
    
    @IBAction func Encender(_ sender: UIButton) {
        encender()
    }
    
    
    @IBAction func Apagar(_ sender: UIButton) {
        apagar()
    }
    
    
    //ENCENDER BUZZER
    func encender(){
        estado = 1
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/Activador/buzzer/\(estado!)")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        conexion.dataTask(with: request) { datos, respuesta, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = respuesta as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error en la respuesta del servidor")
                print(respuesta)
                return
            }

            guard let datos = datos else {
                print("No se recibieron datos del servidor")
                return
            }

            do {
                let statusCode = httpResponse.statusCode
                print("Código de estado HTTP recibido: \(statusCode)")
                
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        print("Encendido")
                        self.btnApagar.isEnabled = true
                        self.btnEncender.isEnabled = false
                        self.pkIncubadora.isUserInteractionEnabled = false
                    }
                } else {
                    print("Algo salió mal")
                
                }
            } catch {
                print("Error al decodificar los datos JSON: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    
    //APAGAR BUZZER
    func apagar(){
        estado = 0
        let conexion = URLSession(configuration: .default)
        let url = URLManager.sharedInstance.getURL(path: "/api/Activador/buzzer/\(estado!)")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        conexion.dataTask(with: request) { datos, respuesta, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = respuesta as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error en la respuesta del servidor")
                print(respuesta)
                return
            }

            guard let datos = datos else {
                print("No se recibieron datos del servidor")
                return
            }

            do {
                let statusCode = httpResponse.statusCode
                print("Código de estado HTTP recibido: \(statusCode)")
                
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        print("Apagado")
                        self.btnApagar.isEnabled = false
                        self.btnEncender.isEnabled = true
                        self.pkIncubadora.isUserInteractionEnabled = true
                    }
                } else {
                    print("Algo salió mal")
                
                }
            } catch {
                print("Error al decodificar los datos JSON: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    
}
