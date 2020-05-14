//
//  NetworkManager.swift
//  ARProject2
//
//  Created by seunghwan Lee on 2020/04/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import Alamofire
import CoreLocation

class NetworkManager {
    
    let baseURL = "http:54.180.173.160:3000"
        
    func saveImage(lat: CLLocationDegrees, lon: CLLocationDegrees, altitude: CLLocationDistance,   img: UIImage) {
        let url = baseURL + "/ar/up"
        
        let parameters = [
            "lat" : lat,
            "lon" : lon,
            "alt" : altitude
            ]
        
        let image = img
        let imageData = image.jpegData(compressionQuality: 1)
                
        AF.upload(multipartFormData: { multiPart in
        multiPart.append(imageData!, withName: "file",fileName: "test.png", mimeType: "image/png")
        for (key, value) in parameters {
                multiPart.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                }, to: url, method: .post) .uploadProgress(queue: .main, closure: { progress in
                    print("Upload Progress: \(progress.fractionCompleted)")
                }).responseJSON(completionHandler: { data in
                    print("upload finished: \(data)")
                }).response { (response) in
                    switch response.result {
                    case .success(let resut):
                        print("upload success result: \(resut)")
                        print("code: \(response.response?.statusCode)")
                    case .failure(let err):
                        print("upload err: \(err)")
                    }
        }
    }
    
    func getImgData(lat: CLLocationDegrees, lon: CLLocationDegrees, altitude: CLLocationDistance, completion: @escaping (Response?) -> Void) {
        let url = baseURL + "/ar/dis"
        
        let param = Img_loca(image: nil, lon: lon, lat: lat, alt: altitude)
        
        let request = AF.request(url,
        method: .post,
        parameters: param,
        encoder: JSONParameterEncoder.default)
        
        request.responseDecodable(of: Response.self) { response in
           switch response.result {
           case let .success(result):
            completion(result)
           case let .failure(error):
            print("Error description is: \(error.localizedDescription)")
           }
        }
    }

}
