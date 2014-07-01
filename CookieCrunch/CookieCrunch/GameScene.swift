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
    var selectionSprite = SKSpriteNode()
    // 这是一个闭包函数，接受一个Swap的参数，没有返回值。这个属性可以是nil，所以使用Optional value ?
    var swipeHandler: ((Swap) -> ())?
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()
    
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
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
    
    // 选择🍰的高亮
    func showSelectionIndicatorForCookie(cookie: Cookie){
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            // 只设置texture不会同时设定正确的size，但是使用SKAction却会
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    // 取消🍰的高亮
    func hideSelectionIndicator() {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()
            ]))
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
                // 高亮选择的🍰
                showSelectionIndicatorForCookie(cookie)
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
                //取消高亮🍰
                hideSelectionIndicator()
                swipeFromColumn = nil
            }
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!){
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            //取消高亮🍰
            hideSelectionIndicator()
        }
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
                if let handler = swipeHandler {
                    let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                    handler(swap)
                    println(" **** swapping \(fromCookie) with \(toCookie)")
                }
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
    
    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        // 这里是游戏的一个通用的范式，等待一个动画结束，然后继续游戏。
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
        
        runAction(swapSound)
    }
    
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence([moveA,moveB]), completion:completion)
        spriteB.runAction(SKAction.sequence([moveB,moveA]))
        
        runAction(invalidSwapSound)
    }
}
 