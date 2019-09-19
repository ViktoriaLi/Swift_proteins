//
//  LigandsListViewController.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/19/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit

class LigandsListViewController: UITableViewController {

    var proteinsList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        if let sourceFile = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            if let data = try? String(contentsOfFile: sourceFile, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                proteinsList = data.components(separatedBy: "\n")
            }
        }
    }
    
}

extension LigandsListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proteinsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        cell.textLabel?.text = proteinsList[indexPath.row]
        
        return cell
    }
}
