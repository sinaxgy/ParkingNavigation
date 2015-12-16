//
//  SwiftAlamofireJSON.swift
//  ParkingNavigation
//
//  Created by 徐成 on 15/7/24.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

protocol dataFromAlamofire {
    func dictionaryWithGET(dic:NSDictionary)
}

class SwiftAlamofireJSON: NSObject {
   
    func get() {
        var json:JSON = JSON.nullJSON
    }
    
    var dataDelegate:dataFromAlamofire!
    
    static func JSONWithPOST(msgStr:String) {
        let requestUrl = "http://10.104.7.120:8080/YLQ/"
        let request = Alamofire.request(.POST, requestUrl, parameters: ["location":""])
        request.responseJSON(){
            (_,_,data,error) in
            if error != nil {
                let alert = UIAlertView(title: "错误", message: "读取失败", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            println(data)
        }
    }
    
    func JSONWithGET(){
        let url = "http://10.104.4.202/web/index.php/app/picture?pro_id=5"
        let request = Alamofire.request(.GET, url)
        request.responseJSON() {
            (_,_,data,error) in
            if error != nil {
                let alert = UIAlertView(title: "错误", message: "读取失败", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            //println(data)
            //let dic:NSDictionary = data as! NSDictionary
            //self.dataDelegate.dictionaryWithGET(dic)
        }
    }
}
