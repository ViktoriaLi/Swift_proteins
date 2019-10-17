//
//  ViewController.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/19/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit
import LocalAuthentication

class SignInViewController: UIViewController {

    let touchMe = BiometricIDAuth()
    
    @IBOutlet weak var touchIDButton: UIButton!
    
    @IBAction func toichIDAction(_ sender: UIButton) {
        touchAction()
    }
    
    @IBOutlet weak var simpleSignInButton: UIButton!
    
    func touchAction() {
        touchMe.authenticateUser() { [weak self] message, ifCancel in
            if let message = message, ifCancel == false {
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true, completion: {
                    switch UIDevice.current.orientation {
                    case .landscapeRight:
                        alertView.view.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
                    case .landscapeLeft:
                        alertView.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                    default:
                        alertView.view.transform = CGAffineTransform.identity
                    }
                })
            }
            else if ifCancel == true {
                self?.touchMe.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "You need authorization") { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self?.goToLigands()
                            print("FIRST goToLigands")
                            
                        } else {
                            print("touchMe false")
                        }
                    }
                }
            }
            else {
                self?.goToLigands()
                print("SECOND goToLigands")
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
        touchIDButton.layer.cornerRadius = touchIDButton.frame.height / 2
        switch touchMe.biometricType() {
        case .faceID:
            touchIDButton.setImage(UIImage(named: "icons8-face-id-101"),  for: .normal)
            simpleSignInButton.isHidden = true
            touchIDButton.isHidden = false
        case .touchID:
            touchIDButton.setImage(UIImage(named: "icons8-touch-id-144"),  for: .normal)
            simpleSignInButton.isHidden = true
            touchIDButton.isHidden = false
        default:
            simpleSignInButton.isHidden = false
            touchIDButton.isHidden = true
        }
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        goToLigands()
    }
}


