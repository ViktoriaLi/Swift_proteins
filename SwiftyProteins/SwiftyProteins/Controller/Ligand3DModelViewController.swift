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
    var atomInfos = [AtomDescription]()
    
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var rotationGesture: UIRotationGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
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
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
                
                let textTodraw = SCNText(string: tappedNode!.name, extrusionDepth: 1)
                textTodraw.firstMaterial?.transparency = 1
                textTodraw.firstMaterial?.diffuse.contents = UIColor.yellow
                let textNode = SCNNode(geometry: textTodraw)
                textNode.position = tappedNode!.position
                tappedNode?.addChildNode(textNode)
                /*let label = UILabel(frame: CGRect(x: 0, y: 35, width: 200, height: 30))
                label.font = UIFont.systemFont(ofSize: 30)
                view.addSubview(label)
                label.textAlignment = .center
                label.text = "25"
                label.textColor = .white*/
                
                
                //tappedNode?.geometry?.firstMaterial?.diffuse.contents = label
            }
        }
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
                    scene.rootNode.addChildNode(newConnection)
                }
            }
            print("atomInfos2")
            print(atomInfos)
        }
        
    
        
        
        /*let floor = SCNNode()
        
        floor.geometry = SCNFloor()
        floor.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(floor)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 3, 10)
        scene.rootNode.addChildNode(cameraNode)
 
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLight.LightType.ambient
        scene.rootNode.addChildNode(ambientLightNode)
        
        let omnidirectionalLightNode = SCNNode()
        omnidirectionalLightNode.light = SCNLight()
        omnidirectionalLightNode.position = SCNVector3(0, 5, 10)
        omnidirectionalLightNode.light?.type = SCNLight.LightType.omni
        scene.rootNode.addChildNode(omnidirectionalLightNode)
        
        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.position = SCNVector3(0, 10, 0)
        spotLightNode.eulerAngles = SCNVector3(0 *  Float((Double.pi) / 180), 0 *  Float((Double.pi) / 180), 0 *  Float((Double.pi) / 180))
        spotLightNode.light?.type = SCNLight.LightType.spot
        scene.rootNode.addChildNode(spotLightNode)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5.0
        spotLightNode.position = SCNVector3(0, 15, 0)
        spotLightNode.eulerAngles = SCNVector3(-90 *  Float((Double.pi) / 180), 0 *  Float((Double.pi) / 180), 0 *  Float((Double.pi) / 180))
        
        SCNTransaction.commit()*/
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
