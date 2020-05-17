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

class DrawingViewController: UIViewController,ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var undoButton: UIButton!
    
    var previousPoint: SCNVector3?
    var currentFingerPosition: CGPoint?
    
    var whiteBallCount = 0
    var sphereCountLabel: UILabel!
    
    var strokeAnchorIDs: [UUID] = []
    var currentStrokeAnchorNode: SCNNode?
    
    var currentStrokeColor: StrokeColor = .white
    
    let configuration = ARWorldTrackingConfiguration()
    
    var locationManager = CLLocationManager()
    
    var location: CLLocationCoordinate2D?
    var altitude: CLLocationDistance?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressUndoButton))
        undoButton.addGestureRecognizer(longPressGesture)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
                UIApplication.shared.isIdleTimerDisabled = true
                sceneView.preferredFramesPerSecond = 60

                sceneView.delegate = self
                sceneView.session.delegate = self
        //        sceneLocationView.run()
                
                //Add sphere count label
                sphereCountLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 100, height: 40))
                sphereCountLabel.textColor = UIColor.purple
                sphereCountLabel.isHidden = false
                    
                let scene = SCNScene()
                sceneView.scene = scene
                
                sceneView.session.run(configuration)
                
//                view.addSubview(scneView)
//                scneView.addSubview(sphereCountLabel)
    }
    
    @objc func longPressUndoButton(gesture: UILongPressGestureRecognizer) {
        for strokeAnchorID in strokeAnchorIDs {
            if let strokeAnchor = anchorForID(strokeAnchorID) {
                sceneView.session.remove(anchor: strokeAnchor)
            }
        }
        currentStrokeAnchorNode = nil
    }

    @IBAction func didPressGallery(_ sender: Any) {
       let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchArVC") as! SearchARViewContollerViewController
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didPressSave(_ sender: Any) {
        print("저장")
//        let locationLat = NSNumber(value:location!.latitude)
//        let locationLon = NSNumber(value:location!.longitude)
//        let alti = NSNumber(value: altitude!)
//        UserDefaults.standard.set(["lat": locationLat, "lon": locationLon, "alti" : alti], forKey: "1")
        
        let image = sceneView.snapshot()
//        networkTest(img:image)
        
        NetworkManager().saveImage(lat: location!.latitude, lon: location!.longitude, altitude: altitude!, img: image)
        
//        let imgData = image.pngData()
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let newImage = NSEntityDescription.insertNewObject(forEntityName: "Image", into: context!)
////        newImage.setValue(imgData, forKey: "img")
////
////        do {
////            try Constant.context?.save()
////        }
    }
    
    @IBAction func didPressUndo(_ sender: Any) {
        sortStrokeAnchorIDsInOrderOfDateCreated()
        
        guard let currentStrokeAnchorID = strokeAnchorIDs.last, let curentStrokeAnchor = anchorForID(currentStrokeAnchorID) else {
            print("No stroke to remove")
            return
        }
        
        sceneView.session.remove(anchor: curentStrokeAnchor)

        // add this?
        currentStrokeAnchorNode = nil
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
    
// 카메라 로컬라이징
//    func changeTrackingStateView(forCamera camera: ARCamera) {
//        switch camera.trackingState {
//        case .notAvailable:
//            // "Tracking unavailable."
//            trackingStateView.isHidden = true
//            break
//        case .limited(.initializing):
//            trackingStateView.isHidden = false
//            trackingStateImageView.image = UIImage(named: "move-phone")
//            trackingStateTitleLabel.text = "Detecting world"
//            trackingStateMessageLabel.text = "Move your device around slowly"
//            addPhoneMovingAnimation()
//        case .limited(.relocalizing):
//            trackingStateView.isHidden = true
//            debugTrackingStateLabel.text = "Tracking state limited(relocalizing)"
//            removePhoneMovingAnimation()
//        case .limited(.excessiveMotion):
//            trackingStateView.isHidden = false
//            trackingStateImageView.image = UIImage(named: "exclamation")
//            trackingStateTitleLabel.text = "Too much movement"
//            trackingStateMessageLabel.text = "Move your device more slowly"
//            removePhoneMovingAnimation()
//        case .limited(.insufficientFeatures):
//            trackingStateView.isHidden = false
//            trackingStateImageView.image = UIImage(named: "light-bulb")
//            trackingStateTitleLabel.text = "Not enough detail"
//            trackingStateMessageLabel.text = "Move around or find a better lit place"
//            removePhoneMovingAnimation()
//        case .normal:
//            trackingStateView.isHidden = true
//            removePhoneMovingAnimation()
//            break
//        }
//    }
    
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
        whiteBallCount += 1
    }
    
    // MARK:- Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
                // Create a StrokeAnchor and add it to the Scene (One Anchor will be added to the exaction position of the first sphere for every new stroke)
                guard let touch = touches.first else { return }
                guard let touchPositionInFrontOfCamera = getPosition(ofPoint: touch.location(in: sceneView), atDistanceFromeCamera: 1, inView: sceneView) else { return }
                
                // Convert the position from SCNVector3 to float4x4
    //            let strokeAnchor = StrokeAnchor(name: "strokeAnchor", transform: simd_float4x4(SIMD4(1, 0, 0, 0), SIMD4(0, 1, 0, 0), SIMD4(0, 0, 1, 0), SIMD4(touchPositionInFrontOfCamera.x,
    //            touchPositionInFrontOfCamera.y, touchPositionInFrontOfCamera.z,1)))
                let strokeAnchor = StrokeAnchor(name: "strokeAnchor", transform:
                    
                    
                    // float4 -> SIMD4 로 바꾼 상태
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
                
                DispatchQueue.main.async {
                    self.sphereCountLabel.text = "\(self.whiteBallCount)"
                }
            }
        }
        
        // MARK:- ARSCNViewDelegate
//        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//            print("랜더러 작동")
//            // This is only used when loading a worldMap
//            if let strokeAnchor = anchor as? StrokeAnchor {
//                currentStrokeAnchorNode = node
//                strokeAnchorIDs.append(strokeAnchor.identifier)
//                for sphereLocation in strokeAnchor.sphereLocations {
//                    createSphereAndInsert(atPosition: SCNVector3Make(sphereLocation[0], sphereLocation[1], sphereLocation[2]), andAddToStrokeAnchor: strokeAnchor)
//                }
//            }
//        }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("랜더러 작동")
        // This is only used when loading a worldMap
        if let strokeAnchor = anchor as? StrokeAnchor {
            currentStrokeAnchorNode = node
            strokeAnchorIDs.append(strokeAnchor.identifier)
            for sphereLocation in strokeAnchor.sphereLocations {
                createSphereAndInsert(atPosition: SCNVector3Make(sphereLocation[0], sphereLocation[1], sphereLocation[2]), andAddToStrokeAnchor: strokeAnchor)
            }
        }
    }
    
    
    
//    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        arViewDelegate?.renderer?(renderer, didAdd: node, for: anchor)
//
//    }
        
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
            // Remove the anchorID from the strokes array
            print("Anchor removed")
            strokeAnchorIDs.removeAll(where: { $0 == anchor.identifier })
        }
        
    }

extension DrawingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation : CLLocation = locations[0]
        //        let latitude = userLocation.coordinate.latitude
        //        let longitude = userLocation.coordinate.longitude
                
//                let latDelta : CLLocationDegrees = 0.05
//
//                let lonDelta : CLLocationDegrees = 0.05
//        //
//              let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                
        //        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        altitude = userLocation.altitude
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}



    



