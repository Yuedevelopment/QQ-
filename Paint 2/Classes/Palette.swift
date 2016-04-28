//
//  Palette.swift
//  JJChatSwift
//
//  Created by Tangguo on 15/7/22.
//  Copyright (c) 2015年 TangGuo. All rights reserved.
//

import UIKit
import CoreGraphics

class Palette: UIView {
    
    var _isErase:Bool = false //是否是橡皮檫
    var _eraseLineWidth:CGFloat = 6.72
    var _lineWidth:CGFloat = 6.72
    var _defaultLineWidth: CGFloat = 6.72
    var _lineColor = UIColor.whiteColor()
    var _defaultLineColor = UIColor.whiteColor()
    
    var _lastps = [CGPoint]()
    var _allline = [[CGPoint]]()
    var _allColor = [UIColor]()
    var _allwidth = [CGFloat]()
    var _allErase = [Bool]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {

        //获取上下文
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        //设置笔冒
        CGContextSetLineCap(context, CGLineCap.Round)
        //设置画线的连接处　拐点圆滑
        CGContextSetLineJoin(context, CGLineJoin.Round)
        
        //画之前线
        if _allline.count > 0 {
            
            for i in 0...(_allline.count-1) {
                
                let arr = _allline[i]
                
                let isErase = _allErase[i]
                var lineWidth = CGFloat(0)
                
                if _allColor.count > 0 {
                    
                    if i < _allwidth.count {
                        lineWidth = _allwidth[i]
                    }else {
                        if isErase == true {
                            lineWidth = _eraseLineWidth
                        }else {
                            lineWidth = _defaultLineWidth
                        }
                    }
                }
                
                if arr.count > 1 {
                    
                    CGContextBeginPath(context)
                    let sp:CGPoint = arr[0]
                    CGContextMoveToPoint(context, sp.x, sp.y)
                    
                    for j in 0...(arr.count-2) {
                        let ep = arr[j+1]
                        CGContextAddLineToPoint(context, ep.x,ep.y);
                    }
                    
                    var lineColor:UIColor!
                    if i < _allColor.count {
                        lineColor = _allColor[i]
                    }else {
                        lineColor = _defaultLineColor
                    }
                    
                    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
                    //-------------------------------------------------------
                    CGContextSetLineWidth(context, lineWidth);
                    // 橡皮檫功能
                    if isErase == true {
                        CGContextSetBlendMode(context, .Clear);
                    }else {
                        CGContextSetBlendMode(context, .Normal);
                    }
                    CGContextStrokePath(context);
                }
            }
        }
        
        //画当前的线
        if _lastps.count > 1 {
            CGContextBeginPath(context)
            
            let sp = _lastps[0]
            CGContextMoveToPoint(context, sp.x, sp.y)
            
            //把move的点全部加入　数组
            _lineWidth = _allwidth.last!
            for i in 0...(_lastps.count-2) {
                
                let ep = _lastps[i+1]
                // 贝赛尔曲线的估算长度
                let x1 = abs(sp.x-ep.x)
                let x2 = abs(sp.y-ep.y)
                let len = sqrt(pow(x1, 2)+pow(x2,2))*10
                print("len = \(len)")
                CGContextAddLineToPoint(context, ep.x,ep.y);
                
                //在颜色和画笔大小数组里面取不相应的值
                
                //_lineColor = _lineColor.colorWithAlphaComponent(len/10)
                //绘制画笔颜色
                CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
                CGContextSetFillColorWithColor (context,  _lineColor.CGColor);
                //-------------------------------------------
                //绘制画笔宽度
                CGContextSetLineWidth(context, _lineWidth);
                // 橡皮檫功能
                if _isErase == true {
                    CGContextSetBlendMode(context, .Clear);
                }else {
                    CGContextSetBlendMode(context, .Normal);
                }
                //把数组里面的点全部画出来
                CGContextStrokePath(context);
            }
        }
    }
    
    //===========================================================
    //初始化
    //===========================================================
    func IntroductionpointInit() {
        _lastps.removeAll()
    }
    
    //===========================================================
    //把画过的当前线放入　存放线的数组
    //===========================================================
    func IntroductionpointLineaddArr() {
        _allline.append(_lastps)
    }
    
    //===========================================================
    //把画过的当前点放入数组
    //===========================================================
    func IntroductionpointPointaddArr(point:CGPoint) {
        _lastps.append(point)
    }
    
    //===========================================================
    //接收颜色
    //===========================================================
    
    func IntroductionpointlineColor(templineColor:UIColor) {
        _lineColor = templineColor
        _allColor.append(templineColor)
    }
    
    //===========================================================
    //接收线条宽度按钮反回来的值
    //===========================================================
    func IntroductionpointWidth(tempLineWidth:CGFloat) {
        _allwidth.append(_lineWidth)
    }
    
    //===========================================================
    //接收是否是橡皮檫的值
    //===========================================================
    func IntroductionIsErase(Erase:Bool) {
        _isErase = Erase
        _allErase.append(_isErase)
    }
    
    //===========================================================
    //清屏按钮
    //===========================================================
    
    func myalllineclear() -> Bool {
        
        if _allline.count > 0 {
            _allline.removeAll()
            _allColor.removeAll()
            _allwidth.removeAll()
            _lastps.removeAll()
            _allErase.removeAll()
            
            self.setNeedsDisplay()
            return true
        }
        return false
    }
    
    //===========================================================
    //撤销上一步
    //===========================================================
    func myLineFinallyRemove() {
        
        if _allline.count > 0 {
            _allline.removeLast()
            _allColor.removeLast()
            _allwidth.removeLast()
            _lastps.removeAll()
            _allErase.removeLast()
        }
        self.setNeedsDisplay()
    }
    //===========================================================
    //获取我总共有多少多少条线
    //===========================================================
    func getmyLineCount() -> Int {
        return _allline.count
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    

}
