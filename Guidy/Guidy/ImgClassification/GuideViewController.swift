//
//  GuideViewController.swift
//  ImageClassification
//
//  Created by seunghwan Lee on 2020/05/06.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import UIKit
import AVFoundation

var soundEffect: AVAudioPlayer?

class GuideViewController: UIViewController {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var textGuide: UITextView!
    @IBOutlet weak var audioGuideBtn: UIButton!
    
    var isplay = 0
    var name: String?
    var audioName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = name
        
//        let imgName = name.text! + "가이드이미지"
//        img.image = UIImage(named: imgName)
//        
////        textGuide.text = 
//
        let path = Bundle.main.path(forResource: "guideData", ofType: "json")
        
        if let contents = try? String(contentsOfFile: path!) {
            if let data = contents.data(using: .utf8) {

                 do {
                   let result = try JSONDecoder().decode(guideVO.self, from: data)
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
    }
    
    @IBAction func didPressAudioPlayBtn(_ sender: Any) {
        test()
    }
    
    /*
    if (player.playing == true) {
        player.stop()
        playPauseButtonOutlet.setImage(UIImage(named: "play.jpg"), forState: UIControlState.Normal)
    } else {
        player.play()
        playPauseButtonOutlet.setImage(UIImage(named: "pause.jpg"), forState: UIControlState.Normal)
    }
    */
    
    func test() {
        let url = Bundle.main.url(forResource: audioName, withExtension: "mp3")
        
        if let url = url {
            
            do {
                soundEffect = try AVAudioPlayer(contentsOf: url)
                
                guard let sound = soundEffect else {
                    return
                }
                
                sound.prepareToPlay() //재생 준비 ? -> 버퍼를 미리 로드하고 재생에 필요한 하드웨어를 가져옴?
                
                if isplay == 0 {
                    sound.play()
                    isplay = 1
                    if #available(iOS 13.0, *) {
                        audioGuideBtn.setImage(UIImage(systemName: "pause"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                } else {
                    sound.pause()
                    isplay = 0
                    if #available(iOS 13.0, *) {
                        audioGuideBtn.setImage(UIImage(systemName: "play"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
    }
    
}
