//
//  SplashViewController.swift
//  Integradora_5A
//
//  Created by imac on 27/03/24.
//

import UIKit

class SplashViewController: UIViewController {

    
    @IBOutlet weak var imvSplash: UIImageView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let w = 0.8 * view.frame.width
        let h = 0.43 * w
        let x = (view.frame.width - w)/2
        let y = -h
        imvSplash.frame = CGRect(x: x, y: y, width: w, height: h)
        imvSplash.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        UIView.animate(withDuration: 2) {
            self.imvSplash.frame.origin.y = (self.view.frame.height - self.imvSplash.frame.height)/2
            self.imvSplash.alpha = 1.0
        } completion: { respuesta in
            self.performSegue(withIdentifier: "sgSplash", sender: nil)
        }
    }

}
