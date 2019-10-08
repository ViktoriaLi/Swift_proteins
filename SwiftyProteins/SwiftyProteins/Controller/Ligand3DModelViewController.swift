//
//  Ligand3DModelViewController.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/19/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit
import SceneKit

struct AtomDescription {
    var number: Int = 0
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    var type: Substring = ""
    var connections = [Int]()
}

class Ligand3DModelViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!
    
    var ligandInfo: String = ""
    let scene = SCNScene()
    var atomNodes = [SCNNode]()
    var connectionNodes = [SCNNode]()
    var atomInfos = [AtomDescription]()
    var ligandCode = ""
    var currentAngle: Float = 0.0
    var ifPresent = false
    
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var pdbxTypeLabel: UILabel!
    @IBOutlet weak var formulaLabel: UILabel!
    
    @IBOutlet weak var elementName: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var elementInfoView: UIView!
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapGesture.delegate = self
        pinchGesture.delegate = self
        panGesture.delegate = self
        
        if ligandCode != "" {
            loadLigandDescription()
        }
        
        setScene()
        setCamera()
        build3DModel()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
//        print("\n\n\nshared pressed\n\n\n")
        let activityViewController = UIActivityViewController(activityItems: ["check"], applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    func loadLigandDescription() {
        guard let url = URL(string: "http://files.rcsb.org/ligands/view/\(ligandCode).cif") else { return }
        print(url)
        let task = URLSession.shared.downloadTask(with: url) { data, response, error in
            DispatchQueue.global().async {
                if let data = data {
                    if let fileContent = try? String(contentsOf: data) {
                        print("fileContent")
                        print(fileContent)
                        DispatchQueue.main.async {
                            let descriptionArray = fileContent.split(separator: "\n")
                            for i in 0..<descriptionArray.count {
                                let strArray = descriptionArray[i].split(separator: " ")
                                if strArray[0] == "_chem_comp.name" {
                                    self.nameLabel.text = "Name: Unknown"
                                    if strArray.count > 1 {
                                        self.nameLabel.text = "Name: " + String(strArray[1]).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                                    } else {
                                        if descriptionArray.count > i + 1 {
                                            self.nameLabel.text = "Name: " + descriptionArray[i + 1].trimmingCharacters(in: CharacterSet(charactersIn: "\";"))
                                        }
                                    }
                                } else if strArray[0] == "_chem_comp.type" {
                                    self.typeLabel.text = "Type: Unknown"
                                    if strArray.count > 1 {
                                        var type = ""
                                        for i in 1..<strArray.count {
                                            type += String(strArray[i]) + " "
                                        }
                                        self.typeLabel.text = "Type: " + type.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                                    }
                                } else if strArray[0] == "_chem_comp.pdbx_type" {
                                    self.pdbxTypeLabel.text = "PDBX Type: Unknown"
                                    if strArray.count > 1 {
                                        self.pdbxTypeLabel.text = "PDBX Type: " + String(strArray[1])
                                    }
                                } else if strArray[0] == "_chem_comp.formula" {
                                    self.formulaLabel.text = "Formula: Unknown"
                                    if strArray.count > 1 {
                                        var formula = ""
                                        for i in 1..<strArray.count {
                                            formula += String(strArray[i]) + " "
                                        }
                                        self.formulaLabel.text = "Formula: " + formula.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 1:
            for atom in atomNodes {
                let newNode = NodeCreator.makeAtomOriginal(from: atom)
                sceneView.scene?.rootNode.addChildNode(newNode)
                atom.removeFromParentNode()
                if let index = atomNodes.firstIndex(of: atom) {
                    atomNodes.remove(at: index)
                }
                formulaLabel.textColor = .black
                typeLabel.textColor = .black
                nameLabel.textColor = .black
                pdbxTypeLabel.textColor = .black
                atomNodes.append(newNode)
                //remove from array and add new
            }
            for connection in connectionNodes {
                connection.removeFromParentNode()
                if let index = connectionNodes.firstIndex(of: connection) {
                    connectionNodes.remove(at: index)
                }
            }
            
            for atom in atomInfos {
                for connection in atom.connections {
                    let newConnection = NodeCreator.makeCylinderOriginal(parent: atomNodes[atom.number - 1], child: atomNodes[connection - 1])
                    connectionNodes.append(newConnection)
                    scene.rootNode.addChildNode(newConnection)
                }
            }
            sceneView.backgroundColor = UIColor.black.inverse()
            elementName.textColor = UIColor.black
        default:
            for atom in atomNodes {
                if let index = atomNodes.firstIndex(of: atom) {
                    atomNodes.remove(at: index)
                }
                atom.removeFromParentNode()
            }
            for atom in atomInfos {
                var node = SCNNode()
                if sender.selectedSegmentIndex == 2 {
                    node = NodeCreator.makeAtom(with: atom, style: .eco)
                } else {
                    node = NodeCreator.makeAtom(with: atom, style: .classic)
                }
                scene.rootNode.addChildNode(node)
                atomNodes.append(node)
            }
            for connection in connectionNodes {
                connection.removeFromParentNode()
                if let index = connectionNodes.firstIndex(of: connection) {
                    connectionNodes.remove(at: index)
                }
            }
            for atom in atomInfos {
                for connection in atom.connections {
                    var newConnection = SCNNode()
                    if sender.selectedSegmentIndex == 2 {
                        newConnection = NodeCreator.makeCylinder(with: atom, parent: atomNodes[atom.number - 1], child: atomNodes[connection - 1], style: .eco)
                    } else {
                        newConnection = NodeCreator.makeCylinder(with: atom, parent: atomNodes[atom.number - 1], child: atomNodes[connection - 1], style: .classic)
                    }
                    connectionNodes.append(newConnection)
                    scene.rootNode.addChildNode(newConnection)
                }
            }
            sceneView.backgroundColor = UIColor.black
            elementName.textColor = UIColor.white
            formulaLabel.textColor = .white
            typeLabel.textColor = .white
            nameLabel.textColor = .white
            pdbxTypeLabel.textColor = .white
        }
    }
    
    func showAtomDescription(tappedNode: SCNNode) {
        let text = SCNText(string: tappedNode.name, extrusionDepth: 0)
        let font = UIFont(name: "Futura", size: 0.5)
        text.font = font
        text.flatness = 0.005
        text.alignmentMode = CATextLayerAlignmentMode.natural.rawValue
        if sceneView.backgroundColor == UIColor.black {
            text.firstMaterial?.diffuse.contents = UIColor.white
        } else {
            text.firstMaterial?.diffuse.contents = UIColor.white.inverse()
        }
        text.firstMaterial?.isDoubleSided = true
        let textNode = SCNNode(geometry: text)
        textNode.position = tappedNode.position
        textNode.eulerAngles = tappedNode.eulerAngles
        sceneView.scene!.rootNode.addChildNode(textNode)
        
    }
    
    func setScene() {
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLight.LightType.omni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        sceneView.addGestureRecognizer(panRecognizer)
        view.addGestureRecognizer(pinchGesture)
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    func setCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        sceneView.pointOfView = cameraNode
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func build3DModel() {
        
        if ligandInfo.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            let proteinInfo = ligandInfo.split(separator: "\n")
            
            for element in proteinInfo {
                let elementInfo = element.split(separator: " ")
                if elementInfo[0] == "ATOM" {
                    var atom = AtomDescription()
                    atom.number = Int(elementInfo[1])!
                    atom.x = Double(elementInfo[6])!
                    atom.y = Double(elementInfo[7])!
                    atom.z = Double(elementInfo[8])!
                    atom.type = elementInfo[11]
                    atomInfos.append(atom)
                    let node = NodeCreator.makeAtom(with: atom, style: .classic)
                    scene.rootNode.addChildNode(node)
                    atomNodes.append(node)
                }
            }
            for element in proteinInfo {
                let elementInfo = element.split(separator: " ")
                if elementInfo[0] == "CONECT" {
                    if let index = atomInfos.firstIndex(where: {$0.number == Int(elementInfo[1])}) {
                        for i in 0..<elementInfo.count {
                            if i >= 2, let connection = Int(elementInfo[i]), connection > 0, connection <= atomInfos.count {
                                atomInfos[index].connections.append(connection)
                            }
                        }
                    }
                }
            }
            
            print("atomInfos1")
            print(atomInfos)
                
            for i in 0..<atomInfos.count {
                for connection in atomInfos[i].connections {
                    if let index = atomInfos[connection - 1].connections.firstIndex(of: i + 1) {
                        atomInfos[connection - 1].connections.remove(at: index)
                    }
                }
            }
            
            for atom in atomInfos {
                for connection in atom.connections {
                    let newConnection = NodeCreator.makeCylinder(with: atom, parent: atomNodes[atom.number - 1], child: atomNodes[connection - 1], style: .classic)
                    connectionNodes.append(newConnection)
                    scene.rootNode.addChildNode(newConnection)
                }
            }
            print("atomInfos2")
            print(atomInfos)
        }
    }

}

extension Ligand3DModelViewController: UIGestureRecognizerDelegate {
    @IBAction func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard sender.view != nil else { return }
        
        if sender.state == .began || sender.state == .changed {
            sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
            sender.scale = 1.0
        }
    }
    
    @objc func panGestureAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        var newAngle = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngle += currentAngle
        
        scene.rootNode.transform = SCNMatrix4MakeRotation(newAngle, 1, 1, 1)
        
        if(sender.state == UIGestureRecognizer.State.ended) {
            currentAngle = newAngle
        }
    }
    
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location: CGPoint = sender.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty, let tappedNode = hits.first?.node, tappedNode.name != nil {
                showAtomDescription(tappedNode: tappedNode)
                if tappedNode.name != nil {
                    showElementName(name: getElementFullName(shortName: tappedNode.name!))
                }
            }
        }
    }
    
    func getElementFullName(shortName: String) -> String {
        switch shortName {
        case "H":
            return "Hydrogen"
        case "C":
            return "Carbon"
        case "N":
            return "Nitrogen"
        case "O":
            return "Oxygen"
        case "F":
            return "Fluorine"
        case "Cl":
            return "Chlorine"
        case "Br":
            return "Bromine"
        case "I":
            return "Iodine"
        case "He":
            return "Helium"
        case "Ne":
            return "Neon"
        case "Ar":
            return "Argon"
        case "Xe":
            return "Xenon"
        case "Kr":
            return "Krypton"
        case "P":
            return "Phosphorus"
        case "S":
            return "Sulfur"
        case "B":
            return "Boron"
        case "Li":
            return "Lithium"
        case "Na":
            return "Sodium"
        case "K":
            return "Potassium"
        case "Rb":
            return "Rubidium"
        case "Cs":
            return "Caesium"
        case "Fr":
            return "Francium"
        case "Be":
            return "Beryllium"
        case "Mg":
            return "Magnesium"
        case "Ca":
            return "Calcium"
        case "Sr":
            return "Strontium"
        case "Ba":
            return "Barium"
        case "Ra":
            return "Radium"
        case "Ti":
            return "Titanium"
        case "Fe":
            return "Ferrum"
        default:
            return "Unknown"
        }
    }
    
    func showElementName(name: String) {
        elementName.text = name
        ifPresent = false
        self.elementInfoView.isHidden = true
        UIView.animate(withDuration: 1, animations: {
            self.elementInfoView.isHidden = false
            self.ifPresent = true
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            if self.ifPresent == true {
                self.elementInfoView.isHidden = true
                self.ifPresent = false
            }
        }
    }
}

enum Elements {
    
}

extension UIColor {
    func inverse() -> UIColor {
        var r:CGFloat = 0.0; var g:CGFloat = 0.0; var b:CGFloat = 0.0; var a:CGFloat = 0.0;
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        return .black
    }
}
