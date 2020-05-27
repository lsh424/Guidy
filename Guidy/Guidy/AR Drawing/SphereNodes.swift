//
//  SphereNodes.swift
//  Capstone AR Drawing
//
//  Created by seunghwan Lee on 2019/11/28.
//  Copyright © 2019 seunghwan Lee. All rights reserved.
//

import SceneKit

enum StrokeColor: String {
    case white = "white"
    case selectedColor = "selectedColor"
}

func getReferenceSphereNode(forStrokeColor color: StrokeColor) ->  SCNNode {
    switch color {
    case .white:
        return whiteSphereNode
    case .selectedColor:
        return selectedColorNode
    }
}

var radius: CGFloat = 0.005 {
    didSet{
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        selectedColorNode = SCNNode(geometry: sphere)
    }
}

var color: UIColor = UIColor.white {
    didSet{
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        selectedColorNode = SCNNode(geometry: sphere)
    }
}

var whiteSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: radius)
    sphere.firstMaterial?.diffuse.contents = UIColor.white
    return SCNNode(geometry: sphere)
}()

var selectedColorNode: SCNNode = {
    let sphere = SCNSphere(radius: radius)
    sphere.firstMaterial?.diffuse.contents = UIColor.white
    return SCNNode(geometry: sphere)
}()
