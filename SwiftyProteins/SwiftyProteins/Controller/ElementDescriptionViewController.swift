//
//  ElementDescriptionViewController.swift
//  SwiftyProteins
//
//  Created by Viktoriia LIKHOTKINA on 10/10/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit
import NotificationCenter

class ElementDescriptionViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var appearanceLabel: UILabel!
    @IBOutlet weak var atomicMassLabel: UILabel!
    @IBOutlet weak var boilLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var densityLabel: UILabel!
    @IBOutlet weak var discoveredByLabel: UILabel!
    @IBOutlet weak var meltLabel: UILabel!
    @IBOutlet weak var molarHeatLabel: UILabel!
    @IBOutlet weak var phaseLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var element: ElementModel.Element?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if element != nil {
            displayInfo()
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func displayInfo() {
        nameLabel.text = "Name: " + (element?.name ?? "Unknown")
        appearanceLabel.text = "Appearance: " + (element?.appearance ?? "Unknown")
        atomicMassLabel.text = "Atomic mass: " + String(element!.atomicMass ?? 0)
        boilLabel.text =  "Boil: " + String(element?.boil ?? 0)
        categoryLabel.text = "Category: " + (element?.category ?? "Unknown")
        densityLabel.text =  "Density: " + String(element?.density ?? 0)
        discoveredByLabel.text = "Discovered by: " + (element?.discoveredBy ?? "Unknown")
        meltLabel.text =  "Melt: " + String(element?.melt ?? 0)
        molarHeatLabel.text =  "Molar heat: " + String(element?.molarHeat ?? 0)
        phaseLabel.text = "Phase: " + (element?.phase ?? "Unknown")
        descriptionLabel.text = "Description: " + (element?.summary ?? "Unknown")
    }
}

