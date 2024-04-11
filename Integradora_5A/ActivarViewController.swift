//
//  ActivarViewController.swift
//  Integradora_5A
//
//  Created by imac on 10/04/24.
//

import UIKit

class ActivarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func Hecho(_ sender: UIButton) {
        performSegue(withIdentifier: "sg-activar-login", sender: sender)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
