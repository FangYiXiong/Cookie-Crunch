//
//  Swap.swift
//  CookieCrunch
//
//  Created by FangYiXiong on 14-6-30.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//

import Foundation

class Swap: Printable {
    var cookieA: Cookie
    var cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}