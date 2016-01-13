//
//  ABYNetwork.swift
//  ios_app_b
//
//  Created by hwh on 15/12/21.
//  Copyright © 2015年 黄某人. All rights reserved.
//

import Foundation
#if DEBUG
let timeOut = 10.00
#else
let timeOut = 30.00
#endif
public enum YTNetworkCode: Int {
    case YT_Error = 600
    case YT_Unknown = 700
}
/// 网络调试开关
//# FIXME: 发布时 记得修改位 测试环境 networkDebug =  false
//# TODO: 发布时 记得修改位 测试环境 networkDebug =  false
let networkDebug = true

public typealias SerializeResponse = (NSDictionary?, NSURLResponse?, NSError?) -> Void

struct YTURL {
    private static let _baseUrl = "https://api.kiwivm.it7.net/v1/"
    
    //MARK: -- 子路径
    static let GetServiceInfo = {
        return _baseUrl + "getServiceInfo"
    }()
    static let Restart = {
        return  _baseUrl + "restart"
    }()
    static let Start = {
        return _baseUrl + "start"
    }()
    static let Stop = {
        return _baseUrl + "stop"
    }()
}
class YTNetwork {
    static  let shareInstance = YTNetwork()
    static  let oAuth_Secret: String = {
        if networkDebug { //测试
            return "fd1eb15b6be1860ad678604d90e2fc6d"
        }else { //正式
            return "08fe2621d8e716b02ec0da35256a998d"
        }
    }()
    private let session = NSURLSession.sharedSession()
    private var tasks = [NSURLSessionDataTask]()
    
    enum Methed: String {
        case GET  = "GET"
        case POST = "POST"
    }
    deinit {
        print("YTNetwork \(tasks) 消除")
    }
    func requestWithUrl(urlString: String,methed: Methed, parameters:[String:  AnyObject]? = nil, completionHandler: SerializeResponse) -> NSURLSessionDataTask? {
        if urlString.isEmpty  {
            return nil
        }
        let paras =  appendParametersTo(parameters)
        
        let mutableRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableRequest.HTTPMethod = methed.rawValue
        mutableRequest.timeoutInterval = timeOut
        
        let request = encode(mutableRequest, parameters: paras)
        if networkDebug {
            print("\n\n----Request Start------\n \(request.URL!.absoluteString)\n\n")
        }
        let task = session.dataTaskWithRequest(request) {[unowned self] (data, response, error) -> Void in
            var json :NSDictionary?
            var aybError:NSError? = error
            defer {
                dispatch_async_safely_main_queue({ () -> () in
                    if let _json = json {
                        completionHandler(json!,response,aybError)
                    }else {
                        completionHandler(nil,response,aybError)
                    }
                })
            }
            guard let validData = data, let jsonData =  try? NSJSONSerialization.JSONObjectWithData(validData, options: .AllowFragments) as? NSDictionary  else {
                aybError = NSError(domain: "com.yt", code: YTNetworkCode.YT_Error.rawValue, userInfo: ["error":"接口数据解析错误"])
                print("网络返回结果解析错误")
                return
            }
            if networkDebug {
                print("\n------ Request Response ------\n\(jsonData)\n\n")
            }
            json = jsonData
            
            if try! self.validHttpResponse(response) == false ,let _res = response as? NSHTTPURLResponse {
                aybError = NSError(domain: "com.yt", code: _res.statusCode, userInfo: ["error":"请求错误"])
                return
            }
        }
        task.resume()
        return task
    }
    /**
     关闭请求
     
     - parameter task: 请求任务
     */
    func cancel(task: NSURLSessionDataTask) {
        session.getTasksWithCompletionHandler { (sessionTasks, uploadTasks, downloadTasks) -> Void in
            for _task in sessionTasks {
                if _task.taskIdentifier == task.taskIdentifier {
                    print("找到task，并已cancel")
                    _task.cancel()
                }
            }
        }
    }
    private func encode(urlRequest: NSMutableURLRequest, parameters: [String: AnyObject]?) -> NSURLRequest {
        if parameters == nil {
            return urlRequest
        }
        var mutableURLRequest: NSMutableURLRequest! = urlRequest.mutableCopy() as! NSMutableURLRequest
        let methed = Methed(rawValue: mutableURLRequest.HTTPMethod)
        switch methed! {
            case .POST:
                do {
                    let options = NSJSONWritingOptions()
                    let data = try NSJSONSerialization.dataWithJSONObject(parameters!, options: options)
                    
                    mutableURLRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "X-Accept")
                    mutableURLRequest.HTTPBody = data
                } catch {
                    print(" HTTPBody Encode Failed")
            }
        default:
            /**
            参数拼接
            
            - parameter parameters: 所有上传参数
            
            - returns: url 参数字符串
            */
            func query(parameters: [String: AnyObject]) -> String {
                var components: [(String, String)] = []
                
                for key in Array(parameters.keys).sort(<) {
                    let value: AnyObject! = parameters[key]
                    components += queryComponents(key, value)
                }
                
                return (components.map { "\($0)=\($1)" } as [String]).joinWithSeparator("&")
            }
            /**
             key value 转换位 (string, string) 数组
             
             - parameter key:   字典中 key
             - parameter value: 字典中 value
             
             - returns:  (stirng, string)类型的 数组
             */
            func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
                var components: [(String, String)] = []
                if let dictionary = value as? [String: AnyObject] {
                    for (nestedKey, value) in dictionary {
                        components += queryComponents("\(key)[\(nestedKey)]", value)
                    }
                } else if let array = value as? [AnyObject] {
                    for value in array {
                        components += queryComponents("\(key)[]", value)
                    }
                } else {
                    components.appendContentsOf([(escape(key), escape("\(value)"))])
                }
                return components
            }
            if let URLComponents = NSURLComponents(URL: mutableURLRequest.URL!, resolvingAgainstBaseURL: false) {
                URLComponents.percentEncodedQuery = (URLComponents.percentEncodedQuery != nil ? URLComponents.percentEncodedQuery! + "&" : "") + query(parameters!)
                mutableURLRequest.URL = URLComponents.URL
            }
        }
        
        return mutableURLRequest
        
    }
    enum httpError: ErrorType {
        case Failed   //非 200 错误码
        case Unknowed //不是http 回应
    }
    private func validHttpResponse(response: NSURLResponse?)  throws -> Bool  {
        if let _httpRes = response as? NSHTTPURLResponse {
            if _httpRes.statusCode == 200 {
                print("http请求成功")
                return true
            }
            print("http 错误码非 200 \(response)")
            return false
        }
        print("非http 返回头部 \(response)")
        return false
    }
    /**
     特殊字符处理
     
     - parameter string: 待处理字符串
     
     - returns: 去除特殊字符串
     */
    private func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    private func appendParametersTo(parameters: [String:AnyObject]?) -> [String: AnyObject]? {
        //赋值原有 参数
        var paras = [String: AnyObject]()
        
        //自有参数
        if parameters != nil {
            for (key, value) in parameters! {
                paras[key] = value
            }
        }
        return paras
    }

}