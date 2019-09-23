//
//  NodeCreator.swift
//  SwiftyProteins
//
//  Created by Mac Developer on 9/23/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import UIKit
import SceneKit

class NodeCreator {
    
    class func makeAtom(with params: AtomDescription) -> SCNNode {
        let node = SCNNode()
        node.geometry = SCNSphere(radius: 0.3)
        node.position = SCNVector3(params.x, params.y, params.z)
        node.geometry?.firstMaterial?.diffuse.contents = cpkColor(atomType: params.type)
        
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
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
            return UIColor(red: 143, green: 143, blue: 255, alpha: 1)
        case "S":
            return UIColor(red: 255, green: 200, blue: 50, alpha: 1)
        case "P", "Fe", "Ba":
            return UIColor(red: 255, green: 165, blue: 0, alpha: 1)
        case "Na":
            return UIColor(red: 0, green: 0, blue: 255, alpha: 1)
        case "Mg":
            return UIColor(red: 34, green: 139, blue: 34, alpha: 1)
        case "Ca", "Mn", "Cr", "Al", "Ti", "Ag":
            return UIColor(red: 128, green: 128, blue: 144, alpha: 1)
        case "Zn", "Cu", "Ni", "Br":
            return UIColor(red: 165, green: 42, blue: 42, alpha: 1)
        case "Cl", "B":
            return UIColor(red: 0, green: 255, blue: 0, alpha: 1)
        case "F", "Si", "Au":
            return UIColor(red: 218, green: 165, blue: 32, alpha: 1)
        case "I":
            return UIColor(red: 160, green: 32, blue: 240, alpha: 1)
        case "Li":
            return UIColor(red: 178, green: 34, blue: 34, alpha: 1)
        case "He":
            return UIColor(red: 255, green: 192, blue: 203, alpha: 1)
        default:
            return UIColor(red: 255, green: 20, blue: 147, alpha: 1)
        }
    }
    
    class func makeCylinder(with params: AtomDescription, parent: SCNNode, child: SCNNode) -> SCNNode {
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
        
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        node.position.y = Float(-distance/2)
        zAxisNode.addChildNode(node)
        rootNode.addChildNode(zAxisNode)
        rootNode.constraints = [SCNLookAtConstraint(target: child)]
        
        return rootNode
    }
}

