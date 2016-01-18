//
//  MasterViewController.swift
//  YTBandwagonhost
//
//  Created by hwh on 16/1/12.
//  Copyright © 2016年 油条. All rights reserved.
//

import UIKit


class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [String:AnyObject]() {
        didSet {
            var allKeys = [String]()
            for  (key, _) in objects {
                allKeys.append(key)
            }
            keys = allKeys
        }
    }
    
    private var keys:[String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        refreshUsers()
        
        //注册通知 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshUsers", name: Constant.NotificationKey.RefreshUsers, object: nil)
    }
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    deinit {
        print("\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    func refreshUsers() {
        let users = NSUserDefaults.standardUserDefaults().objectForKey(Constant.UserDefaultKey.UsersKey) as? [String:AnyObject] ??  [String:AnyObject]()
        objects = users
        tableView.reloadData()
    }
    func insertNewObject(sender: AnyObject) {
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("login")
        if let _ = loginVC {
            navigationController?.presentViewController(loginVC!, animated: true, completion: nil)
        }
        /*
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        */
    }
    //MARK: - Methed
    func login(veid: String, apikey: String) {
        showHud()
        let network = YTNetwork.shareInstance
        network.requestWithUrl(YTURL.GetServiceInfo, methed: .GET, parameters: ["veid":veid,"api_key":apikey]) { [unowned self](data, response, error) -> Void in
            if let _ = error {
                self.showError()
                let alert = AlertWithMsg(error!.localizedDescription)
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            self.hiddenHUD()
            //登录成功
            self.enterDetail(data,veid: veid, apikey: apikey)
        }
    }
    func enterDetail(data: AnyObject?,veid: String? = nil, apikey: String? = nil) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("detail") as? DetailViewController
        if let _veid = veid, let _apikey = apikey {
            vc?.setVeid(_veid, apiKey: _apikey)
        }
        if let _ = vc ,let _ = data {
            vc?.vpsInfo = data
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(keys)
        return keys.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let key = keys[indexPath.row]
        if let _hostname = objects[key] as? String {
            cell.textLabel!.text = "\(_hostname)"
            cell.detailTextLabel?.text = "veid:\(key)"
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let key = keys[indexPath.row]
        if editingStyle == .Delete {
            UserDefault.removeObjectForKey(key)
            KeyChain.removeObjectForKey(key)
            keys.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            refreshUsers()
            if keys.count <= 0 {
                self.setEditing(false, animated: true)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let veid = keys[indexPath.row]
        
        guard let apiKey = KeyChain.objectForKey(veid) else {
            let alert = AlertWithMsg("获取登录信息失败")
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        login(veid, apikey: apiKey)
    }
    
}

