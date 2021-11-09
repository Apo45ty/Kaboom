//
//  GameScene.swift
//  Kaboom
//
//  Created by Antonio Tapia Maldonado on 11/6/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
  
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background_1")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.background.rawValue/.          addChild(background)
        
        let foreground = SKSpriteNode(imageNamed:  "foreground_1")
        foreground.anchorPoint = CGPoint(x: 0, y: 0)
        foreground.position = CGPoint(x: 0, y: 0)
        foreground.zPosition = Layer.foreground.rawValue
        addChild(foreground)
        
        let player = Player()
        player.position = CGPoint(x: size.width/2, y: foreground.frame.maxY)
        addChild(player)
    }
    
    
  
}
