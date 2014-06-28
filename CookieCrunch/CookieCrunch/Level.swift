//
//  Level.swift
//  CookieCrunch
//
//  Created by FangYiXiong on 14-6-27.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    let cookies = Array2D<Cookie>(columns: NumColumns, rows:NumRows) //private
    let tiles = Array2D<Tile>(columns: NumColumns, rows:NumRows) // privarte
    
    init(filename: String){
        // 读取JSON文件
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename){
            // tilesArray 是一个二维数组
            if let tilesArray: AnyObject = dictionary["tiles"]{
                for (row, rowArray) in enumerate(tilesArray as Int[][]){
                    // 反转坐标系
                    let tileRow = NumRows - row - 1
                    // 当该值为1，就在该位置创建一个Tile
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }
    
    // 获取某行某列的 tile 的方法
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column,row]
    }
    
    // 获取某行某列的 cookie 的方法
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return cookies[column,row]
    }
    
    func shuffle() -> Set<Cookie> {
        return createInitialCookies()
    }
    
    func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        for row in 0..NumRows {
            for column in 0..NumColumns {
                // 判断当前位置是否有 Tile
                if tiles[column, row] != nil {
                    var cookieType = CookieType.random()
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    // 这里的let 的数组是可变的？
                    cookies[column, row] = cookie
                    set.addElement(cookie)
                }
            }
        }
        return set
    }
    
    
    
}