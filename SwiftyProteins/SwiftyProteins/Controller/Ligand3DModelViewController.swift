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
    
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var rotationGesture: UIRotationGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapGesture.delegate = self
        pinchGesture.delegate = self
        panGesture.delegate = self
        rotationGesture.delegate = self
        
        setScene()
        setCamera()
        build3DModel()
    }
    
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location: CGPoint = sender.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            if !hits.isEmpty, let tappedNode = hits.first?.node, tappedNode.name != nil {
                
                showAtomDescription(tappedNode: tappedNode)
            }
        }
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
        default:
            for atom in atomNodes {
                if let index = atomNodes.firstIndex(of: atom) {
                    atomNodes.remove(at: index)
                }
                atom.removeFromParentNode()
            }
            for atom in atomInfos {
                let node = NodeCreator.makeAtom(with: atom)
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
                    let newConnection = NodeCreator.makeCylinder(with: atom, parent: atomNodes[atom.number - 1], child: atomNodes[connection - 1])
                    connectionNodes.append(newConnection)
                    scene.rootNode.addChildNode(newConnection)
                }
            }
            sceneView.backgroundColor = UIColor.black
        }
    }
    
    func showAtomDescription(tappedNode : SCNNode) {
        let text = SCNText(string: tappedNode.name, extrusionDepth: 0)
        let font = UIFont(name: "Futura", size: 0.5)
        text.font = font
        text.flatness = 0.005
        text.alignmentMode = CATextLayerAlignmentMode.natural.rawValue
        text.firstMaterial?.diffuse.contents = UIColor.white
        //text.firstMaterial?.specular.contents = UIColor.black
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
    
    var geometryNode: SCNNode = SCNNode()
    
    func setCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        sceneView.pointOfView = cameraNode
        scene.rootNode.addChildNode(cameraNode)
    }
    
    @IBAction func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard sender.view != nil else { return }
        
        if sender.state == .began || sender.state == .changed {
            sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
            sender.scale = 1.0
        }
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
                    let node = NodeCreator.makeAtom(with: atom)
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
                    let newConnection = NodeCreator.makeCylinder(with: atom, parent: atomNodes[atom.number - 1], child: atomNodes[connection - 1])
                    connectionNodes.append(newConnection)
                    scene.rootNode.addChildNode(newConnection)
                }
            }
            print("atomInfos2")
            print(atomInfos)
        }
    }

    var currentAngle: Float = 0.0
    
    @objc func panGestureAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        var newAngle = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngle += currentAngle
        
        scene.rootNode.transform = SCNMatrix4MakeRotation(newAngle, 1, 1, 1)
        
        if(sender.state == UIGestureRecognizer.State.ended) {
            currentAngle = newAngle
        }
    }
    
    @IBAction func rotationAction(_ sender: UIRotationGestureRecognizer) {
        
    }
    
}

extension Ligand3DModelViewController: UIGestureRecognizerDelegate {
    
}


extension UIColor {
    func inverse() -> UIColor {
        var r:CGFloat = 0.0; var g:CGFloat = 0.0; var b:CGFloat = 0.0; var a:CGFloat = 0.0;
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        return .black // Return a default colour
    }
}
