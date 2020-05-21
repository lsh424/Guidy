//
//  GuideVO.swift
//  Guidy
//
//  Created by seunghwan Lee on 2020/05/19.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

struct guideVO: Codable {
    let data: type
    
    struct type: Codable {
        let gwang: info
        let geun: info
        let gang: info
        let kyung: info
        
        struct info: Codable {
            let audioGuide: String
            let textGuide: String
        }
    }
}
