//
//  SensoresViewController.swift
//  Integradora_5A
//
//  Created by imac on 20/04/24.
//
import UIKit

class SensoresViewController: UIViewController {

    @IBOutlet weak var scrSensores: UIScrollView!

    let usuario = Usuario.sharedData()

    var sensores: [Sensor] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        consultarSensores()
    }

    func consultarSensores() {
        let url = URLManager.sharedInstance.getURL(path: "/api/values")!
        let token = usuario.access_token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let conexion = URLSession(configuration: .default)

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
                if let json = json, let dataDict = json["data"] as? [String: Any] {
                    var sensores: [Sensor] = []
                    for (key, value) in dataDict {
                        if let sensorDict = value as? [String: Any],
                           let id = sensorDict["_id"] as? String,
                           let name = sensorDict["name"] as? String,
                           let unit = sensorDict["unit"] as? String,
                           let sensorValue = sensorDict["value"] as? Double {
                            let sensor = Sensor(id: id, name: name, unit: unit, value: sensorValue)
                            sensores.append(sensor)
                        }
                    }
                    DispatchQueue.main.async {
                        self.dibujarSensores(sensores)
                        print(json)
                    }
                } else {
                    print("El formato de los datos recibidos no es el esperado")
                    print(respuesta)
                }
            } catch {
                print("Error al decodificar los datos JSON: \(error.localizedDescription)")
                print(respuesta)
            }
        }.resume()
    }

    func dibujarSensores(_ sensores: [Sensor]) {
        let x = 10.0
        let h = 120.0
        let k = 10.0
        var w = Double(self.scrSensores.frame.width) - 2.5 * x
        let m = 5.0
        var y = k

        for sensor in sensores {
            let vwVista = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
            
            vwVista.layer.cornerRadius = 15
            
            let imvFoto = UIImageView(frame: CGRect(x: 10.0, y: 20.0, width: 60.0, height: 60.0))
            imvFoto.contentMode = .scaleAspectFit
            
            
            let lblNombre = UILabel(frame: CGRect(x: h, y: m, width: w - h - m, height: (h - 2*m) * 0.4))
            lblNombre.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            
            
            if sensor.name == "bu"
            {
                vwVista.backgroundColor = UIColor(red: 180.0/255.0, green: 188.0/255.0, blue: 205.0/255.0, alpha: 1.0)
                imvFoto.image = UIImage(named: "buzz")
                lblNombre.text = "Buzzer"
            }
            else if sensor.name == "te"
            {
                vwVista.backgroundColor = UIColor(red: 255.0/255.0, green: 153.0/255.0, blue: 68.0/255.0, alpha: 1.0)
                imvFoto.image = UIImage(named: "temperatura")
                lblNombre.text = "Temperatura"
            }
            else if sensor.name == "pu"
            {
                vwVista.backgroundColor = UIColor(red: 75.0/255.0, green: 156.0/255.0, blue: 211.0/255.0, alpha: 1.0)
                imvFoto.image = UIImage(named: "pu")
                lblNombre.text = "Pulso"
            }
            else if sensor.name == "ca"
            {
                vwVista.backgroundColor = UIColor(red: 152.0/255.0, green: 251.0/255.0, blue: 152.0/255.0, alpha: 1.0)
                imvFoto.image = UIImage(named: "aire")
                lblNombre.text = "Calidad el aire"
            }
            else if sensor.name == "so"
            {
                vwVista.backgroundColor = UIColor(red: 222.0/255.0, green: 111.0/255.0, blue: 161.0/255.0, alpha: 1.0)
                imvFoto.image = UIImage(named: "3159161")
                lblNombre.text = "Sonido"
            }
            

            let lblValor = UILabel(frame: CGRect(x: h, y: Double(lblNombre.frame.origin.y + lblNombre.frame.height), width: w - 2 * m, height: (h - 2 * m) * 0.3))
            lblValor.font = UIFont.systemFont(ofSize: 16)
            lblValor.text = "Values: \(sensor.value) \(sensor.unit)"

            vwVista.addSubview(lblNombre)
            vwVista.addSubview(lblValor)
            vwVista.addSubview(imvFoto)
            scrSensores.addSubview(vwVista)

            y += h + k
        }

        let totalHeight = y > scrSensores.frame.height ? y : scrSensores.frame.height
        scrSensores.contentSize = CGSize(width: 0.0, height: totalHeight)
    }
}
