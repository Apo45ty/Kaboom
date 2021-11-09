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
}
