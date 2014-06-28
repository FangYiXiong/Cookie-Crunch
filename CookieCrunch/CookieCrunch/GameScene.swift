//
//  GameScene.swift
//  CookieCrunch
//
//  Created by FangYiXiong on 14-6-27.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var level: Level!
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    init(size: CGSize){
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed:"Background")
        addChild(background)
        
        addChild(gameLayer)
        
        // 因为之前将錨点设置为屏幕的中心点，而cookiesLayer的位置应该为左下角，所以这里这么设置：
        let layerPosition = CGPoint(x: -TileWidth * CGFloat(NumColumns) / 2, y: -TileHeight * CGFloat(NumRows) / 2)
        
        cookiesLayer.position = layerPosition
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(cookiesLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    func addTiles(){
        for row in 0..NumRows{
            for column in 0..NumColumns {
                if let tile = level.tileAtColumn(column, row: row){
                    let tileNode = SKSpriteNode(imageNamed:"Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    func addSpriteForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row:cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * TileWidth + TileWidth/2,
            y: CGFloat(row) * TileHeight + TileHeight/2)
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!){
        // 1. 将触摸的位置转换为cookiesLayer的坐标
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        // 2. 找到这个是否位置是否在 9x9 的格子内
        let (success, column, row) = convertPoint(location)
        if success {
            // 3. 验证该处是一个🍰还是一个空格子
            if let cookie = level.cookieAtColumn(column, row: row){
                // 4. 是🍰，记录行列号
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!){
        // 如果在格子外，直接返回
        if swipeFromColumn == nil { return }
        
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! { // 向走滑
                horzDelta = -1
            } else if column > swipeFromColumn! {
                horzDelta = 1
            } else if row < swipeFromRow! {
                vertDelta = -1
            } else if row > swipeFromRow! {
                vertDelta = 1
            }
            
            if (horzDelta != 0 || vertDelta != 0) {
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!){
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!){
        touchesEnded(touches, withEvent: event)
    }
    
    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int){
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        if toColumn < 0 || toColumn > NumColumns { return }
        if toRow < 0 || toRow > NumRows { return }
        
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
            if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!) {
                println(" **** swapping \(fromCookie) with \(toCookie)")
            }
        }
    }
    
    // 这个函数将位置的点转换为🍰的行列号
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int){
        if (point.x >= 0 && point.x < CGFloat(NumColumns) * TileWidth && point.y >= 0 && point.y < CGFloat(NumRows) * TileHeight) {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0) // 无效的位置
        }
    }
}
 