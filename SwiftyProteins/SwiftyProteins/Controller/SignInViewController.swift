//
//  ViewController.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/19/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "LigandsListStoryboard", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "ligandsListID") as? LigandsListViewController
        if let controller = newController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}


