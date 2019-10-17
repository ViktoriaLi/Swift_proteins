//
//  LigandsListViewController.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/19/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit
import NotificationCenter

class LigandsListViewController: UITableViewController {

    @IBOutlet weak var proteinsSearchBar: UISearchBar!
    
    var proteinsList: [String] = []
    var filteredProteins: [String] = []
    var activityIndicator = UIActivityIndicatorView()
    let loadMessage = "Please check wi-fi connection or correct section!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivityIndicatory()
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        proteinsSearchBar.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        if let sourceFile = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            if let data = try? String(contentsOfFile: sourceFile, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                proteinsList = data.components(separatedBy: "\n")
            }
        }
        filteredProteins = proteinsList
    }
    
    @objc func appMovedToBackground() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func goAlertProcessing() {
        let alert = UIAlertController(title: "Error loading ligands", message: loadMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActivityIndicatory() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.backgroundColor = UIColor.clear
    }
}

extension LigandsListViewController {
    
    func loadPDBFile(ligand: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
                            print("\n\n\nactivity monitor here\n\n\n")
                            controller.ligandInfo = fileContent
                            controller.ligandCode = ligand
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidesWhenStopped = true
                    }
                }
                else {
                    print("\n\n\n\n\n\n")
                    print ("ERRRROOORRR")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                    self.goAlertProcessing()
                    print("\n\n\n\n\n\n")
                }
            }
        }
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadPDBFile(ligand: filteredProteins[indexPath.row])
        activityIndicator.startAnimating()
        activityIndicator.backgroundColor = UIColor.clear
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
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
