//
//  EditingViewController.swift
//  Guidy
//
//  Created by seunghwan Lee on 2020/06/01.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

protocol pushViewControllerDelegate {
    func pushVC(_ controller: UIViewController)
}

class EditingViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var botConstOfOptionView: NSLayoutConstraint!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var completionButton: UIButton!
    
    let toolBar = UIToolbar()
    
    var image = UIImage()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var altitude: Double = 0.0
    var delegate: pushViewControllerDelegate?
    
    
    lazy var optionButton = UIBarButtonItem()
    lazy var setconst = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageView.image = image
        
        textView.delegate = self
        textView.frame.size.width = self.view.frame.width * 0.9
        textView.center.x = self.view.center.x
        textView.center.y = self.view.center.y - 200
        imageView.layer.cornerRadius = self.view.frame.width / 10
        optionView.layer.cornerRadius = self.view.frame.width / 20
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        toolbarSetup()
        
        textView.textColor = .white
        textView.tintColor = .white
        
        optionButton.tintColor = .white
        
        self.view.bringSubviewToFront(optionView)
        self.view.bringSubviewToFront(completionButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.becomeFirstResponder()
    }
    
    @IBAction func dragTextView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: textView)
        
        let xPos = textView.center.x + translation.x
        let yPos = textView.center.y + translation.y
        textView.center = CGPoint(x: xPos, y: yPos)
        
        
        sender.setTranslation(CGPoint.zero, in: textView)
    }
    
    @IBAction func changeFontSize(_ sender: UISlider) {
        self.textView.font = UIFont.boldSystemFont(ofSize: CGFloat(sender.value))
        
        if textView.frame.size.height < self.view.frame.size.height * 0.8 {
            adjustTextViewSize(textView)
        }
    }
    
    @IBAction func changeFontColor(_ sender: RoundButton) {
        textView.textColor = sender.backgroundColor
        textView.tintColor = sender.backgroundColor
        fontSizeSlider.thumbTintColor = sender.backgroundColor
        fontSizeSlider.tintColor = sender.backgroundColor
        optionButton.tintColor = sender.backgroundColor
    }
    
    @IBAction func didPressCompletion(_ sender: UIButton) {
        let image = UIImage.createImageWithTextView(imageView, textView)
        
        NetworkManager().saveImage(lat: latitude, lon: longitude, altitude: altitude, img: image)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchArVC") as! SearchARViewContoller
        
        self.dismiss(animated: false) {
            self.delegate?.pushVC(vc)
//            self.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
////            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {

    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        
        if setconst == false {
            let keyboardHeight = CGFloat(keyboardSize.height)
            botConstOfOptionView.constant = keyboardHeight + 5
            setconst = true
        }
      }
    }
    
    func toolbarSetup() {
        toolBar.frame = CGRect(x: 0, y: 0, width: 0, height: 38)
        toolBar.barTintColor = UIColor.lightGray
        
        optionButton = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .done, target: self, action: #selector(didPressOption))
        
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .done, target: self, action: #selector(didPresstrash))
        deleteButton.tintColor = .darkGray
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let hideKeyboardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(didPressKeyboardDown))
        hideKeyboardButton.tintColor = .darkGray

        toolBar.setItems([optionButton, deleteButton, flexibleSpace, hideKeyboardButton], animated: true)
        textView.inputAccessoryView = toolBar
    }
    
    @objc func didPressOption() {
        if optionView.isHidden == true {
            optionView.isHidden = false
        } else {
            optionView.isHidden = true
        }
    }
    
    @objc func didPresstrash() {
        textView.text.removeAll()
    }
    
    @objc func didPressKeyboardDown() {
        
        if optionView.isHidden == false {
            optionView.isHidden = true
        }
        
        textView.endEditing(true)
    }
    
    func test() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height), false, 2.0)
            
        let testView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
        
        testView.image = imageView.image
        
            let testView2 = textView!
            testView.addSubview(testView2)
        
            testView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            
//            let currentView = UIView.init(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
//            let currentImage = UIImageView.init(image: image)
//            currentImage.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
//            currentView.addSubview(currentImage)
//            currentView.addSubview(label)
        
            
//            currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
//            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img!
        }
}

extension EditingViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.frame.size.height < self.view.frame.size.height * 0.8 {
            adjustTextViewSize(textView)
        }
    }
    
    func adjustTextViewSize(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
    }
}


