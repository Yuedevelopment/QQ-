//
//  PaintView.swift
//  JJChatSwift
//
//  Created by Tangguo on 15/7/22.
//  Copyright (c) 2015年 TangGuo. All rights reserved.
//

import UIKit

@objc protocol PaintViewDelegate:NSObjectProtocol {
    
    optional func paintLineTouchesBegan()
    
    optional func paintLineToucheChange()
    
    optional func paintLineTouchfinish(lineCount:Int)
}

class PaintView: Palette {

    var MyBeganpoint:CGPoint?
    var MyMovepoint:CGPoint?
    
    var tapRecognizer:UITapGestureRecognizer?
    
    var delegate:PaintViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self._lineWidth = 6.72
        self._eraseLineWidth = 6.72
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(PaintView.panLine(_:)))
        self.addGestureRecognizer(pan)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PaintView.tapTouchPoint(_:)))
        
        addTapTouchPoint()
        
    }
    
    func addTapTouchPoint() {
        self.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeTapTouchPoint() {
        self.removeGestureRecognizer(tapRecognizer!)
    }
    
    func tapTouchPoint(recognizer:UITapGestureRecognizer) {
        
        MyBeganpoint = recognizer.locationInView(self)
        
        IntroductionpointlineColor(self._lineColor)
        IntroductionpointWidth(self._isErase ? self._eraseLineWidth:self._lineWidth)
        IntroductionIsErase(self._isErase)
        IntroductionpointInit()
        IntroductionpointPointaddArr(MyBeganpoint!)
        IntroductionpointPointaddArr(MyBeganpoint!)
        
        if (delegate?.respondsToSelector(#selector(PaintViewDelegate.paintLineTouchesBegan))) == true {
            delegate?.paintLineTouchesBegan!()
        }
        
        IntroductionpointLineaddArr()
        self.setNeedsDisplay()
        
        if (delegate?.respondsToSelector(#selector(PaintViewDelegate.paintLineTouchfinish(_:)))) == true {
            delegate?.paintLineTouchfinish!(getmyLineCount())
        }
    }
    
    func panLine(recognizer:UIPanGestureRecognizer) {
        
        MyBeganpoint = recognizer.locationInView(self)
        
        switch recognizer.state {
        case UIGestureRecognizerState.Began:

            IntroductionpointlineColor(self._lineColor)
            IntroductionpointWidth(self._isErase ? self._eraseLineWidth: self._lineWidth)
            IntroductionIsErase(self._isErase)
            IntroductionpointInit()
            IntroductionpointPointaddArr(MyBeganpoint!)
            IntroductionpointPointaddArr(MyBeganpoint!)
            self.setNeedsDisplay()
            
            if (delegate?.respondsToSelector(#selector(PaintViewDelegate.paintLineTouchesBegan))) == true {
                delegate?.paintLineTouchesBegan!()
            }
            
            break
        case UIGestureRecognizerState.Changed:
            
            IntroductionpointPointaddArr(MyBeganpoint!)
            self.setNeedsDisplay()
            
            if (delegate?.respondsToSelector(#selector(PaintViewDelegate.paintLineToucheChange))) == true {
                delegate?.paintLineToucheChange!()
            }
            
            break
        default:
            
            IntroductionpointLineaddArr()
            self.setNeedsDisplay()
            
            if (delegate?.respondsToSelector(#selector(PaintViewDelegate.paintLineTouchfinish(_:)))) == true {
                delegate?.paintLineTouchfinish!(getmyLineCount())
            }

            break
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
