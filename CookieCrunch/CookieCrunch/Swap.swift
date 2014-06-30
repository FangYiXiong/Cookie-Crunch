//
//  Swap.swift
//  CookieCrunch
//
//  Created by FangYiXiong on 14-6-30.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//

import Foundation

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB) ||
        (lhs.cookieA == rhs.cookieB && lhs.cookieB == rhs.cookieA)
}

class Swap: Printable, Hashable {
    var cookieA: Cookie
    var cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
    
    // 异或两个hashValue来生成一个hashValue
    var hashValue: Int {
        return cookieA.hashValue ^ cookieB.hashValue
    }
}