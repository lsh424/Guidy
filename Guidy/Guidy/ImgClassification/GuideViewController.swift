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
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var textGuide: UITextView!
    @IBOutlet weak var audioGuideBtn: UIButton!
    
    var isplay = 0
    var name: String? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = name
//        let imgName = name.text! + "가이드이미지"
//        img.image = UIImage(named: imgName)
//        
////        textGuide.text = 
//
        let path = Bundle.main.path(forResource: "guideData", ofType: "json")
        
        if let contents = try? String(contentsOfFile: path!) {
            if let data = contents.data(using: .utf8) {
                print("리절트 데이터 \(data)")
                let result = try? JSONDecoder().decode(guideVO.self, from: data)
                print("제이슨 결과 \(result)")
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
//        let fileName = name.text! + "오디오가이드"
        
        let url = Bundle.main.url(forResource: "근정전오디오가이드", withExtension: "mp3")
        
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
