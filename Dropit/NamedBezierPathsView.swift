//
//  NamedBezierPathsView.swift
//  Dropit
//
//  Created by hyf on 17/1/8.
//  Copyright © 2017年 hyf. All rights reserved.
//

import UIKit

class NamedBezierPathsView: UIView {
    
    var bezierPaths = [String: UIBezierPath]() {
        didSet {
            setNeedsDisplay()
        }
    }

    
    override func draw(_ rect: CGRect) {
        // Drawing code
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
   
}
