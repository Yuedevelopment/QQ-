//
//  ThirdViewController.swift
//  CButton
//
//  Created by jyg on 16/4/22.
//  Copyright © 2016年 jyg. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    var _needalpha = false
    var _tableView: UITableView!
    var _index = -1
    var _array = [["pid": 1, "pids": [1, 2, 3, 4, 5, 6, 7, 8]],
                  ["pid": 2, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
                  ["pid": 3, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]],
                  ["pid": 4, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]],
                  ["pid": 5, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]],
                  ["pid": 6, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]],
                  ["pid": 7, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]],
                  ["pid": 8, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]],
                  ["pid": 9, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]],
                  ["pid": 10, "pids": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initTableView()
    }

    func initTableView() {
        _tableView = UITableView(frame: self.view.bounds)
        _tableView.backgroundColor = MainBackColor()
        _tableView.separatorStyle = .None
        let top: CGFloat = 4
        let bottom: CGFloat = 4-SH()
        _tableView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
        self.view.addSubview(_tableView)
        
        _tableView.delegate = self
        _tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ThirdViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _array.count+1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section < _array.count {
            let reuseIdentifier: String = "TVCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? TVCell
            if  cell == nil {
                cell = TVCell(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
                cell?._delegate = self
            }
            
            cell?.setH(tableView.rectForRowAtIndexPath(indexPath).size.height, completion: nil)
            
            cell?._index = indexPath.section
            cell?.setSel(cell?._index == _index)
            
            let obj = _array[indexPath.section]
            let pid = obj["pid"] as! Int
            cell?.setPid(pid)
            
            let pids = obj["pids"] as! [Int]
            cell?.setPids(pids)
            
            cell?.setNeedalpha(_needalpha)
            
            return cell!
        } else {
            let reuseIdentifier: String = "TVEmptyCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? TVEmptyCell
            if  cell == nil {
                cell = TVEmptyCell(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
                cell!.selectionStyle = .None
                cell!.backgroundColor = UIColor.clearColor()
                cell!.contentView.backgroundColor = MainBackColor()
                cell!.clipsToBounds = true
            }
            
            return cell!
        }
    }
}

extension ThirdViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section < _array.count {
            var height: CGFloat = 52
            if _index == indexPath.section {
                let obj = _array[_index]
                if  let pids = obj["pids"] as? [Int] {
                    var c = pids.count/2
                    c = c+pids.count%2
                    height = height+CGFloat(c*32)
                }
            }
            
            return height
        } else {
            return SH()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension ThirdViewController: TVCellDelegate {
    func btopViewPressed(cell: TVCell) {
        let indexPath = _tableView.indexPathForCell(cell)!
        if indexPath.section == _index {
            _index = -1
            //self._tableView.beginUpdates()
            let set = NSIndexSet(index: indexPath.section)
            self._tableView.reloadSections(set, withRowAnimation: .None)
            //_tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            //self._tableView.endUpdates()
        } else {
            if _index == -1 {
                _index = indexPath.section
                //_tableView.beginUpdates()
                let set = NSIndexSet(index: indexPath.section)
                _tableView.reloadSections(set, withRowAnimation: .Automatic)
                //_tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                //_tableView.endUpdates()
            } else {
                let index = _index
                let set = NSMutableIndexSet(index: index)
                _index = indexPath.section
                set.addIndex(indexPath.section)
                //_tableView.beginUpdates()
                _tableView.reloadSections(set, withRowAnimation: .None)
                //_tableView.reloadRowsAtIndexPaths([path,indexPath], withRowAnimation: .None)
                //_tableView.endUpdates()
            }
        }
    }
}
