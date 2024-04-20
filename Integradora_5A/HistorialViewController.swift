//
//  HistorialViewController.swift
//  Integradora_5A
//
//  Created by imac on 15/04/24.
//

import UIKit

class HistorialViewController: UIViewController {
    @IBOutlet weak var btnHistorial: UIButton!
    var idbebe: Int!
    let usuario =  Usuario.sharedData()
    var historiales: [Historial] = []

    @IBOutlet weak var scrHistorial: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        consultarHistorial()
        print("id del bebe: \(idbebe!)")
        
        if usuario.id_rol == 3
        {
            btnHistorial.alpha = 0
            btnHistorial.isEnabled = false
        }
        else
        {
            btnHistorial.alpha = 1
            btnHistorial.isEnabled = true
        }
        
    }
    
    @objc func irDetalle (sender: UIButton) {
        self.performSegue(withIdentifier: "sgNewH", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgNewH"
        {
            let destino =  segue.destination as! NuevoHistorialViewController
            destino.idbebe = idbebe
        }
    }
    

    func consultarHistorial()
    {
        let url = URLManager.sharedInstance.getURL(path: "/api/bebes/bebefull/\(idbebe!)")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let conexion = URLSession(configuration: .default)

        func crearHistorial(desde diccionario: [String: Any]) -> Historial {
            let id = diccionario["id"] as! Int
            let id_bebe = diccionario["id_bebe"] as! Int
            let diagnostico = diccionario["diagnostico"] as! String
            let medicamentos = diccionario["medicamentos"] as! String
            let created_at = diccionario["created_at"] as! String
            
            return Historial(id: id, id_bebe: id_bebe, diagnostico: diagnostico, medicamentos: medicamentos, created_at: created_at)
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
                if let json = json, let resultados = json["Historial"] as? [[String: Any]] {
                    for historial in resultados {
                        let nuevoHistorial = crearHistorial(desde: historial)
                        self.historiales.append(nuevoHistorial)
                        print(nuevoHistorial.diagnostico)
                    }
                    DispatchQueue.main.async {
                        self.dibujarHistoriales()
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
    
    
    func dibujarHistoriales()
    {
        let x = 10.0
        let h = 120.0
        let k = 10.0
        var w = Double(self.scrHistorial.frame.width) - 2.5*x
        let m = 5.0
        var y = k
        //(x: x, y: y, width: w, height: h)
        for i in 0..<historiales.count{
            let vwVista = UIView(frame: CGRect(x: x, y: y, width: w, height: 280))
            vwVista.backgroundColor = UIColor(red: 221.0/255.0, green: 131.0/255.0, blue: 116.0/255.0, alpha: 1.0)
            vwVista.layer.cornerRadius = 15
            let imvFoto = UIImageView(frame: CGRect(x: 5.0, y: 15.0, width: h - 10.0, height: h - 10.0))
            imvFoto.image = UIImage(named: "historial")
            imvFoto.contentMode = .scaleAspectFit
            
            let lblIncubadora = UILabel(frame: CGRect(x: h, y: m, width: w - h - m, height: (h - 2*m) * 0.4))
            lblIncubadora.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            lblIncubadora.adjustsFontSizeToFitWidth = true
            lblIncubadora.text = "Historial no° \(i + 1)"
            lblIncubadora.minimumScaleFactor = 0.5
            
            let lblNombreTitle = UILabel(frame: CGRect(x: h, y: Double(lblIncubadora.frame.origin.y + lblIncubadora.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblNombreTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            lblNombreTitle.adjustsFontSizeToFitWidth = true
            lblNombreTitle.text = "Diagnóstico: "
            lblNombreTitle.minimumScaleFactor = 0.5
            
            
            let lblNombre = UILabel(frame: CGRect(x: h, y: Double(lblNombreTitle.frame.origin.y + lblNombreTitle.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblNombre.font = UIFont.systemFont(ofSize: 20)
            lblNombre.adjustsFontSizeToFitWidth = true
            lblNombre.text = historiales[i].diagnostico
            lblNombre.minimumScaleFactor = 0.5
            
            let lblTelefonoTitle = UILabel(frame: CGRect(x: h, y: Double(lblNombre.frame.origin.y + lblNombre.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblTelefonoTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            lblTelefonoTitle.adjustsFontSizeToFitWidth = true
            lblTelefonoTitle.text = "Medicamentos: "
            lblTelefonoTitle.minimumScaleFactor = 0.5
            
            let lblTelefono = UILabel(frame: CGRect(x: h, y: Double(lblTelefonoTitle.frame.origin.y + lblTelefonoTitle.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblTelefono.font = UIFont.systemFont(ofSize: 20)
            lblTelefono.adjustsFontSizeToFitWidth = true
            lblTelefono.text = historiales[i].medicamentos
            lblTelefono.minimumScaleFactor = 0.5
            
            let lblEmailTitle = UILabel(frame: CGRect(x: h, y: Double(lblTelefono.frame.origin.y + lblTelefono.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblEmailTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            lblEmailTitle.adjustsFontSizeToFitWidth = true
            lblEmailTitle.text = "Creado (fecha y hora): "
            lblEmailTitle.minimumScaleFactor = 0.5
            
            let lblEmail = UILabel(frame: CGRect(x: h, y: Double(lblEmailTitle.frame.origin.y + lblEmailTitle.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblEmail.font = UIFont.systemFont(ofSize: 20)
            lblEmail.adjustsFontSizeToFitWidth = true
            lblEmail.text = historiales[i].created_at
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
            scrHistorial.addSubview(vwVista)
            
            y += h + 130
        }
        
        scrHistorial.contentSize = CGSize(width: 0.0, height: y)
    }


}
