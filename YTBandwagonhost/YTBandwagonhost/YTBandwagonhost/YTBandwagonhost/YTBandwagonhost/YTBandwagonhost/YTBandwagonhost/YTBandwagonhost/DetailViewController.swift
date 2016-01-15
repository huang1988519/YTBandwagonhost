//
//  DetailViewController.swift
//  YTBandwagonhost
//
//  Created by hwh on 16/1/12.
//  Copyright © 2016年 油条. All rights reserved.
//

import UIKit
import KYCircularProgress
import SnapKit

class DetailViewController: UIViewController {

    @IBOutlet var ramProgress: RectView!
    @IBOutlet var bwProgress: RectView!
    
    @IBOutlet weak var bwLabel: UILabel!
    @IBOutlet weak var ramLabel: UILabel!
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    private var content: String = "" {
        didSet {
        }
    }
    private var _ram: Double = 0
    private var _bw:  Double = 0
    private var _suspend = true
    
    private var _veid: String?
    private var _apiKey: String?
    
    var vpsInfo: AnyObject? {
        didSet {
            print(vpsInfo)
            let info = vpsInfo!
            guard let hostname = info["hostname"] as? String,
                let nodeAlias = info["node_alias"] as? String,
            let ips = info["ip_addresses"] as? [String],
            let os = info["os"] as? String,
            let plan = info["plan"] as? String,
            let planDisk = info["plan_disk"] as? Double,
            let dataCounter = info["data_counter"] as? Double,
            let totalCounter = info["plan_monthly_data"] as? Double,
            let suspend = info["suspended"] as? Bool
            else {
                    return
            }
            let list = ["主机名:  \(hostname)","别名:    \(nodeAlias)","IP:     \(ips)","操作系统: \(os)","套餐:   \(plan)","硬盘:   \(planDisk/1024/1024/1024) G"]
            content = list.joinWithSeparator("\n")
            _bw = dataCounter/totalCounter
            
            _suspend = suspend
        }
    }

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        bwProgress.progress  = _bw

        
        detailDescriptionLabel.text = content
        if let counter = vpsInfo!["data_counter"] as? Double ,
            let total = vpsInfo!["plan_monthly_data"] as? Double {
            bwLabel.text = String(format: "%0.1f/%0.1fG",counter/1024/1024/1024,total/1024/1024/1024)
        }
        if let ram = vpsInfo!["plan_ram"] as? Double {
            ramLabel.text = String(format: "Total: %0.0f M", ram/1024/1024)
        }
    }
    func setVeid(veid: String, apiKey: String) {
        _veid = veid
        _apiKey = apiKey
    }
    @IBAction func restart(sender: AnyObject) {
        startRequestForState(YTURL.Restart)
    }
    @IBAction func start(sender: AnyObject) {
        startRequestForState(YTURL.Start)
    }
    @IBAction func stop(sender: AnyObject) {
        startRequestForState(YTURL.Stop)
    }
    private func startRequestForState(url: String) {
        guard let veid = _veid,let apikey = _apiKey else {
            print("缺少veid 或者apikey")
            return
        }
        let network = YTNetwork.shareInstance
        network.requestWithUrl(url, methed: .GET, parameters: ["veid":veid,"api_key":apikey]) {[unowned self] (data, response, error) -> Void in
            guard let _ = error else {
                self.showSucess("操作成功")
                return
            }
            
            print("网络错误")
            self.showError(error)
        }
    }

}

