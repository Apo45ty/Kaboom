//
//  GameScene.swift
//  Kaboom
//
//  Created by Antonio Tapia Maldonado on 11/6/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player = Player()
    let playerSpeed:CGFloat = 1.5
    var level : Int = 1
    var numberOfDrops : Int = 10
    var dropSpeed : CGFloat = 1.0
    var minDropSpeed : CGFloat = 0.12
    var maxDropSpeed:CGFloat=1.0
    var movingPlayer : Bool = false
    var lastPosition : CGPoint?
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background_1")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.background.rawValue
        addChild(background)
        
        let foreground = SKSpriteNode(imageNamed:  "foreground_1")
        foreground.anchorPoint = CGPoint(x: 0, y: 0)
        foreground.position = CGPoint(x: 0, y: 0)
        foreground.zPosition = Layer.foreground.rawValue
        addChild(foreground)
        
        player.position = CGPoint(x: size.width/2, y: foreground.frame.maxY)
        player.setupConstraint(floor: foreground.frame.maxY)
        addChild(player)
        player.walk()
        
        spawnMultipleGloop()
        
    }
    
    // MARK:-TOUCH HANDELING
    
    func touchDown(atPoint pos:CGPoint){
        let touchedNode = atPoint(pos)
        if(touchedNode.name == "player"){
            movingPlayer = true
        }
//        let distance = hypot(pos.x-player.position.x, pos.y-player.position.y)
//        let calculateSpeed = TimeInterval(distance/playerSpeed) / 255
//
//        if pos.x < player.position.x {
//            player.moveToPosition(pos: pos,direction: "L", speed: calculateSpeed)
//        } else {
//            player.moveToPosition(pos: pos,direction: "R", speed: calculateSpeed)
//        }
    }
    
    func touchMoved(toPoint pos:CGPoint){
        if movingPlayer {
            let newPos = CGPoint(x: pos.x, y: player.position.y)
            player.position = newPos
            let recordedPosition = lastPosition ?? player.position
            if recordedPosition.x > newPos.x{
                player.xScale = -abs(player.xScale)
            }else{
                player.xScale = abs(player.xScale)
            }
            lastPosition = newPos
        }
    }
    
    func touchUp(atPoint pos:CGPoint){
        movingPlayer=false;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches{ self.touchMoved(toPoint:t.location(in: self))}
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint:t.location(in: self))
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint:t.location(in: self))
        }
    }
    //MARK:-GAME FUNCTIONS
    func spawnGloop(){
        let collectible = Collectible(collectibleType: CollectibleType.gloop)
        let margin = collectible.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX+margin,upperLimit: frame.maxX-margin)
        let randomX = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)
        collectible.position=CGPoint(x: randomX, y: player.position.y*2.5)
        addChild(collectible)
        collectible.drop(dropSpeed: TimeInterval(1.0), floorLevel: player.frame.minY)
    }
    func spawnMultipleGloop(){
        
        switch level {
        case 1,2,3,4,5:
            numberOfDrops = level * 10
        case 6:
            numberOfDrops = 75
        case 7:
            numberOfDrops = 100
        case 8:
            numberOfDrops = 150
        default:
            numberOfDrops = 150
        }
        
        
        dropSpeed = 1 / ( CGFloat(level) + ( CGFloat(level) / CGFloat(numberOfDrops) ) )
        if dropSpeed < minDropSpeed {
            dropSpeed = minDropSpeed
        } else if dropSpeed > maxDropSpeed {
            dropSpeed = maxDropSpeed
        }
        
        let wait = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn = SKAction.run{
            [unowned self] in self.spawnGloop()
        }
        let sequence = SKAction.sequence([wait,spawn])
        
        
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrops)
        
        run(repeatAction,withKey: "gloop")
        
    }
}
