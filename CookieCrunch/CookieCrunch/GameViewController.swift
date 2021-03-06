//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by FangYiXiong on 14-6-27.
//  Copyright (c) 2014年 Fang YiXiong. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    // 这里的属性之所以加!的原因是所有属性在类初始化之后必须有初始值，而这里的属性必须要在viewDidLoad中初始化，所以要告诉编译器这些属性在使用前一定会初始化，不用担心了，但是记住，一定初始化之后，这些属性就不能再变成nil了，因为不是optional（那种情况要用?）
    var scene: GameScene!
    var level: Level!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置视图
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // 创建并配置场景
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // 创建并配置关卡
        level = Level(filename:"Level_3")
        scene.level = level
        scene.addTiles()
        // 这里将handleSwipe函数 传给 scene，这样每当GameScene这个类调用swipehandler(swap)时，它实际上调用的是GameViewController中的这个函数！可以这样做的原因是在Swift中，函数和闭包是可以交换的。
        scene.swipeHandler = handleSwipe
        
        
        // 展示场景
        skView.presentScene(scene)
        
        // 开始游戏
        beginGame()
    }
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        // 获得一组随机的cookies
        let newCookies = level.shuffle()
        scene.addSpriteForCookies(newCookies)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap){
            level.performSwap(swap)
            scene.animateSwap(swap){
                self.view.userInteractionEnabled = true
            }
        }else{
            scene.animateInvalidSwap(swap){
                self.view.userInteractionEnabled = true
            }
        }

    }
    
}
