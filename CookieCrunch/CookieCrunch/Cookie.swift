//
//  Cookie.swift
//  CookieCrunch
//
//  Created by FangYiXiong on 14-6-27.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//

import SpriteKit

enum CookieType: Int, Printable{
    case UnKnown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie
    
    var spriteName: String {
        let spriteNames = ["Croissant", "Cupcake", "Danish", "Donut", "Macaroon", "SugarCookie"]
        // toRaw() 把当前枚举的值转换为 int
        return spriteNames[toRaw() - 1]
    }
    
    var highlightedSpriteName: String {
        let highlightedSpriteNames = [
            "Croissant-Highlighted",
            "Cupcake-Highlighted",
            "Danish-Highlighted",
            "Donut-Highlighted",
            "Macaroon-Highlighted",
            "SugarCookie-Highlighted"]
        return highlightedSpriteNames[toRaw() - 1]
    }
    
    var description: String {
        return ["羊角面包","纸杯面包","冰块","甜甜圈","铜锣烧","星星"][toRaw() - 1]
    }
    
    // 每次增加一个糖果，要一个随机类型，所以把这个函数放到枚举中会很合适
    static func random() -> CookieType {
        return CookieType.fromRaw(Int(arc4random_uniform(6) + 1))!
        //
    }
}

// 当你遵守 Hashable 协议的时候，你还要重载 == 操作符来比较两个对象
func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

// 这里Cookie 只是 MVC中的 model，sprite作为一个属性是view，所以没有让Cookie继承自SKSpriteNode
// Hashable 协议要求你有一个名为 hashValue 的属性，该值应该尽可能唯一，这里使用2D的位置作为该值
class Cookie: Printable, Hashable {
    var column: Int
    var row: Int
    let cookieType: CookieType
    // 精灵属性是可选的，因为Cookie不一定一直有精灵
    var sprite: SKSpriteNode?
    var description: String{
        return "type:\(cookieType) square:(\(column),\(row))"
    }
    var hashValue: Int {
        return row*10 + column
    }
    
    init(column: Int, row: Int, cookieType: CookieType){
        self.column = column
        self.row = row
        self.cookieType = cookieType
    }

    
    
}
