//
//  GuideVO.swift
//  Guidy
//
//  Created by seunghwan Lee on 2020/05/19.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

struct GuideData: Codable {
    let data: Type
}

struct Type: Codable {
    let gwang: Info
    let geun: Info
    let gang: Info
    let kyung: Info
}

struct Info: Codable {
    let audioGuide: String
    let textGuide: String
}
