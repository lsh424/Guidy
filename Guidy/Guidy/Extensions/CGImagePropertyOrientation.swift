//
//  CGImagePropertyOrientation.swift
//  AR Project
//
//  Created by seunghwan Lee on 2020/02/09.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

extension CGImagePropertyOrientation {
    /// Preferred image presentation orientation respecting the native sensor orientation of iOS device camera.
    init(cameraOrientation: UIDeviceOrientation) {
        switch cameraOrientation {
        case .portrait:
            self = .right
        case .portraitUpsideDown:
            self = .left
        case .landscapeLeft:
            self = .up
        case .landscapeRight:
            self = .down
        default:
            self = .right
        }
    }
}
