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
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        return node
    }

    class func makeCylinder(with params: AtomDescription, parent: SCNNode, child: SCNNode) -> SCNNode {
        let rootNode = SCNNode()
        
        let endNode = SCNNode()
        
        let distance = sqrt(pow(child.position.x - parent.position.x, 2) + pow(child.position.y - parent.position.y, 2) + pow(child.position.z - parent.position.z, 2))
        
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

