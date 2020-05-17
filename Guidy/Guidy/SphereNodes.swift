//
//  SphereNodes.swift
//  Capstone AR Drawing
//
//  Created by seunghwan Lee on 2019/11/28.
//  Copyright © 2019 seunghwan Lee. All rights reserved.
//

import SceneKit

enum StrokeColor: String {
    case red = "red"
    case green = "green"
    case blue = "blue"
    case white = "white"
    case black = "black"
}

func getReferenceSphereNode(forStrokeColor color: StrokeColor) ->  SCNNode {
    switch color {
    case .red:
        return redSphereNode
    case .green:
        return greenSphereNode
    case .blue:
        return blueSphereNode
    case .white:
        return whiteSphereNode
    case .black:
        return blackSphereNode
    }
}

var redSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: 0.004)
    sphere.firstMaterial?.diffuse.contents = UIColor.red
    return SCNNode(geometry: sphere)
}()

var greenSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: 0.004)
    sphere.firstMaterial?.diffuse.contents = UIColor.green
    return SCNNode(geometry: sphere)
}()

var blueSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: 0.004)
    sphere.firstMaterial?.diffuse.contents = UIColor.blue
    return SCNNode(geometry: sphere)
}()

var whiteSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: 0.025) // 0.03 -> 40, 0.025 -> 30, 0.015 -> 25, -> 20, -> 15
    sphere.firstMaterial?.diffuse.contents = UIColor.white
    return SCNNode(geometry: sphere)
}()

var blackSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: 0.004)
    sphere.firstMaterial?.diffuse.contents = UIColor.black
    return SCNNode(geometry: sphere)
}()
