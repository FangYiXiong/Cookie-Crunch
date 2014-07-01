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
    var possibleSwaps = Set<Swap>() // private
    
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
    
    // 打乱🍰的顺序
    func shuffle() -> Set<Cookie> {
        var set: Set<Cookie>
        do {
            set = createInitialCookies()
            detectPossibleSwaps()
            println("possible swaps: \(possibleSwaps)")
        }
        while possibleSwaps.count == 0
        
        return set
    }
    
    // 检测是否是一个有效的交换
    func isPossibleSwap(swap: Swap) -> Bool {
        // 这里可行的原因是我们已经重载了 Swap 的 hashValue，调用==的时候比较的就是hashValue
        return possibleSwaps.containsElement(swap)
    }
    
    // 判断当前位置的纵向和横向是否可以消除
    func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && cookies[i, row]?.cookieType == cookieType;
            --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && cookies[i, row]?.cookieType == cookieType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && cookies[column, i]?.cookieType == cookieType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && cookies[column, i]?.cookieType == cookieType;
            ++i, ++vertLength { }
        return vertLength >= 3
    }
    
    // 检测所有可能的消除
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        for row in 0..NumRows {
            for column in 0..NumColumns {
                if let cookie = cookies[column, row] {
                    // TODO: 检测的逻辑代码
                    // 思路 1. 如果当前是🍰，那么执行检测逻辑，并把结果储存到 possibleSwaps 这个属性中
                    // 2. 同样的逻辑执行2遍，只是方向不同，第 1 次向右交换，第 2 次向上交换
                    
                    // 向右交换
                    // 判断右边是否到了边界
                    if column < NumColumns - 1 {
                        // 判断右边是否有🍰
                        if let other = cookies[column+1, row]{
                            // 交换两者
                            cookies[column, row] = other
                            cookies[column+1, row] = cookie
                            
                            // 检测当前是否可以消除
                            if hasChainAtColumn(column+1, row: row) ||
                               hasChainAtColumn(column, row: row) {
                                set.addElement(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // 交换回来
                            cookies[column, row] = cookie
                            cookies[column+1, row] = other
                        }
                    }
                    
                    // 向上交换
                    // 判断是否到了上边界
                    if row < NumRows - 1 {
                        // 判断上边是否是🍰
                        if let other = cookies[column, row + 1]{
                            // 交换两者
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            // 判断是否可以消除
                            if hasChainAtColumn(column, row: row) ||
                               hasChainAtColumn(column, row: row + 1) {
                                set.addElement(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // 交换回来
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                    
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        for row in 0..NumRows {
            for column in 0..NumColumns {
                // 判断当前位置是否有 Tile
                if tiles[column, row] != nil {
//                    var cookieType = CookieType.random()
//                    这里把随机的🍰类型注释掉，保证刚开始的时候没办法进行3连消除
                    var cookieType: CookieType
                    do {
                        cookieType = CookieType.random()
                    }while (column >= 2 && cookies[column - 1, row]?.cookieType == cookieType &&
                            cookies[column - 2, row]?.cookieType == cookieType)
                        || (row >= 2 && cookies[column, row - 1]?.cookieType == cookieType &&
                            cookies[column, row - 2]?.cookieType == cookieType)
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    // 这里的let 的数组是可变的？
                    cookies[column, row] = cookie
                    set.addElement(cookie)
                }
            }
        }
        return set
    }
    
    // 模型层的交换
    func performSwap(swap: Swap){
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
}