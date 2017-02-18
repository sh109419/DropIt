//
//  DropItView.swift
//  Dropit
//
//  Created by hyf on 17/1/1.
//  Copyright © 2017年 hyf. All rights reserved.
//

import UIKit
import CoreMotion

class DropItView: NamedBezierPathsView, UIDynamicAnimatorDelegate {
    
    fileprivate lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    } ()
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        removeCompletedRow()
    }
    
    let dropBehavior = FallingObjectBehavior()
    
    var animating: Bool = false {
        didSet {
            if animating {
                animator.addBehavior(dropBehavior)
                updateRealGravity()
            } else {
                animator.removeBehavior(dropBehavior)
            }
        }
    }
    
    fileprivate var attachment: UIAttachmentBehavior? {
        willSet {
            if attachment != nil {
                animator.removeBehavior(attachment!)
                bezierPaths[PathNames.Attachment] = nil
            }
        }
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment!.action = { [unowned self] in
                    if let attachedDrop = self.attachment!.items.first as? UIView {
                        self.bezierPaths[PathNames.Attachment] = UIBezierPath.lineFrom(self.attachment!.anchorPoint, to: attachedDrop.center)
                    }
                }
            }
        }
    }
    
    var realGravity = false {
        didSet {
            updateRealGravity()
        }
    }
    
    fileprivate let montionManager = CMMotionManager()
    
    fileprivate func updateRealGravity() {
        if realGravity {
            if montionManager.isAccelerometerAvailable && !montionManager.isAccelerometerActive {
                montionManager.accelerometerUpdateInterval = 0.25
                montionManager.startAccelerometerUpdates(to: OperationQueue.main)
                {
                    [unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil {
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            switch UIDevice.current.orientation {
                            case .portrait: dy = -dy
                            case .portraitUpsideDown: break
                            case .landscapeLeft: swap(&dx, &dy); dy = -dy
                            case .landscapeRight: swap(&dx, &dy)
                            default: dx = 0; dy = 0;
                            }
                            self.dropBehavior.gravity.gravityDirection = CGVector(dx: dx, dy: dy)
                        }

                    } else {
                        self.montionManager.stopAccelerometerUpdates()
                    }
                                    }
            }
        } else {
            montionManager.stopAccelerometerUpdates()
        }
    }
    
    fileprivate struct PathNames {
        static let MiddleBarrier = "Middle Barrier"
        static let Attachment = "Attachment"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(ovalIn: CGRect(center: bounds.mid, size: dropSize))
        dropBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
        bezierPaths[PathNames.MiddleBarrier] = path
    }

    func grabDrop(_ recognizer: UIPanGestureRecognizer) {
        let gesturePoint = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            if let dropToAttachTo = lastDrop, dropToAttachTo.superview != nil {
                attachment = UIAttachmentBehavior(item: dropToAttachTo, attachedToAnchor: gesturePoint)
            }
            lastDrop = nil
        case .changed:
            attachment?.anchorPoint = gesturePoint
        default:
            attachment = nil
        }
    }
    
    fileprivate func removeCompletedRow() {
        var dropsToRemove = [UIView]()
        
        var hitTestRect = CGRect(origin: bounds.lowerLeft, size: dropSize)
        repeat {
            hitTestRect.origin.x = bounds.minX
            hitTestRect.origin.y -= dropSize.height
            var dropsTested = 0
            var dropsFound = [UIView]()
            while dropsTested < dropsPerRow {
                if let hitView = hitTest(hitTestRect.mid), hitView.superview == self {
                    dropsFound.append(hitView)
                } else {
                    break
                }
                hitTestRect.origin.x += dropSize.width
                dropsTested += 1
            }
            if dropsTested == dropsPerRow {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && hitTestRect.origin.y > bounds.minY
        
        for drop in dropsToRemove {
            dropBehavior.remvoeItem(drop)
            drop.removeFromSuperview()
        }
       
    }
    
    fileprivate let dropsPerRow = 10
    
    fileprivate var dropSize: CGSize {
        let size = bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    fileprivate var lastDrop: UIView?

    func addDrop() {
        var frame = CGRect(origin: CGPoint.zero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        
        addSubview(drop)
        dropBehavior.addItem(drop)
        lastDrop = drop
    }
}
