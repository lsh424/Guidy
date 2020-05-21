//
//  ImageViewerController.swift
//  Guidy
//
//  Created by seunghwan Lee on 2020/05/19.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

class ImageViewerController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var heartBtn: UIButton!
    
    var image: UIImage?
    var isPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.clipsToBounds = true
    }
    
    @IBAction func didPressHeart(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            if isPressed == false {
                heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                heartBtn.tintColor = .red
                isPressed = true
            } else {
                heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                heartBtn.tintColor = .systemGray
                isPressed = false
            }
        } else {
            //
        }
        
    }
    
    
}
