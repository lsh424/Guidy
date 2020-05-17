//
//  SearchARViewContollerViewController.swift
//  AR Project
//
//  Created by seunghwan Lee on 2020/02/23.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation

class SearchARViewContollerViewController: UIViewController {
    
    var sceneLocationView = SceneLocationView()
    
//    var img: UIImage?
    
    var locationManager = CLLocationManager()
    
    var location: CLLocationCoordinate2D?
    var altitude: CLLocationDistance?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        let toDrawingBtn = UIButton(frame: CGRect(x: 30, y: 30, width: 100, height: 30))
        toDrawingBtn.setTitle("그리기", for: .normal)
        
        toDrawingBtn.addTarget(self, action: #selector(test), for: .touchUpInside)
        
        view.addSubview(toDrawingBtn)
        
        self.sceneLocationView.locationNodeTouchDelegate = self
        self.sceneLocationView.locationEstimateMethod = LocationEstimateMethod.mostRelevantEstimate
        
        
//        let locationDictionary = UserDefaults.standard.object(forKey: "1") as? Dictionary<String,NSNumber>
//        let locationLat = locationDictionary!["lat"]!.doubleValue
//        let locationLon = locationDictionary!["lon"]!.doubleValue
//        let alt = locationDictionary!["alti"]!.doubleValue

                
//        LocationEstimateMethod.coreLocationDataOnly
        // Originally, the hard-coded factor to raise an annotation's label within the viewport was 1.1.
//        var annotationHeightAdjustmentFactor = 1.1

//            var scalingScheme = ScalingScheme.normal
//            // I have absolutely no idea what reasonable values for these scaling parameters would be.
//            var threshold1: Double = 100.0
//            var scale1: Float = 0.85
//            var threshold2: Double = 400.0
//            var scale2: Float = 0.5
//            var buffer: Double = 100.0
//
//            var continuallyAdjustNodePositionWhenWithinRange = true
//            var continuallyUpdatePositionAndScale = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchImages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pauseAnimation()
        super.viewWillDisappear(animated)
    }

    func pauseAnimation() {
        print("pause")
        sceneLocationView.pause()
    }

    func restartAnimation() {
        print("run")
        sceneLocationView.run()
    }
    
    @objc func test() {
        print("버튼 눌림")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func fetchImages() {
        NetworkManager().getImgData(lat: location!.latitude, lon: location!.longitude, altitude: altitude!) { (result) in
            
            print(result)
            
            for data in result!.dis {
                self.downloadImage(from: (data?.image)!, lat: (data?.lat)!, lon: (data?.lon)!, alt: (data?.alt)!)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from urlString: String, lat: Double, lon: Double, alt: Double) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() { [weak self] in
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let location = CLLocation(coordinate: coordinate, altitude: alt)
                
                let imgView = UIImageView()
                let img = UIImage(data: data)
                
                imgView.image = img

                imgView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
                imgView.layer.masksToBounds = true
                imgView.layer.borderWidth = 5
                imgView.layer.borderColor = UIColor.purple.cgColor
                imgView.layer.cornerRadius = imgView.bounds.width / 3
                
                
                let annotationNode = LocationAnnotationNode(location: location, view: imgView, tag: urlString)
                annotationNode.scaleRelativeToDistance = true
                
//                annotationNode.continuallyUpdatePositionAndScale = true
                annotationNode.continuallyAdjustNodePositionWhenWithinRange = false // 기본 - true
                annotationNode.accessibilityLabel = urlString
                annotationNode.name = urlString
                
                guard let scnLocationView = self?.sceneLocationView else {
                    return
                }
                
                scnLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                
                
                
//                annotationNode.accessibilityValue = urlString
//                print(annotationNode.accessibilityValue, urlString)
                
                //        annotationNode.scalingScheme = .normal

            }
        }
    }
}

extension SearchARViewContollerViewController: LNTouchDelegate {
    
    func annotationNodeTouched(node: AnnotationNode) {
        
        // node could have either node.view or node.image
        if let nodeView = node.view{
            // Do stuffs with the nodeView
            // ...
            print("nodeView touched")

        }
        
        if let nodeImage = node.image{
            // Do stuffs with the nodeImage
            // ...
            print("nodeImage touched")

            getData(from: URL(string: node.accessibilityValue!)!) { (data, response, error) in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { [weak self] in
                    let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: self!.view.frame.width, height: self!.view.frame.height))
                    imgView.image = UIImage(data: data)
                    self!.sceneLocationView.addSubview(imgView)
            }
        }
     }
    }
    

    func locationNodeTouched(node: LocationNode) {
        print("locationnode touched")
//        guard let name = node.tag else { return }
//        guard let selectedNode = node.childNodes.first(where: { $0.geometry is SCNBox }) else { return }

        // Interact with the selected node
    }
}
    

extension SearchARViewContollerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        altitude = userLocation.altitude
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
