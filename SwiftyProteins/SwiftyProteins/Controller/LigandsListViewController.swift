//
//  LigandsListViewController.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/19/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit

class LigandsListViewController: UITableViewController {

    @IBOutlet weak var proteinsSearchBar: UISearchBar!
    
    var proteinsList: [String] = []
    var filteredProteins: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        proteinsSearchBar.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        if let sourceFile = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            if let data = try? String(contentsOfFile: sourceFile, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                proteinsList = data.components(separatedBy: "\n")
            }
        }
        filteredProteins = proteinsList
    }
    
}

extension LigandsListViewController {
    
    func loadPDBFile(ligand: String) {
        let directory = Array(ligand)[0]
        guard let url = URL(string: "https://files.rcsb.org/ligands/\(directory)/\(ligand)/\(ligand)_ideal.pdb") else { return }
        print(url)
        let task = URLSession.shared.downloadTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    if let fileContent = try? String(contentsOf: data) {
                        print(fileContent)
                        let storyboard = UIStoryboard(name: "Ligand3DModelStoryboard", bundle: nil)
                        let newController = storyboard.instantiateViewController(withIdentifier: "ligand2dID") as? Ligand3DModelViewController
                        if let controller = newController {
                            controller.ligandInfo = fileContent
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    
                        //completionHandler(pdbfile)
                    }
                }
            }
        }
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadPDBFile(ligand: filteredProteins[indexPath.row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProteins.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        cell.textLabel?.text = filteredProteins[indexPath.row]
        
        return cell
    }
}

extension LigandsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredProteins = searchText.isEmpty ? proteinsList : proteinsList.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
}
