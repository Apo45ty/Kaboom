//
//  Collectible.swift
//  Kaboom
//
//  Created by Antonio Tapia Maldonado on 11/9/21.
//

import Foundation
import SpriteKit

enum CollectibleType:String{
    case none
    case gloop
}

class Collectible:SKSpriteNode{
    //MARK:-Properties
    private var collectibleType:CollectibleType = .none
    private let playCollectSound = SKAction.playSoundFileNamed("collect.wav", waitForCompletion: false)
    private let playMissSound = SKAction.playSoundFileNamed("miss.wav", waitForCompletion: false)
    //MARK:-INIT
    init(collectibleType:CollectibleType){
        var texture : SKTexture!
        self.collectibleType=collectibleType
        switch self.collectibleType{
        case .gloop:
            texture = SKTexture(imageNamed: "gloop")
        case .none:
            break
        }
        
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.name = "co_\(collectibleType)"
        self.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.zPosition = Layer.collectible.rawValue
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: 0.0, y: -self.size.height/2.0))
        self.physicsBody?.affectedByGravity=false
        self.physicsBody?.categoryBitMask = PhysicsCategory.collectible
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.foreground
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name:"CIGaussianBlur",parameters: ["inputRadius":40.0])
    }
    
    required init?(coder aDecoder:NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:-FUNCTIONS
    func drop(dropSpeed:TimeInterval,floorLevel:CGFloat){
        let pos = CGPoint(x: position.x, y: floorLevel)
        let scaleX = SKAction.scaleX(to: 1.0, duration: 1.0)
        let scaleY = SKAction.scaleY(to: 1.3, duration: 1.0)
        let scale = SKAction.group([scaleX,scaleY])
        
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let moveAction = SKAction.move(to: pos, duration: dropSpeed)
        let actionSequence = SKAction.sequence([appear,scale,moveAction])
        
        self.scale(to: CGSize(width: 0.25, height: 1.0))
        self.run(actionSequence,withKey: "drop")
    }
    
    func collected(){
        let removeFromParent = SKAction.removeFromParent()
        let actionGroup = SKAction.group([playCollectSound,removeFromParent])
        self.run(actionGroup)
    }
    func missed(){
        let removeFromParent = SKAction.removeFromParent()
        let move = SKAction.moveBy(x: 0, y: -size.height/1.5, duration: 0.0)
        let splatX = SKAction.scaleX(to: 1.5, duration: 0.0)
        let splatY = SKAction.scaleY(to: 0.5, duration: 0.0)
        
        
        let actionGroup = SKAction.group([playMissSound,move,splatX,splatY])
        self.run(actionGroup)
    }
}
