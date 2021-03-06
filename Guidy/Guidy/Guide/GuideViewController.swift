//
//  GuideViewController.swift
//  Guidy
//
//  Created by seunghwan Lee on 2020/05/06.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import UIKit
import AVFoundation

class GuideViewController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var textGuide: UITextView!
    @IBOutlet weak var audioGuideBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    private var isplay = false
    private var audioName: String?
    private var timer: Timer?
    lazy private var player =  AVAudioPlayer()
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = name
        
        let path = Bundle.main.path(forResource: "guideData", ofType: "json")
        
        if let contents = try? String(contentsOfFile: path!) {
            if let data = contents.data(using: .utf8) {
                do {
                    let result = try JSONDecoder().decode(GuideData.self, from: data)
                    if name == "광화문" {
                        audioName = result.data.gwang.audioGuide
                        textGuide.text = result.data.gwang.textGuide
                        img.image = UIImage(named: "광화문가이드이미지.jpg")
                    } else if name == "근정전" {
                        audioName = result.data.geun.audioGuide
                        textGuide.text = result.data.geun.textGuide
                        img.image = UIImage(named: "근정전가이드이미지.jpg")
                    } else if name == "강녕전" {
                        audioName = result.data.gang.audioGuide
                        textGuide.text = result.data.gang.textGuide
                        img.image = UIImage(named: "강녕전가이드이미지.jpeg")
                    } else {
                        audioName = result.data.kyung.audioGuide
                        textGuide.text = result.data.kyung.textGuide
                        img.image = UIImage(named: "경회루가이드이미지.jpg")
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        let url = Bundle.main.url(forResource: audioName, withExtension: "mp3")
        if let url = url {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                slider.maximumValue = Float((player.duration))
                player.prepareToPlay()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func didPressAudioPlayBtn(_ sender: Any) {
        play()
    }
    
    @IBAction func slide(_ sender: Any) {
        player.currentTime = TimeInterval(slider.value)
    }
    
    @objc func updateSlider() {
        slider.value = Float(player.currentTime)
        if slider.value > slider.maximumValue - 0.1 {
            audioGuideBtn.setImage(UIImage(systemName: "play"), for: .normal)
            isplay = false
        }
    }
    
    private func play() {
        guard slider.value != slider.maximumValue else {
            slider.value = slider.minimumValue
            return
        }
        
        if !isplay{
            player.play()
            isplay = true
            timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            
            if #available(iOS 13.0, *) {
                audioGuideBtn.setImage(UIImage(systemName: "pause"), for: .normal)
            } else {
                
            }
        } else {
            player.stop()
            timer?.invalidate()
            isplay = false
            if #available(iOS 13.0, *) {
                audioGuideBtn.setImage(UIImage(systemName: "play"), for: .normal)
            } else {
                
            }
        }
    }
}
