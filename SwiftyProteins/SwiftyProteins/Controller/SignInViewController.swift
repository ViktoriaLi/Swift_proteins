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

    let myContext = LAContext()
    let myLocalizedReasonString = "Biometric Authntication testing !! "
    var authError: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "LigandsListStoryboard", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "ligandsListID") as? LigandsListViewController
        if let controller = newController {
            self.navigationController?.pushViewController(controller, animated: true)
            loginWithTouchID()
        }
    }
    
    func loginWithTouchID() {
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    DispatchQueue.main.async {
                        if success {
//                            self.successLabel.text = "Awesome!!... User authenticated successfully"
                            print("\n\n\nAwesome!!... User authenticated successfully\n\n\n")
                        } else {
//                            self.successLabel.text = "Sorry!!... User did not authenticate successfully"
                            print("\n\n\nSorry!!... User did not authenticate successfully\n\n\n")
                        }
                    }
                }
            } else {
//                successLabel.text = "Sorry!!.. Could not evaluate policy."
                print("\n\n\nSorry!!.. Could not evaluate policy.\n\n\n")
            }
        } else {
//            successLabel.text = "Ooops!!.. This feature is not supported."
            print("\n\n\nOoops!!.. This feature is not supported.\n\n\n")
        }
    }
}


