//
//  ContactosViewController.swift
//  Integradora_5A
//
//  Created by imac on 15/04/24.
//

import UIKit

class ContactosViewController: UIViewController {
    
    @IBOutlet weak var srcContactos: UIScrollView!
    
    @IBOutlet weak var btnContacto: UIButton!
    var idbebe: Int!
    let usuario =  Usuario.sharedData()
    var contactos: [Contacto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        consultarContactos()
        print("id del bebe \(idbebe!)")
        
        if usuario.id_rol == 3
        {
            btnContacto.alpha = 0
            btnContacto.isEnabled = false
        }
        else
        {
            btnContacto.alpha = 1
            btnContacto.isEnabled = true
        }
        
        
    }
    
    
    @objc func irDetalle (sender: UIButton) {
        self.performSegue(withIdentifier: "sgNewC", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgNewC"
        {
            let destino =  segue.destination as! NuevoContactoViewController
            destino.idbebe = idbebe
        }
    }
    

    

    func consultarContactos()
    {
        let url = URLManager.sharedInstance.getURL(path: "/api/bebes/bebefull/\(idbebe!)")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let conexion = URLSession(configuration: .default)

        func crearContacto(desde diccionario: [String: Any]) -> Contacto {
            let id = diccionario["id_contactoFamiliar"] as! Int
            let nombre = diccionario["nombre"] as! String
            let apellido = diccionario["apellido"] as! String
            let telefono = diccionario["telefono"] as! String
            let email = diccionario["email"] as! String
            
          return Contacto(id: id, nombre: nombre, apellido: apellido, telefono: telefono, email: email)
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
                if let json = json, let resultados = json["Contactos"] as? [[String: Any]] {
                    for contacto in resultados {
                        let nuevoContacto = crearContacto(desde: contacto)
                        self.contactos.append(nuevoContacto)
                        print(nuevoContacto.nombre)
                    }
                    DispatchQueue.main.async {
                        self.dibujarContactos()
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
    
    
    func dibujarContactos()
    {
        let x = 10.0
        let h = 100.0
        let k = 10.0
        var w = Double(self.srcContactos.frame.width) - 2.5*x
        let m = 5.0
        var y = k
        //(x: x, y: y, width: w, height: h)
        for i in 0..<contactos.count{
            let vwVista = UIView(frame: CGRect(x: x, y: y, width: w, height: 240))
            vwVista.backgroundColor = UIColor(red: 112.0/255.0, green: 130.0/255.0, blue: 56.0/255.0, alpha: 1.0)
            vwVista.layer.cornerRadius = 15
            let imvFoto = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: h - 10.0, height: h - 10.0))
            imvFoto.image = UIImage(named: "contacte")
            imvFoto.contentMode = .scaleAspectFit
            
            let lblIncubadora = UILabel(frame: CGRect(x: h, y: m, width: w - h - m, height: (h - 2*m) * 0.4))
            lblIncubadora.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            lblIncubadora.adjustsFontSizeToFitWidth = true
            lblIncubadora.text = "Contacto no° \(i + 1)"
            lblIncubadora.minimumScaleFactor = 0.5
            
            let lblNombreTitle = UILabel(frame: CGRect(x: h, y: Double(lblIncubadora.frame.origin.y + lblIncubadora.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblNombreTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            lblNombreTitle.adjustsFontSizeToFitWidth = true
            lblNombreTitle.text = "Nombre completo: "
            lblNombreTitle.minimumScaleFactor = 0.5
            
            
            let lblNombre = UILabel(frame: CGRect(x: h, y: Double(lblNombreTitle.frame.origin.y + lblNombreTitle.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblNombre.font = UIFont.systemFont(ofSize: 20)
            lblNombre.adjustsFontSizeToFitWidth = true
            lblNombre.text = contactos[i].nombre + " " + contactos[i].apellido
            lblNombre.minimumScaleFactor = 0.5
            
            let lblTelefonoTitle = UILabel(frame: CGRect(x: h, y: Double(lblNombre.frame.origin.y + lblNombre.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblTelefonoTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            lblTelefonoTitle.adjustsFontSizeToFitWidth = true
            lblTelefonoTitle.text = "Teléfono: "
            lblTelefonoTitle.minimumScaleFactor = 0.5
            
            let lblTelefono = UILabel(frame: CGRect(x: h, y: Double(lblTelefonoTitle.frame.origin.y + lblTelefonoTitle.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblTelefono.font = UIFont.systemFont(ofSize: 20)
            lblTelefono.adjustsFontSizeToFitWidth = true
            lblTelefono.text = contactos[i].telefono
            lblTelefono.minimumScaleFactor = 0.5
            
            let lblEmailTitle = UILabel(frame: CGRect(x: h, y: Double(lblTelefono.frame.origin.y + lblTelefono.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblEmailTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            lblEmailTitle.adjustsFontSizeToFitWidth = true
            lblEmailTitle.text = "Email: "
            lblEmailTitle.minimumScaleFactor = 0.5
            
            let lblEmail = UILabel(frame: CGRect(x: h, y: Double(lblEmailTitle.frame.origin.y + lblEmailTitle.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblEmail.font = UIFont.systemFont(ofSize: 20)
            lblEmail.adjustsFontSizeToFitWidth = true
            lblEmail.text = contactos[i].email
            lblEmail.minimumScaleFactor = 0.5
            
            
            vwVista.addSubview(imvFoto)
            vwVista.addSubview(lblNombreTitle)
            vwVista.addSubview(lblNombre)
            vwVista.addSubview(lblTelefonoTitle)
            vwVista.addSubview(lblTelefono)
            vwVista.addSubview(lblEmailTitle)
            vwVista.addSubview(lblEmail)
            vwVista.addSubview(lblIncubadora)
            //vwVista.addSubview(btnDetalle)
            //vwVista.addSubview(lblEstadoTitle)
            srcContactos.addSubview(vwVista)
            
            y += h + 100.0
        }
        
        srcContactos.contentSize = CGSize(width: 0.0, height: y)
    }
    
 
    
}
