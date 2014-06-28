//
//  Array2D.swift
//  CookieCrunch
//
//  Created by FangYiXiong on 14-6-27.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//

// 就是自己实现一个二维数组
class Array2D<T> {
    let columns: Int
    let rows: Int
    let array: Array<T?> // private
    
    init(columns: Int, rows: Int){
        self.columns = columns
        self.rows = rows
        array = Array<T?>(count: rows*columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
        }
        set {
            array[row*columns + column] = newValue
        }
    }
}
