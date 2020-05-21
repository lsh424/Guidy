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
    case blue = "blue"
    case white = "white"
    case black = "black"
}

func getReferenceSphereNode(forStrokeColor color: StrokeColor) ->  SCNNode {
    switch color {
    case .red:
        return redSphereNode
    case .blue:
        return blueSphereNode
    case .white:
        return whiteSphereNode
    case .black:
        return blackSphereNode
    }
}

var radius: CGFloat = 0.015 {
    didSet{
        let whiteSphere = SCNSphere(radius: radius)
        whiteSphere.firstMaterial?.diffuse.contents = UIColor.white
        whiteSphereNode = SCNNode(geometry: whiteSphere)
        
        let redSphere = SCNSphere(radius: radius)
        redSphere.firstMaterial?.diffuse.contents = UIColor.red
        redSphereNode = SCNNode(geometry: redSphere)
        
        let blackSphere = SCNSphere(radius: radius)
        blackSphere.firstMaterial?.diffuse.contents = UIColor.black
        blackSphereNode = SCNNode(geometry: blackSphere)
        
        let blueSphere = SCNSphere(radius: radius)
        blueSphere.firstMaterial?.diffuse.contents = UIColor.blue
        blueSphereNode = SCNNode(geometry: blueSphere)
    }
}

var redSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: radius)
    sphere.firstMaterial?.diffuse.contents = UIColor.red
    return SCNNode(geometry: sphere)
}()

var blueSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: radius)
    sphere.firstMaterial?.diffuse.contents = UIColor.blue
    return SCNNode(geometry: sphere)
}()

var whiteSphereNode: SCNNode = {
    print("white node \(radius)")
    let sphere = SCNSphere(radius: radius) // 0.03 -> 40, 0.025 -> 30, 0.015 -> 25, -> 20, -> 15
    sphere.firstMaterial?.diffuse.contents = UIColor.white
    return SCNNode(geometry: sphere)
}()

var blackSphereNode: SCNNode = {
    let sphere = SCNSphere(radius: radius)
    sphere.firstMaterial?.diffuse.contents = UIColor.black
    return SCNNode(geometry: sphere)
}()
