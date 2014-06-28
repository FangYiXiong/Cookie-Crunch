//
//  Set.swift
//  CookieCrunch
//
//  Created by FangYiXiong on 14-6-27.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//

// 自己实现一个Set
class Set<T: Hashable>: Sequence, Printable{
    var dictionary = Dictionary<T, Bool>() // private
    
    func addElement(newElement: T){
        dictionary[newElement] = true
    }
    
    func removeElement(element: T){
        dictionary[element] = nil
    }
    
    func containsElement(element: T) -> Bool {
        return dictionary[element] != nil
    }
    
    func allElements() -> T[] {
        return Array(dictionary.keys)
    }
    
    var count: Int {
        return dictionary.count
    }
    
    func unionSet(otherSet: Set<T>) -> Set<T> {
        var combined = Set<T>()
        
        for obj in dictionary.keys {
            combined.dictionary[obj] = true
        }
        
        for obj in otherSet.dictionary.keys {
            combined.dictionary[obj] = true
        }
        
        return combined
    }
    
    // Set 遵守 Sequence 协议并实现 generate() 方法来返回一个所谓的 “generator” 对象. 这样你就可以在 for in 循环中使用 Set
    func generate() -> IndexingGenerator<Array<T>>{
        return allElements().generate()
    }
    
    var description: String {
        return dictionary.description
    }
    
}