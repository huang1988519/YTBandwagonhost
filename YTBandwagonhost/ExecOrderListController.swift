//
//  ExecOrderListController.swift
//  YTBandwagonhost
//
//  Created by hwh on 16/1/14.
//  Copyright © 2016年 油条. All rights reserved.
//

import UIKit

class ExecOrderListController: UIViewController {
    @IBOutlet weak var textView: HolderTextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var showButton: UIButton!
    
    @IBOutlet weak var execHeightConstaint: NSLayoutConstraint!
    private var _veid: String?
    private var _apiKey: String?
    
    private var _list = [String]()
    private var _resultList =  [String]()
    private var _message:String? {
        didSet {
            if let list:[String] =  _message!.componentsSeparatedByString("\n") {
                _resultList = list
                resultTableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let execList = NSUserDefaults.standardUserDefaults().objectForKey(Constant.UserDefaultKey.ExecOrderListKey) as? [String] {
            _list =  execList
        }
        resultTableView.rowHeight = UITableViewAutomaticDimension
        tableView.rowHeight =  UITableViewAutomaticDimension
        
        tableView.reloadData()
    }
    func setVeid(veid: String, apiKey: String) {
        _veid = veid
        _apiKey = apiKey
    }
    @IBAction func showHistory(sender: UIButton) {
        self.view.endEditing(true)
        
        print(sender.titleForState(.Normal))
        if sender.titleForState(.Normal) == "Show" {
            showHistory(true)
        }else {
            showHistory(false)
        }
       
    }
    private func showHistory(show: Bool) {
        if show {
            showButton.setTitle("Hide", forState: .Normal)
            execHeightConstaint.constant = 150
        }else{
            showButton.setTitle("Show", forState: .Normal)
            execHeightConstaint.constant = 0
        }
        view.bringSubviewToFront(tableView)
        view.layoutIfNeeded()
    }
    @IBAction func perform(sender: AnyObject?) {
        self.view.endEditing(true)
        showHistory(false)
        
        guard let command =  textView.text ,let veid = _veid, let apiKey = _apiKey else {
            showError("输入命令或者参数异常")
            return
        }
        showHud()
        let network = YTNetwork.shareInstance
        network.requestWithUrl(YTURL.ExecBasicShell, methed: .GET, parameters: ["command":command,"veid":veid,"api_key":apiKey]) {[unowned self] (data, response, error) -> Void in
            if let _ = error {
                self.showError(error)
                return
            }
            if let message = data!["message"] as? String {
                self._message = message
            }
            self.showSucess("执行成功")
            self.storeOrder(self.textView.text)
            self.tableView.reloadData()

        }
    }
    func storeOrder(exec: String?) {
        var list = _list
        if let _ = exec {
            list.append(exec!)
        }
        if list.count > 10 {
            list.removeFirst()
        }
        _list = list
        NSUserDefaults.standardUserDefaults().setObject(list, forKey: Constant.UserDefaultKey.ExecOrderListKey)
    }
}
extension ExecOrderListController: UITableViewDataSource,UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultTableView {
            return _resultList.count
        }
        return _list.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == resultTableView {
            let result = _resultList[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("cell",
                forIndexPath: indexPath)
            let textLabel = cell.viewWithTag(100) as? UILabel
            textLabel?.text = result
            return cell
        }else {
            let order = _list[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            cell.textLabel?.text =  order
            return cell
    
        }
    }
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if textView.isFirstResponder() {
            textView.resignFirstResponder()
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showHistory(false)
        
        if tableView == resultTableView {
            let result = _resultList[indexPath.row]
            UIPasteboard.generalPasteboard().string = result
            showSucess("复制到剪切板")
        }else {
            let order = _list[indexPath.row]
            textView.text = order
            perform(nil)
        }
    }
}