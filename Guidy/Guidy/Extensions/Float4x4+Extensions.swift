//
//  Float4x4+Extensions.swift
//  AR Project
//
//  Created by seunghwan Lee on 2020/02/09.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import SceneKit

extension float4x4 {
    func convertToSCNVector3() -> SCNVector3 {
        return SCNVector3Make(self.columns.3.x,
                              self.columns.3.y,
                              self.columns.3.z)
    }
}
