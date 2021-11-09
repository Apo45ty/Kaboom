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
}

class Player : SKSpriteNode{
    //MARK:- PROPERTIES
    private var walkTextures:[SKTexture]?
    //MARK:- INIT
    init(){
        let texture = SKTexture(imageNamed: "blob-walk_0")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.walkTextures = self.loadTextures(atlas: "blob", prefix: "blob-walk_", startsAt: 0, stopsAt: 2)
        self.name = "player"
        self.setScale(1.0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        self.zPosition = Layer.player.rawValue
    }
    required init?(coder aDecoder:NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}
