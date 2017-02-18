//
//  FallingObjectBehavior.swift
//  Dropit
//
//  Created by hyf on 17/1/8.
//  Copyright © 2017年 hyf. All rights reserved.
//

import UIKit

class FallingObjectBehavior: UIDynamicBehavior {
    
    let gravity = UIGravityBehavior()
    
    fileprivate let collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    } ()

    fileprivate let itemBehavior: UIDynamicItemBehavior = {
        let dib = UIDynamicItemBehavior()
        dib.allowsRotation = true
        dib.elasticity = 0.75
        return dib
    } ()
    
    func addBarrier(_ path: UIBezierPath, named name: String) {
        collider.removeBoundary(withIdentifier: name as NSCopying)
        collider.addBoundary(withIdentifier: name as NSCopying, for: path)
    }
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(itemBehavior)
    }
    
    func addItem(_ item: UIDynamicItem) {
        gravity.addItem(item)
        collider.addItem(item)
        itemBehavior.addItem(item)
    }
    
    func remvoeItem(_ item: UIDynamicItem) {
        gravity.removeItem(item)
        collider.removeItem(item)
        itemBehavior.removeItem(item)
    }
}
