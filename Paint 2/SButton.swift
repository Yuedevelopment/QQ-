//
//  SButton.swift
//  SwifTest
//
//  Created by jyg on 16/2/27.
//  Copyright © 2016年 jyg. All rights reserved.
//

import UIKit

class SButton: UIButton {

    class SButton: UIButton {
        
        var scale = CGPoint(x: 0.9, y: 0.9)
        
        override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
            UIView.animateWithDuration(0.15
                , delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(self.scale.x, self.scale.y)
                }, completion: nil)
            
            return super.beginTrackingWithTouch(touch, withEvent: event)
        }
        
        override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
            
            let delay:NSTimeInterval = 0
            UIView.animateWithDuration(0.15,
                delay: delay, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                }) { (finished) -> Void in
                    
            }
            
            super.endTrackingWithTouch(touch,withEvent: event);
        }
        
        override func cancelTrackingWithEvent(event: UIEvent?) {
            UIView.animateWithDuration(0.15,
                delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                }) { (finished) -> Void in
                    
            }
            
            super.cancelTrackingWithEvent(event)
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
