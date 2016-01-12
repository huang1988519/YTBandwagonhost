//
//  LoginViewController.swift
//  YTBandwagonhost
//
//  Created by hwh on 16/1/12.
//  Copyright © 2016年 油条. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var veidTf: UITextField!
    @IBOutlet weak var apiKeyTf: UITextField!
    
    private let placeColor = UIColor(white: 0.8, alpha: 0.8)

    //MARK: - Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorfulPlaceHolder = NSAttributedString(string: veidTf.placeholder ?? "", attributes: [NSForegroundColorAttributeName: placeColor])
        veidTf.attributedPlaceholder = colorfulPlaceHolder
        apiKeyTf.attributedPlaceholder = colorfulPlaceHolder
    }

    //MARK: - Methed
    @IBAction func login(sender: AnyObject) {
        guard let _veid = veidTf.text  ,let _apikey = apiKeyTf.text else{
            let alert = AlertWithMsg("请检查 veid 和 api key 是否输入正确")
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let network = YTNetwork.shareInstance
        network.requestWithUrl(YTURL.GetServiceInfo, methed: .GET, parameters: ["veid":_veid,"api_key":_apikey]) { [unowned self](data, response, error) -> Void in
            if let _ = error {
                let alert = AlertWithMsg(error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                return 
            }
            
            self.storeUser(data as? [String: AnyObject])
        }
    }
    @IBAction func cancel(sender: UIButton?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func storeUser(data : [String: AnyObject]?) {
        guard let _veid = veidTf.text  ,let _apikey = apiKeyTf.text ,let _ = data else{
            let alert = AlertWithMsg("请检查 veid 和 api key 是否输入正确")
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        let hostname = data!["hostname"] as? String ?? ""
        
        UserDefault.setObejct(hostname, forKey: _veid)
        KeyChain.setObject(_apikey, forKey: _veid)
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constant.NotificationKey.RefreshUsers, object: nil)
        cancel(nil)
    }
}
