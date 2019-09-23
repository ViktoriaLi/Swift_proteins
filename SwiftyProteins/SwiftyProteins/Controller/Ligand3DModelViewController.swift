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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setScene()
        setCamera()
        build3DModel()
    }

    func setScene() {
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.lightGray
        sceneView.autoenablesDefaultLighting = true
    }
    
    func setCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 30)
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
        
        /*var i: Int = 0
         let atomsRange = atoms.count
         let parent: Int = Int(elementInfo[1])! - 1
         for element in elementInfo {
         let child = (Int(element) ?? 0) - 1
         if i > 1 {
         if (parent < atomsRange && child < atomsRange) {
         
         let rootNode = SCNNode()
         
         let startNode = SCNNode()
         let endNode = SCNNode()
         
         startNode.position = atoms[parent].position
         endNode.position = atoms[child].position
         
         let zAxisNode = SCNNode()
         zAxisNode.eulerAngles.x = Float(CGFloat(Double.pi / 2))
         
         let height = CGFloat(Float(sqrt((atoms[child].position.x - atoms[parent].position.x) * (atoms[child].position.x - atoms[parent].position.x) + (atoms[child].position.y - atoms[parent].position.y) * (atoms[child].position.y - atoms[parent].position.y) + (atoms[child].position.z - atoms[parent].position.z) * (atoms[child].position.z - atoms[parent].position.z))))
         
         
         
         let node = SCNNode()
         node.geometry = SCNCylinder(radius: 0.1, height: height)
         
         node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
         node.geometry?.firstMaterial?.isDoubleSided = true
         //node.geometry?.firstMaterial?.specular.contents = UIColor.white
         node.position.y = Float(-height/2)
         
         node.position.y = Float(-height/2)
         zAxisNode.addChildNode(node)
         
         zAxisNode.addChildNode(node)
         startNode.addChildNode(zAxisNode)
         endNode.addChildNode(zAxisNode)
         rootNode.addChildNode(startNode)
         rootNode.addChildNode(endNode)
         
         scene.rootNode.addChildNode(rootNode)
         
         
         
         
         //let newConnection = AtomConnections(v1: (atoms[parent]?.position)!, v2: (atoms[Int(element)! - 1]?.position)!)
         //newConnection.name = "CONECT"
         
         }
         }
         i += 1
         }*/
        
        
        /*let floor = SCNNode()
        
        floor.geometry = SCNFloor()
        floor.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(floor)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 3, 10)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
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
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        
        hittedObj.geometry?.firstMaterial?.emission.contents = oldColor
        
        let hitList = sceneView.hitTest(location, options: nil)
        if let hitObject = hitList.first {
            for currAtom in descData{
                if currAtom.symb?.lowercased() == hitObject.node.name?.lowercased() {
                    
                    melt.text = "Melting point: --"
                    boil.text = "Boiling point: --"
                    name.text = "Full Name: --"
                    descript.text = "--"
                    mass.text = "Atomic mass: --"
                    
                    if let temp = currAtom.melt {
                        melt.text = "Melting point: \(String(describing: temp))°C"
                    }
                    if let temp = currAtom.name {
                        name.text = "Full Name: \(temp)"
                    }
                    if let temp = currAtom.boil {
                        boil.text = "Boiling point: \(String(describing: temp))°C"
                    }
                    if let temp = currAtom.atomic_mass {
                        mass.text = "Atomic mass: \(String(describing: temp))"
                    }
                    descript.text = currAtom.summary
                }
            }
            hittedObj = hitObject.node
            oldColor = hitObject.node.geometry?.firstMaterial?.emission.contents as! UIColor
            hitObject.node.geometry?.firstMaterial?.emission.contents = UIColor.flatMint
        } else {
            melt.text = nil
            boil.text = nil
            name.text = nil
            descript.text = nil
            mass.text = nil
        }
    }*/
}
