//
//  YTHelper.swift
//  YTBandwagonhost
//
//  Created by hwh on 16/1/12.
//  Copyright © 2016年 油条. All rights reserved.
//

import UIKit
let App = UIApplication.sharedApplication().delegate as! AppDelegate
struct  Constant{
    struct UserDefaultKey {
        static let UsersKey = "UsersKey"
    }
    struct NotificationKey {
        static let RefreshUsers = "RefreshUsers"
    }
}
/**
 线程执行
 
 - parameter block: 执行Block
 */
func dispatch_asyn_queue(block: ()->()) {
    if NSThread.isMainThread() == false {
        block()
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            block()
        }
    }
}
/**
 主线程回调
 
 - parameter block: 执行Block
 */
func dispatch_async_safely_main_queue(block: ()->()) {
    if NSThread.isMainThread() {
        block()
    } else {
        dispatch_async(dispatch_get_main_queue()) {
            block()
        }
    }
}//MARK: - Alert
func AlertWithMsg(meg:String) -> UIAlertController {
    let alert = UIAlertController(title: "提示", message: meg, preferredStyle: .Alert)
    
    let action = UIAlertAction(title: "确定", style: .Default, handler: nil)
    alert.addAction(action)

    return alert
}
//MARK: - UserDefault
struct UserDefault {
    static func setObejct(object: AnyObject, forKey: String) {
        var users = NSUserDefaults.standardUserDefaults().objectForKey(Constant.UserDefaultKey.UsersKey) as? [String:AnyObject] ?? [String:AnyObject]()
        users[forKey] = object
        NSUserDefaults.standardUserDefaults().setObject(users, forKey: Constant.UserDefaultKey.UsersKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    static func removeObjectForKey(key: String) {
        let userKey = Constant.UserDefaultKey.UsersKey
        if var users = NSUserDefaults.standardUserDefaults().objectForKey(userKey) as? [String:AnyObject] {
            users.removeValueForKey(key)
            NSUserDefaults.standardUserDefaults().setObject(users, forKey: userKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}

struct KeyChain {
    static let authenticationPrompt = "更新apikey"
    static func setObject(object: String, forKey: String) {
        let value = keychain[forKey]
        
        if let _ = value { //update
            dispatch_asyn_queue({ () -> () in
                do {
                    try keychain.accessibility(.WhenPasscodeSetThisDeviceOnly, authenticationPolicy: .UserPresence)
                        .authenticationPrompt(authenticationPrompt)
                        .set(object, key: forKey)
                } catch let error {
                    print(error)
                }
            })
            
        }else {  //set
            dispatch_asyn_queue { () -> () in
                do {
                    try keychain.accessibility(.WhenPasscodeSetThisDeviceOnly, authenticationPolicy: .UserPresence)
                        .set(object, key: forKey)
                }catch let error {
                    print(error)
                }
            }
        }
    }
    static func objectForKey(key: String) -> String? {
        do {
            let apiKey = try keychain.authenticationPrompt(authenticationPrompt)
            .get(key)
            return apiKey
        }catch let error {
            print(error)
            return nil
        }
    }
}