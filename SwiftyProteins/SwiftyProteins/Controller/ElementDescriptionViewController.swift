//
//  ElementDescriptionViewController.swift
//  SwiftyProteins
//
//  Created by Viktoriia LIKHOTKINA on 10/10/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit

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
    }
    
    func displayInfo() {
        nameLabel.text = element?.name ?? "Unknown"
        appearanceLabel.text = element?.appearance ?? "Unknown"
        atomicMassLabel.text = String(element!.atomicMass ?? 0)
        boilLabel.text =  String(element?.boil ?? 0)
        categoryLabel.text = element?.category ?? "Unknown"
        densityLabel.text =  String(element?.density ?? 0)
        discoveredByLabel.text = element?.discoveredBy ?? "Unknown"
        meltLabel.text =  String(element?.melt ?? 0)
        molarHeatLabel.text =  String(element?.molarHeat ?? 0)
        phaseLabel.text = element?.phase ?? "Unknown"
        descriptionLabel.text = element?.summary ?? "Unknown"
    }
}
