//
//  Response.swift
//  ARProject2
//
//  Created by seunghwan Lee on 2020/04/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

struct Response: Codable {
    let message: String?
    let dis: [Img_loca?]
    let status: Int?
}
