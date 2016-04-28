//
//  TVCell.swift
//  CButton
//
//  Created by jyg on 16/4/27.
//  Copyright © 2016年 jyg. All rights reserved.
//

import UIKit

protocol TVCellDelegate {
    func btopViewPressed(cell: TVCell)
}

class TVCell: UITableViewCell {
    
    var _bview: UIView!
    var _imgView: UIImageView!
    var _lab: UILabel!
    var _updownView: UIImageView!
    
    var _btopView: UIButton!
    var _index = -1
    var _sel = false
    var _delegate: TVCellDelegate!
    
    var _pid = 0
    var _pidsView: UIView!
    var _pidBtns = [SButton]()
    var _lines = [UIView]()
    var _line: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = MainBackColor()
        self.clipsToBounds = true
        
        let s = UIScreen.mainScreen().bounds.size.width
        let ox: CGFloat = 8
        let oy: CGFloat = 4
        _bview = UIView(frame: CGRect(x: ox, y: oy, width: s-ox*2, height: 52-oy*2))
        _bview.backgroundColor = CellBackColor()
        _bview.layer.cornerRadius = 6
        _bview.clipsToBounds = true
        self.contentView.addSubview(_bview)
        //_bview.autoresizingMask = .FlexibleHeight
        
        _btopView = UIButton(type: .Custom)
        _btopView.frame = CGRect(x: 0, y: 0, width: _bview.frame.size.width, height: 44)
        _btopView.adjustsImageWhenHighlighted = false
        _bview.addSubview(_btopView)
        _btopView.addTarget(self, action: #selector(TVCell.btopViewTouchDown), forControlEvents: .TouchDown)
        _btopView.addTarget(self, action: #selector(TVCell.btopViewPressed), forControlEvents: .TouchUpInside)
        _btopView.addTarget(self, action: #selector(TVCell.btopViewCancel), forControlEvents: .TouchDragOutside)
        _btopView.addTarget(self, action: #selector(TVCell.btopViewCancel), forControlEvents: .TouchCancel)
        
        _imgView = UIImageView(image: UIImage(named: "more"))
        _imgView.center = CGPoint(x: 15+_imgView.frame.size.width/2, y: _btopView.frame.size.height/2)
        _btopView.addSubview(_imgView)
        
        _lab = UILabel()
        _lab.backgroundColor = UIColor.clearColor()
        _lab.textColor = UIColor.whiteColor()
        _lab.font = UIFont.systemFontOfSize(CGFloat(CELLLABELSIZE))
        _btopView.addSubview(_lab)
        
        _updownView = UIImageView(image: UIImage(named: "more"))
        _updownView.center = CGPoint(x: _btopView.frame.size.width-15-_imgView.frame.size.width/2, y: _btopView.frame.size.height/2)
        _btopView.addSubview(_updownView)
        
        _pidsView = UIView(frame: CGRect(x: 0, y: 44,width: _bview.frame.size.width, height: 0))
        _pidsView.clipsToBounds = true
        _bview.addSubview(_pidsView)
        
        _line = UIView(frame: CGRect(x: _pidsView.frame.size.width/2, y: 0, width: 0.5, height: 0))
        _line.backgroundColor = RGBA(0xe0e0e0, 1)
        _pidsView.addSubview(_line)
    }
    
    func setH(h: CGFloat, completion: ((Bool) -> Void)?) {
        var frame = _bview.frame
        frame.size.height = h-8
        self._bview.frame = frame
    }
    
    func setCellH(h: CGFloat, completion: ((Bool) -> Void)?) {
        var frame = self.frame
        frame.size.height = h
        UIView.animateWithDuration(10.3, delay: 0, options: .BeginFromCurrentState, animations: {
            self.frame = frame
            }, completion: completion)
    }
    
    func btopViewTouchDown() {
        _btopView.backgroundColor = CellSelectColor()
    }
    
    func btopViewPressed() {
        _btopView.backgroundColor = CellBackColor()
        _delegate.btopViewPressed(self)
    }
    
    func setSel(sel: Bool) {
        _sel = sel
        
        checkUpdown()
    }
    
    func checkUpdown() {
        var sy: CGFloat = 1
        if _sel {
            sy = -1
        }
        
        self._updownView.transform = CGAffineTransformMakeScale(1, sy)
    }
    
    func btopViewCancel() {
        _btopView.backgroundColor = CellBackColor()
    }
    
    func setPid(pid: Int) {
        _pid = pid
        
        _imgView.image = UIImage(named: "more")
        _lab.text = mylocallang("aa")
        _lab.sizeToFit()
        _lab.center = CGPoint(x: _imgView.frame.size.width+_imgView.frame.origin.x+8+_lab.frame.size.width/2, y: _imgView.center.y)
    }
    
    func setPids(pids: [Int]) {
        if !_sel {
            var frame1 = _pidsView.frame
            frame1.size.height = 0
            
            var frame2 = _line.frame
            frame2.size.height = 0
            
            UIView.animateWithDuration(0.3, delay: 0, options: .BeginFromCurrentState, animations: {
                self._pidsView.frame = frame1
                self._line.frame = frame2
                }, completion: nil)
            return
        }
        
        for btn in _pidBtns {
            btn.hidden = true
        }
        
        for line in _lines {
            line.hidden = true
        }
        
        let width = _bview.frame.size.width/2
        let height: CGFloat = 32
        for i in 0..<pids.count {
            var btn: SButton!
            if i < _pidBtns.count {
                btn = _pidBtns[i]
            } else {
                btn = SButton(type: .Custom)
                btn.frame = CGRect(x: CGFloat((i%2))*width, y: CGFloat((i/2))*height, width: width, height: height)
                btn.backgroundColor = UIColor.clearColor()
                btn.setTitle("11111", forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(CGFloat(CELLLABELSIZE))
                btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                btn.adjustsImageWhenHighlighted = false
                _pidsView.addSubview(btn)
                _pidBtns.append(btn)
            }
            
            btn.hidden = false
            
            if i%2 == 0 {
                let j = i/2
                var line: UIView!
                if j < _lines.count {
                    line = _lines[j]
                } else {
                    line = UIView(frame: CGRect(x: 0, y: CGFloat(j*32), width: _pidsView.frame.size.width, height: 0.5))
                    line.backgroundColor = RGBA(0xe0e0e0, 1)
                    _pidsView.addSubview(line)
                    _lines.append(line)
                }
                
                line.hidden = false
            }
        }
        
        let h = CGFloat(((pids.count/2)+pids.count%2)*32)
        var frame1 = _pidsView.frame
        frame1.size.height = h
        
        var frame2 = _line.frame
        frame2.size.height = h
        
        UIView.animateWithDuration(0.3, delay: 0, options: .BeginFromCurrentState, animations: {
            self._pidsView.frame = frame1
            self._line.frame = frame2
            }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNeedalpha(needalpha: Bool) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
