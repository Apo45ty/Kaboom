//
//  Player.swift
//  Kaboom
//
//  Created by Antonio Tapia Maldonado on 11/9/21.
//

import Foundation
import SpriteKit

enum PlayerAnimationType:String{
    case walk
    case die
}

class Player : SKSpriteNode{
    //MARK:- PROPERTIES
    private var walkTextures:[SKTexture]?
    private var dieTextures:[SKTexture]?
    //MARK:- INIT
    init(){
        let texture = SKTexture(imageNamed: "blob-walk_0")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.walkTextures = self.loadTextures(atlas: "blob", prefix: "blob-walk_", startsAt: 0, stopsAt: 2)
        self.dieTextures = self.loadTextures(atlas: "blob", prefix: "blob-die_", startsAt: 0, stopsAt: 0)
        self.name = "player"
        self.setScale(1.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        self.zPosition = Layer.player.rawValue
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size,center: CGPoint(x: 0.0, y: self.size.height/2.0))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    required init?(coder aDecoder:NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-Methods
    func setupConstraint(floor:CGFloat){
        let range = SKRange(lowerLimit: floor,upperLimit: floor)
        let lockToPlatform = SKConstraint.positionY(range)
        constraints = [lockToPlatform]
    }
    func die(){
        //Check for textures
        guard let dieTextures = dieTextures else {
            preconditionFailure("Could not find textures!")
        }
        removeAction(forKey: PlayerAnimationType.walk.rawValue)
        startAnimation(textures: dieTextures, speed: 0.25, name: PlayerAnimationType.die.rawValue, count: 0, resize: true, restore: true)
    }
    func walk(){
        //Check for textures
        guard let walkTextures = walkTextures else {
            preconditionFailure("Could not find textures!")
        }
        removeAction(forKey: PlayerAnimationType.die.rawValue)
        // run animation
        startAnimation(textures: walkTextures, speed: 0.25, name: PlayerAnimationType.walk.rawValue, count: 0, resize: true, restore: true)
    }
    func moveToPosition(pos:CGPoint,direction:String,speed:TimeInterval){
        switch direction{
        case "L":
            xScale = -abs(xScale)
        default:
            xScale = abs(xScale)
        }
        let moveAction = SKAction.move(to: pos, duration: speed)
        run(moveAction)
    }
}
