//
//  IncubadoraViewController.swift
//  Integradora_5A
//
//  Created by imac on 02/04/24.
//

import UIKit

class IncubadoraViewController: UIViewController {

    @IBOutlet weak var srcIncubadoras: UIScrollView!
    var incubadoras: [Incubadora] = []
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
   /*
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let boton = sender as! UIButton
        let vcDetalle =  segue.destination as! DetalleIncuViewController
        vcDetalle.detalle_incubadora = incubadoras[boton.tag].detalle_incubadora
    }
    
    func consultarIncubadoras()
    {
        let conexion = URLSession(configuration: .default)
        let url = URL(string: "https://192.168.80.101:8000/api/incubadora/list")!
        
        conexion.dataTask(with: url) { datos, respuesta, error in
            do
            {
                let json = try JSONSerialization.jsonObject(with: datos!) as! [String:Any]
                let resultados = json["results"] as! [[String: Any]]
                
                for incubadora in resultados
                {
                    self.incubadoras.append(Incubadora.init(nombre: personaje["name"] as! String, estado: personaje["status"] as! String, especie: personaje["species"] as! String, imagen: personaje["image"] as! String))
                    self.personajes.last?.episodios = personaje["episode"] as! [String]
                }
                
                DispatchQueue.main.async {
                    self.dibujarPersonajes()
                }
            }
            catch
            {
                print("Algo salió mal =(")
            }
        }.resume()
    }
    
    
*/

}
