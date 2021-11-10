//
//  SpriteKitHelper.swift
//  Kaboom
//
//  Created by Antonio Tapia Maldonado on 11/9/21.
//

import Foundation
import SpriteKit

enum Layer : CGFloat {
    case background
    case foreground
    case player
    case collectible
}

extension SKSpriteNode{
    
    func loadTextures(atlas: String,prefix:String,startsAt:Int,stopsAt:Int)->[SKTexture]{
        var textureArray=[SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)
        for i in startsAt...stopsAt {
            let textureName = "\(prefix)\(i)"
            let temp = textureAtlas.textureNamed(textureName)
            textureArray.append(temp)
        }
        return textureArray
    }
    
    func startAnimation(textures:[SKTexture],speed:Double,name:String,count:Int,resize:Bool,restore:Bool){
        if action(forKey: name)==nil {
            let animation = SKAction.animate(with: textures, timePerFrame: speed, resize: resize, restore: restore)
            if count==0 {
                let repearAction = SKAction.repeatForever(animation)
                run(repearAction,withKey: name)
            } else if count == 1{
                run(animation,withKey: name)
            } else {
                let repeatAction = SKAction.repeat(animation,count:count)
                run(repeatAction,withKey: name)
            }
        }
        
    }
}
