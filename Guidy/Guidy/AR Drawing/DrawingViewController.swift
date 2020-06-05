//
//  ViewController.swift
//  AR Project
//
//  Created by seunghwan Lee on 2020/02/09.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreLocation
import Alamofire

//protocol pushViewControllerDelegate {
//    func pushVC()
//}

class DrawingViewController: UIViewController,ARSCNViewDelegate, pushViewControllerDelegate {

    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var drawingOptionButton: UIButton!
    
    @IBOutlet weak var trackingStateView: UIView!
    @IBOutlet weak var trackingStateTitle: UILabel!
    @IBOutlet weak var trackingStateMessage: UILabel!
    
    @IBOutlet weak var dotSizeSlider: UISlider!
    
    
    @IBOutlet weak var drawingOptionView: UIView!
    
    var previousPoint: SCNVector3?
    var currentFingerPosition: CGPoint?
        
    var strokeAnchorIDs: [UUID] = []
    var currentStrokeAnchorNode: SCNNode?
    
    var currentStrokeColor: StrokeColor = .white
    
    let configuration = ARWorldTrackingConfiguration()
    
    var locationManager = CLLocationManager()
    
    var location: CLLocationCoordinate2D?
    var altitude: CLLocationDistance?
    var optionButtonColor: UIColor? = .white
    var isPressed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawingOptionView.layer.cornerRadius = self.view.frame.width / 20
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        UIApplication.shared.isIdleTimerDisabled = true
        sceneView.preferredFramesPerSecond = 60

        sceneView.delegate = self
        sceneView.session.delegate = self
                    
        let scene = SCNScene()
        sceneView.scene = scene
                
        sceneView.session.run(configuration)
        
    }
    
    @IBAction func didPressDelete(_ sender: Any) {
        for strokeAnchorID in strokeAnchorIDs {
            if let strokeAnchor = anchorForID(strokeAnchorID) {
                sceneView.session.remove(anchor: strokeAnchor)
            }
        }
        currentStrokeAnchorNode = nil
    }
    

    @IBAction func didPressGallery(_ sender: Any) {
       let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchArVC") as! SearchARViewContoller
        
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion: nil)
       self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didPressSave(_ sender: Any) {
        let img = sceneView.snapshot()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditingVC") as! EditingViewController
        
        vc.delegate = self
        vc.image = img
        vc.latitude = location!.latitude
        vc.longitude = location!.longitude
        vc.altitude = altitude!
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
//        NetworkManager().saveImage(lat: location!.latitude, lon: location!.longitude, altitude: altitude!, img: image)
    }
    
    @IBAction func didPressUndo(_ sender: Any) {
        sortStrokeAnchorIDsInOrderOfDateCreated()
        
        guard let currentStrokeAnchorID = strokeAnchorIDs.last, let curentStrokeAnchor = anchorForID(currentStrokeAnchorID) else {
            print("No stroke to remove")
            return
        }
        
        sceneView.session.remove(anchor: curentStrokeAnchor)

        currentStrokeAnchorNode = nil
    }
    
    @IBAction func didPressDrawingOption(_ sender: Any) {
        if !isPressed {
            drawingOptionView.isHidden = false
            isPressed = true
        } else {
            drawingOptionView.isHidden = true
            isPressed = false
        }
    }
    
    
    @IBAction func didPressColorBtns(_ sender: RoundButton) {
        currentStrokeColor = .selectedColor
        color = sender.backgroundColor!
        dotSizeSlider.thumbTintColor = sender.backgroundColor
        dotSizeSlider.tintColor = sender.backgroundColor
        drawingOptionButton.tintColor = sender.backgroundColor
    }
    
    @IBAction func changeSize(_ sender: UISlider) {
        radius = CGFloat(sender.value)
    }
    
    
    override func viewDidLayoutSubviews() {
         // ARCL
         super.viewDidLayoutSubviews()
         sceneView.frame = view.bounds
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func pushVC(_ controller: UIViewController) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchArVC") as! SearchARViewContoller
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        changeTrackingStateView(forCamera: camera)
    }

    func changeTrackingStateView(forCamera camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            trackingStateView.isHidden = true
            break
        case .limited(.initializing):
            trackingStateView.isHidden = false
            trackingStateTitle.text = "공간 탐지 중"
            trackingStateMessage.text = "기기를 천천히 움직여 주세요"
        case .limited(.relocalizing):
            trackingStateView.isHidden = true
            trackingStateMessage.text = "공간이 제한적 입니다."
        case .limited(.excessiveMotion):
            trackingStateView.isHidden = false
            trackingStateTitle.text = "움직임이 너무 과합니다."
            trackingStateMessage.text = "기기를 조금 천천히 움직여 주세요"
        case .limited(.insufficientFeatures):
            trackingStateView.isHidden = false
            trackingStateTitle.text = "공간이 제한적 입니다."
            trackingStateMessage.text = "더 나은 장소로 이동해주세요."
        case .normal:
            trackingStateView.isHidden = true
            break
        }
    }

    
    // MARK:- Drawing
    
    func createSphereAndInsert(atPositions positions: [SCNVector3], andAddToStrokeAnchor strokeAnchor: StrokeAnchor) {
        for position in positions {
            createSphereAndInsert(atPosition: position, andAddToStrokeAnchor: strokeAnchor)
        }
    }
    
    func createSphereAndInsert(atPosition position: SCNVector3, andAddToStrokeAnchor strokeAnchor: StrokeAnchor){
        guard let currentStrokeNode = currentStrokeAnchorNode else {return}
        let referenceSphereNode = getReferenceSphereNode(forStrokeColor: strokeAnchor.color)
        let newSphereNode = referenceSphereNode.clone()
        
        let localPosition = currentStrokeNode.convertPosition(position, from: nil)
        newSphereNode.position = localPosition
        currentStrokeNode.addChildNode(newSphereNode)
        strokeAnchor.sphereLocations.append([newSphereNode.position.x, newSphereNode.position.y, newSphereNode.position.z])
    }
    
    // MARK:- Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                // Create a StrokeAnchor and add it to the Scene (One Anchor will be added to the exaction position of the first sphere for every new stroke)
                guard let touch = touches.first else { return }
                guard let touchPositionInFrontOfCamera = getPosition(ofPoint: touch.location(in: sceneView), atDistanceFromeCamera: 1, inView: sceneView) else { return }

                let strokeAnchor = StrokeAnchor(name: "strokeAnchor", transform:
                    
                    // float4 -> SIMD4로 change
                    float4x4(SIMD4(1, 0, 0, 0),
                             SIMD4(0, 1, 0, 0),
                             SIMD4(0, 0, 1, 0),
                             SIMD4(touchPositionInFrontOfCamera.x,
                                    touchPositionInFrontOfCamera.y,
                                    touchPositionInFrontOfCamera.z,
                                    1)))
                
        
                strokeAnchor.color = currentStrokeColor
                sceneView.session.add(anchor: strokeAnchor)
                currentFingerPosition = touch.location(in: sceneView)
            }
            
            override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
                guard let touch = touches.first else { return }
                currentFingerPosition = touch.location(in: sceneView)
            }

            override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
                previousPoint = nil
                currentStrokeAnchorNode = nil
                currentFingerPosition = nil
            }
            
            override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
                previousPoint = nil
                currentStrokeAnchorNode = nil
                currentFingerPosition = nil
            }
            
            func anchorForID(_ anchorID: UUID) -> StrokeAnchor? {
                return sceneView.session.currentFrame?.anchors.first(where: { $0.identifier == anchorID }) as? StrokeAnchor
            }
            
            func sortStrokeAnchorIDsInOrderOfDateCreated() {
                var strokeAnchorsArray: [StrokeAnchor] = []
                for anchorID in strokeAnchorIDs {
                    if let strokeAnchor = anchorForID(anchorID) {
                        strokeAnchorsArray.append(strokeAnchor)
                    }
                }
                strokeAnchorsArray.sort(by: { $0.dateCreated < $1.dateCreated })
                
                strokeAnchorIDs = []
                for anchor in strokeAnchorsArray {
                    strokeAnchorIDs.append(anchor.identifier)
                }
            }
}

    // MARK:- ARSessionDelegate
extension DrawingViewController: ARSessionDelegate {
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            
//            updateDebugWorldMappingStatusInfoLabel(forframe: frame) f
            
            // Draw the spheres
 
            guard let currentStrokeAnchorID = strokeAnchorIDs.last else { return }

            let currentStrokeAnchor = anchorForID(currentStrokeAnchorID)
            if currentFingerPosition != nil && currentStrokeAnchor != nil {

                guard let currentPointPosition = getPosition(ofPoint: currentFingerPosition!, atDistanceFromeCamera: 1, inView: sceneView) else { return }
                
                if let previousPoint = previousPoint {
                    // Do not create any new spheres if the distance hasn't changed much
                    let distance = abs(previousPoint.distance(vector: currentPointPosition))
                    if distance > 0.00104 {
                        createSphereAndInsert(atPosition: currentPointPosition, andAddToStrokeAnchor: currentStrokeAnchor!)
                        // Draw spheres between the currentPoint and previous point if they are further than the specified distance (Otherwise fast movement will make the line blocky)
                        // TODO: The spacing should depend on the brush size
                        let positions = getPositionsOnLineBetween(point1: previousPoint, andPoint2: currentPointPosition, withSpacing: 0.001)
                        createSphereAndInsert(atPositions: positions, andAddToStrokeAnchor: currentStrokeAnchor!)
                        self.previousPoint = currentPointPosition
                    }
                } else {
                    createSphereAndInsert(atPosition: currentPointPosition, andAddToStrokeAnchor: currentStrokeAnchor!)
                    self.previousPoint = currentPointPosition
                }
            }
        }
        
        // MARK:- ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This is only used when loading a worldMap
        if let strokeAnchor = anchor as? StrokeAnchor {
            currentStrokeAnchorNode = node
            strokeAnchorIDs.append(strokeAnchor.identifier)
            for sphereLocation in strokeAnchor.sphereLocations {
                createSphereAndInsert(atPosition: SCNVector3Make(sphereLocation[0], sphereLocation[1], sphereLocation[2]), andAddToStrokeAnchor: strokeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
            // Remove the anchorID from the strokes array
            print("Anchor removed")
            strokeAnchorIDs.removeAll(where: { $0 == anchor.identifier })
        }
        
    }

extension DrawingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation : CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        altitude = userLocation.altitude
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}



    



