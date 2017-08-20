//
//  Network.swift
//  OFO
//
//  Created by paprika on 2017/8/20.
//  Copyright © 2017年 paprika. All rights reserved.
//

import AVOSCloud
struct Network {
    
}

extension Network{
    
    static func getPass(code:String,completion:@escaping (String?)->Void){
        let query = AVQuery(className: "Code")
        //从code列找code这个值对应的pass
        query.whereKey("code", equalTo: code)
        query.getFirstObjectInBackground { (code, error) in
            //if error != nil 没有守护,let e = error可以保护
            if  let e = error{
                print("出错",e.localizedDescription)
            }
            if let code = code,
               let pass = code["pass"] as? String{
                    completion(pass)
            }
        }
    }
}
