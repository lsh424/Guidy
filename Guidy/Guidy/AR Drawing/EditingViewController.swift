//
//  EditingViewController.swift
//  Guidy
//
//  Created by seunghwan Lee on 2020/06/01.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

class EditingViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var botConstOfOptionView: NSLayoutConstraint!
    @IBOutlet weak var fontSizeSlider: UISlider!
    
    let toolBar = UIToolbar()
    lazy var optionButton = UIBarButtonItem()
    lazy var setconst = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        textView.center.x = self.view.center.x
        textView.center.y = self.view.center.y - 100
        imageView.layer.cornerRadius = self.view.frame.width / 10
        optionView.layer.cornerRadius = self.view.frame.width / 20
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        toolbarSetup()
        
        textView.textColor = .white
        textView.tintColor = .white
        
        optionButton.tintColor = .white
    }
    
    @IBAction func dragTextView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: textView)
        
        let xPos = textView.center.x + translation.x
        let yPos = textView.center.y + translation.y
        textView.center = CGPoint(x: xPos, y: yPos)
        
        
        sender.setTranslation(CGPoint.zero, in: textView)
    }
    
    @IBAction func changeFontSize(_ sender: UISlider) {
        self.textView.font = UIFont.systemFont(ofSize: CGFloat(sender.value))
//        self.textView.frame.size = self.textView.contentSize
//        self.textView.updateTextFont()
        
    }
    
    @IBAction func changeFontColor(_ sender: RoundButton) {
        textView.textColor = sender.backgroundColor
        textView.tintColor = sender.backgroundColor
        fontSizeSlider.thumbTintColor = sender.backgroundColor
        fontSizeSlider.tintColor = sender.backgroundColor
        optionButton.tintColor = sender.backgroundColor
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
    
    
}

extension UITextView {
func updateTextFont() {
    if (self.text.isEmpty || self.bounds.size.equalTo(CGSize.zero)) {
        return;
    }

    let textViewSize = self.frame.size;
    let fixedWidth = textViewSize.width;
    let expectSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))


    var expectFont = self.font
    if (expectSize.height > textViewSize.height) {

        while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height) {
            expectFont = self.font!.withSize(self.font!.pointSize - 1)
            self.font = expectFont
        }
    }
    else {
        while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height) {
            expectFont = self.font
            self.font = self.font!.withSize(self.font!.pointSize + 1)
        }
        self.font = expectFont
    }
}
}
