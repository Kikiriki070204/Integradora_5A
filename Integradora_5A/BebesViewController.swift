//
//  BebesViewController.swift
//  Integradora_5A
//
//  Created by imac on 10/04/24.
//

import UIKit


class BebesViewController: UIViewController {
    
    
    @IBOutlet weak var btnCrear: UIButton!
    let usuario = Usuario.sharedData()

    @IBOutlet weak var scrBebes: UIScrollView!
    var bebes: [Bebe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(usuario.access_token)
        consultarBebes()
        usuarioDatos()
        
        if usuario.id_rol == 3
        {
            btnCrear.alpha = 0
            btnCrear.isEnabled = false
        }
        else
        {
            btnCrear.alpha = 1
            btnCrear.isEnabled = true
        }
        
        
    }
    
    
    func consultarBebes()
    {
        let url = URLManager.sharedInstance.getURL(path: "/api/bebes/list")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let conexion = URLSession(configuration: .default)

        func crearBebe(desde diccionario: [String: Any]) -> Bebe {
            let id = diccionario["id"] as! Int
            let nombre = diccionario["nombre"] as! String
            let apellido = diccionario["apellido"] as! String
            let sexo = diccionario["sexo"] as! String
            let fechaNacimiento = diccionario["fecha_nacimiento"] as! String
            let edad = diccionario["edad"] as! Int
            let peso = diccionario["peso"] as! Double
            let idEstado = diccionario["id_estado"] as! Int
            
            let idIncubadora = diccionario["id_incubadora"] as! Int
            let estado = diccionario["estado"] as! String
            let hospital = diccionario["hospital"] as! String
            
            return Bebe(id: id, nombre: nombre, apellido: apellido, sexo: sexo, fecha_nacimiento: fechaNacimiento, edad: edad, peso: peso, id_estado: idEstado, id_incubadora: idIncubadora, estado: estado, hospital: hospital)
             
        }
        
        
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
                let json = try JSONSerialization.jsonObject(with: datos, options: []) as? [String: Any]
                if let json = json, let resultados = json["Bebes"] as? [[String: Any]] {
                    for bebe in resultados {
                        let nuevoBebe = crearBebe(desde: bebe)
                        self.bebes.append(nuevoBebe)
                        print(nuevoBebe.nombre)
                    }
                    DispatchQueue.main.async {
                        self.dibujarBebes()
                        print(json)
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
    
    
    func dibujarBebes()
    {
        let x = 10.0
        let h = 120.0
        let k = 10.0
        var w = Double(self.scrBebes.frame.width) - 2.5*x
        let m = 5.0
        var y = k
        //(x: x, y: y, width: w, height: h)
        for i in 0..<bebes.count{
            if bebes[i].id_estado == 1 {
                let vwVista = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
                if bebes[i].sexo == "F"
                {
                    vwVista.backgroundColor = UIColor(red: 255.0/255.0, green: 188.0/255.0, blue: 205.0/255.0, alpha: 1.0)
                }
                else {
                    vwVista.backgroundColor = UIColor(red: 177.0/255.0, green: 223.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                }
                vwVista.layer.cornerRadius = 15
                let imvFoto = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: h - 10.0, height: h - 10.0))
                imvFoto.image = UIImage(named: "baby_icon")
                imvFoto.contentMode = .scaleAspectFit

                let lblIncubadora = UILabel(frame: CGRect(x: h, y: m, width: w - h - m, height: (h - 2*m) * 0.4))
                lblIncubadora.font = UIFont.systemFont(ofSize: 25, weight: .bold)
                lblIncubadora.adjustsFontSizeToFitWidth = true
                lblIncubadora.text = "Incubadora no° \(bebes[i].id_incubadora)"
                lblIncubadora.minimumScaleFactor = 0.5
                
                let lblNombreTitle = UILabel(frame: CGRect(x: h, y: Double(lblIncubadora.frame.origin.y + lblIncubadora.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
                lblIncubadora.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                lblNombreTitle.adjustsFontSizeToFitWidth = true
                lblNombreTitle.text = "Nombre del paciente: "
                lblNombreTitle.minimumScaleFactor = 0.5
                
                
                let lblNombre = UILabel(frame: CGRect(x: h, y: Double(lblNombreTitle.frame.origin.y + lblNombreTitle.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
                lblNombre.font = UIFont.systemFont(ofSize: 20)
                lblNombre.adjustsFontSizeToFitWidth = true
                lblNombre.text = bebes[i].nombre + " " + bebes[i].apellido
                lblNombre.minimumScaleFactor = 0.5
                
                let btnDetalle = UIButton(frame: CGRect(x: 0, y: 0, width: vwVista.frame.width, height: vwVista.frame.height))
                btnDetalle.tag = i
                btnDetalle.addTarget(self, action: #selector(irDetalle(sender:)), for: .touchUpInside)
                
                vwVista.addSubview(imvFoto)
                vwVista.addSubview(lblNombreTitle)
                vwVista.addSubview(lblNombre)
                vwVista.addSubview(lblIncubadora)
                vwVista.addSubview(btnDetalle)
                scrBebes.addSubview(vwVista)
                
                y += h + k
            }
           
        }
        
        let totalHeight = y > scrBebes.frame.height ? y : scrBebes.frame.height
        scrBebes.contentSize = CGSize(width: 0.0, height: totalHeight)
    }
    
    @objc func irDetalle (sender: UIButton) {
        self.performSegue(withIdentifier: "sgDetalles", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgDetalles"
        {
            let btnSender = sender as! UIButton
            let vcIncubadora = segue.destination as! DetallesBebeViewController
            vcIncubadora.incubadora = bebes[btnSender.tag].id_incubadora
            
            vcIncubadora.idbebe = bebes[btnSender.tag].id
            vcIncubadora.nombre = bebes[btnSender.tag].nombre
            vcIncubadora.apellido = bebes[btnSender.tag].apellido
            vcIncubadora.sexo = bebes[btnSender.tag].sexo
            vcIncubadora.fecha_nacimiento = bebes[btnSender.tag].fecha_nacimiento
            vcIncubadora.edad = bebes[btnSender.tag].edad
            vcIncubadora.peso = bebes[btnSender.tag].peso
            vcIncubadora.estado = bebes[btnSender.tag].id_estado
            vcIncubadora.hospital = bebes[btnSender.tag].hospital
        }
        
    }
    
    func usuarioDatos()
    {
                let conexion = URLSession(configuration: .default)
                let url = URLManager.sharedInstance.getURL(path: "/api/auth/me")!
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
                        if let data = data,
                           let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let id = jsonDict["id"] as? Int,
                           let nombre = jsonDict["name"] as? String,
                           let apellido = jsonDict["last_name"] as? String,
                           let email = jsonDict["email"] as? String
                        
                        {
                            self.usuario.name = nombre
                            self.usuario.id = id
                            self.usuario.lastname = apellido
                            self.usuario.email = email
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
    
}
