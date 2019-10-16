//
//  ViewController.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/19/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol SuccessAuth {
    func goToLigands()
}

class SignInViewController: UIViewController, SuccessAuth {

    let touchMe = BiometricIDAuth()
    
    @IBOutlet weak var touchIDButton: UIButton!
    
    @IBAction func toichIDAction(_ sender: UIButton) {
        touchAction()
    }
    
    func touchAction() {
        touchMe.authenticateUser() { [weak self] message in
            if message != nil {
                let alertView = UIAlertController(title: "Go to Sign in",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)
                
            } else {
                /*let alertView = UIAlertController(title: "You can try this optionon real device",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)*/
                self?.goToLigands()
            }
        }
    }
    
    func goToLigands() {
        let storyboard = UIStoryboard(name: "LigandsListStoryboard", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "ligandsListID") as? LigandsListViewController
        if let controller = newController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touchMe.currentVC = self
        assignbackground()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "joel-filipe-Mbf3xFiC1Zo-unsplash"))
        switch touchMe.biometricType() {
        case .faceID:
            touchIDButton.setImage(UIImage(named: "icons8-face-id-100"),  for: .normal)
        default:
            touchIDButton.setImage(UIImage(named: "icons8-touch-id-100"),  for: .normal)
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let touchBool = touchMe.canEvaluatePolicy()
//        if touchBool {
//            touchAction()
//        }
//    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
//        let storyboard = UIStoryboard(name: "LigandsListStoryboard", bundle: nil)
//        let newController = storyboard.instantiateViewController(withIdentifier: "ligandsListID") as? LigandsListViewController
//        if let controller = newController {
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
    }
    
    
    func assignbackground(){
        let background = UIImage(named: "joel-filipe-Mbf3xFiC1Zo-unsplash")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}


