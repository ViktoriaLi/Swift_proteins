//
//  NodeCreator.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/23/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit
import SceneKit

enum ModelDesign {
    case classic, inverse, eco
}

class NodeCreator {
    
    class func makeAtom(with params: AtomDescription, style: ModelDesign) -> SCNNode {
        let node = SCNNode()
        node.geometry = SCNSphere(radius: 0.3)
        node.position = SCNVector3(params.x, params.y, params.z)
        if style == .classic {
            node.geometry?.firstMaterial?.diffuse.contents = cpkColor(atomType: params.type)
        } else {
            node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "water")
        }
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        node.name = String(params.type)
        return node
    }
    
    class func makeAtomOriginal(from old: SCNNode) -> SCNNode {
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.6, height: 0.6, length: 0.6, chamferRadius: 0.1)
        node.position = SCNVector3(old.position.x, old.position.y, old.position.z)
        node.geometry?.firstMaterial?.diffuse.contents = cpkColor(atomType: Substring(old.name!)).inverse()
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        node.geometry?.firstMaterial?.lightingModel = .blinn
        node.name = old.name
        return node
    }
    

    class func cpkColor(atomType: Substring) -> UIColor {
        switch atomType {
        case "C":
            return UIColor(red: 200, green: 200, blue: 200, alpha: 1)
        case "H":
            return UIColor.lightGray
        case "O":
            return UIColor.red
        case "N":
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        case "S":
            return UIColor.yellow
        case "P", "Fe", "Ba":
            return UIColor.orange
        case "Na":
            return UIColor.purple
        case "Mg":
            return #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        case "Ca", "Mn", "Cr", "Al", "Ti", "Ag":
            return #colorLiteral(red: 0.4352941215, green: 0.4431372583, blue: 0.4745098054, alpha: 1)
        case "Zn", "Cu", "Ni", "Br":
            return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        case "Cl", "B":
            return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case "F", "Si", "Au":
            return #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        case "I":
            return #colorLiteral(red: 0.9686274529, green: 0.401878486, blue: 0.9267960709, alpha: 1)
        case "Li":
            return #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        case "He":
            return #colorLiteral(red: 0.9665093591, green: 0.02991147152, blue: 0.4324507566, alpha: 0.5)
        default:
            return #colorLiteral(red: 0.9548583463, green: 0.2837072, blue: 0.5408555939, alpha: 1)
        }
    }
    
    class func makeCylinderOriginal(parent: SCNNode, child: SCNNode) -> SCNNode {
        let rootNode = SCNNode()
        
        let endNode = SCNNode()
        
        var distance = sqrt(pow(child.position.x - parent.position.x, 2) + pow(child.position.y - parent.position.y, 2) + pow(child.position.z - parent.position.z, 2))
        if distance < 0 {
            distance *= -1
        }
        rootNode.position = parent.position
        endNode.position = child.position
        rootNode.addChildNode(endNode)
        
        let zAxisNode = SCNNode()
        zAxisNode.eulerAngles.x = Float(CGFloat(Double.pi / 2))
        
        let node = SCNNode()
        node.geometry = SCNTube(innerRadius: 0.1, outerRadius: 0.1, height: CGFloat(distance))
        
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.white.inverse()
        node.position.y = Float(-distance/2)
        zAxisNode.addChildNode(node)
        rootNode.addChildNode(zAxisNode)
        rootNode.constraints = [SCNLookAtConstraint(target: child)]
        
        return rootNode
    }
    
    class func makeCylinder(with params: AtomDescription, parent: SCNNode, child: SCNNode, style: ModelDesign) -> SCNNode {
        let rootNode = SCNNode()
        
        let endNode = SCNNode()
        
        var distance = sqrt(pow(child.position.x - parent.position.x, 2) + pow(child.position.y - parent.position.y, 2) + pow(child.position.z - parent.position.z, 2))
        if distance < 0 {
            distance *= -1
        }
        rootNode.position = parent.position
        endNode.position = child.position
        rootNode.addChildNode(endNode)
        
        let zAxisNode = SCNNode()
        zAxisNode.eulerAngles.x = Float(CGFloat(Double.pi / 2))
        
        let node = SCNNode()
        node.geometry = SCNCylinder(radius: 0.1, height: CGFloat(distance))
        
        if style == .classic {
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        } else {
            node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "wood")
        }
        node.position.y = Float(-distance/2)
        zAxisNode.addChildNode(node)
        rootNode.addChildNode(zAxisNode)
        rootNode.constraints = [SCNLookAtConstraint(target: child)]
        
        return rootNode
    }
}

