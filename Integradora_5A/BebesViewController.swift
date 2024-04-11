//
//  BebesViewController.swift
//  Integradora_5A
//
//  Created by imac on 10/04/24.
//

import UIKit

class BebesViewController: UIViewController {

    @IBOutlet weak var scrBebes: UIScrollView!
    var bebes: [Bebe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        consultarBebes()
        
    }
    
    
    func consultarBebes()
    {
        let conexion = URLSession(configuration: .default)
        let url = URL(string: "https://192.168.80.101:8000/api/bebes/list")!
        
        
        func crearBebe(desde diccionario: [String: Any]) -> Bebe {
            let nombre = diccionario["nombre"] as! String
            let apellido = diccionario["apellido"] as! String
            let sexo = diccionario["sexo"] as! String
            let fechaNacimiento = diccionario["fecha_nacimiento"] as! Date
            let edad = diccionario["edad"] as! Int
            let peso = diccionario["peso"] as! Double
            let idEstado = diccionario["id_estado"] as! Int
            let idIncubadora = diccionario["id_incubadora"] as! Int
            
            return Bebe(nombre: nombre, apellido: apellido, sexo: sexo, fecha_nacimiento: fechaNacimiento, edad: edad, peso: peso, id_estado: idEstado, id_incubadora: idIncubadora)
        }
        
        conexion.dataTask(with: url) { datos, respuesta, error in
            do {
                let json = try JSONSerialization.jsonObject(with: datos!) as! [String: Any]
                let resultados = json["results"] as! [[String: Any]]
                
                for bebe in resultados {
                    let nuevoBebe = crearBebe(desde: bebe)
                    self.bebes.append(nuevoBebe)
                }
                
                DispatchQueue.main.async {
                    self.dibujarBebes()
                }
            } catch {
                print("Algo salió mal =(")
            }
        }.resume()
        
    }
    
    
    
    
    func dibujarBebes()
    {
        let x = 10.0
        let h = 120.0
        let k = 10.0
        var w = Double(self.scrBebes.frame.width)
        w -= 2 * x
        let m = 5.0
        var y = k
        //(x: x, y: y, width: w, height: h)
        for i in 0..<bebes.count{
            let vwVista = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
            vwVista.backgroundColor = .orange
            let imvFoto = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: h - 10.0, height: h - 10.0))
            imvFoto.image = UIImage(named: "baby_icon.png")
            imvFoto.contentMode = .scaleAspectFit
            /*let conexion =  URLSession(configuration: .default)
             conexion.dataTask(with: URL(string: bebes[i].imagen)!)
             {datos, respuesta, error in
             if let imagen = datos
             {
             DispatchQueue.main.async {
             imvFoto.image = UIImage(data: imagen)
             }
             }
             else
             {
             print("Algo salió mal :(")
             }
             
             }.resume()*/
            
            let lblNombre = UILabel(frame: CGRect(x: h, y: m, width: w - h - m, height: (h - 2*m) * 0.4))
            lblNombre.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
            lblNombre.adjustsFontSizeToFitWidth = true
            lblNombre.text = bebes[i].nombre
            lblNombre.minimumScaleFactor = 0.5
            
            let lblApellido = UILabel(frame: CGRect(x: h, y: Double(lblNombre.frame.origin.y + lblNombre.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblApellido.font = UIFont.systemFont(ofSize: 27.0, weight: .regular)
            lblApellido.adjustsFontSizeToFitWidth = true
            lblApellido.text = bebes[i].apellido
            lblApellido.minimumScaleFactor = 0.5
            
            let lblSexo = UILabel(frame: CGRect(x: h, y: Double(lblApellido.frame.origin.y + lblApellido.frame.height), width: w - h - m, height: (h - 2*m) * 0.3))
            lblSexo.font = UIFont.systemFont(ofSize: 27.0, weight: .regular)
            lblSexo.adjustsFontSizeToFitWidth = true
            lblSexo.text = bebes[i].sexo
            lblSexo.minimumScaleFactor = 0.5
            
            /*let btnDetalle = UIButton(frame: CGRect(x: 0, y: 0, width: vwVista.frame.width, height: vwVista.frame.height))
            btnDetalle.tag = i
            btnDetalle.addTarget(self, action: #selector(irDetalle(sender:)), for: .touchUpInside)*/
            
            vwVista.addSubview(imvFoto)
            vwVista.addSubview(lblNombre)
            vwVista.addSubview(lblApellido)
            vwVista.addSubview(lblSexo)
            //vwVista.addSubview(btnDetalle)
            scrBebes.addSubview(vwVista)
            
            y += h + k
        }
    }
    
}
