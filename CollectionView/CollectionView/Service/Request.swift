//
//  Request.swift
//  CollectionView
//
//  Created by Mac on 10/31/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import UIKit

class Request: NSObject {
    
    static let sharedInstance = Request()
    
    func request(url:String, method: String, params: [String: String], completion: @escaping (NSDictionary)->() ){
        if let nsURL = URL(string:url) {
            let request = NSMutableURLRequest(url: nsURL as URL)
            let postString:String?
            if method == "POST" {
                // convert key, value pairs into param string
                postString = params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                request.httpBody = postString?.data(using: String.Encoding.utf8)
                //                request.setValue("text/json; oe=utf-8", forHTTPHeaderField: "Accept")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                (data, response, error) in
                do {
                    
                    // what happens if error is not nil?
                    // That means something went wrong.
                    // Make sure there really is some data
                    if let data = data {
//                        let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//                        print(datastring ?? "default value")
//                        var jsonResultDic:NSDictionary  = [String:AnyObject]() as NSDictionary
                        let jsonResultDic = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        completion(jsonResultDic)
                    }
                    else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDataFailedNotification), object: nil, userInfo: nil)
                        print("Data is nil")
                        
                    }
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
        else{
            // Could not make url. Is the url bad?
            // You could call the completion handler (callback) here with some value indicating an error
        }
    }
    
}
