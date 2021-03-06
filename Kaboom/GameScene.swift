//
//  GameScene.swift
//  Kaboom
//
//  Created by Antonio Tapia Maldonado on 11/6/21.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    var prevDropLocation : CGFloat = 0.0
    let player = Player()
    let playerSpeed:CGFloat = 1.5
    var level : Int = 1{
        didSet{
            levelLable.text = "Level : \(level)"
        }
    }
    var score: Int = 0{
        didSet{
            scoreLable.text = "Score : \(score)"
        }
    }
    var numberOfDrops : Int = 10
    var dropSpeed : CGFloat = 1.0
    var minDropSpeed : CGFloat = 0.12
    var maxDropSpeed:CGFloat=1.0
    var movingPlayer : Bool = false
    var lastPosition : CGPoint?
    var scoreLable : SKLabelNode = SKLabelNode()
    var levelLable : SKLabelNode = SKLabelNode()
    let musicAudioNode = SKAudioNode(fileNamed: "music.mp3")
    let bubblesAudioNode = SKAudioNode(fileNamed: "bubbles.mp3")
    var gameInProgress = false
    var dropsExpected = 10
    var dropsCollected = 0
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        audioEngine.mainMixerNode.outputVolume = 0.0
        
        musicAudioNode.autoplayLooped = true
        musicAudioNode.isPositional = false
        addChild(musicAudioNode)
        
        musicAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
        run(SKAction.wait(forDuration: 1.0),completion: {
           [unowned self] in
            self.audioEngine.mainMixerNode.outputVolume = 1.0
            self.musicAudioNode.run(SKAction.changeVolume(to: 0.75, duration: 2.0))
        })
        
        run(SKAction.wait(forDuration: 1.5),completion: {
            [unowned self] in
            self.bubblesAudioNode.autoplayLooped = true
            self.addChild(self.bubblesAudioNode)
        })
        
        let background = SKSpriteNode(imageNamed: "background_1")
        background.position = CGPoint(x: 0, y: 0)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.background.rawValue
        background.name = "background"
        addChild(background)
        
        let foreground = SKSpriteNode(imageNamed:  "foreground_1")
        foreground.anchorPoint = CGPoint(x: 0, y: 0)
        foreground.position = CGPoint(x: 0, y: 0)
        foreground.zPosition = Layer.foreground.rawValue
        foreground.physicsBody=SKPhysicsBody(edgeLoopFrom: foreground.frame)
        foreground.physicsBody?.affectedByGravity=false
        foreground.physicsBody?.categoryBitMask = PhysicsCategory.foreground
        foreground.physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        foreground.physicsBody?.collisionBitMask = PhysicsCategory.none
        foreground.name = "foreground"
        addChild(foreground)
        
        player.position = CGPoint(x: size.width/2, y: foreground.frame.maxY)
        player.setupConstraint(floor: foreground.frame.maxY)
        addChild(player)
        player.walk()
        
        setupLabels()
        showMessage("Tap to Start game")
        setupGloopFlow()
        
        
    }
    
    // MARK:-TOUCH HANDELING
    
    func touchDown(atPoint pos:CGPoint){
        if !gameInProgress{
            spawnMultipleGloop()
            return
        }
        let touchedNodes = nodes(at:pos)
        
        for touchedNode in touchedNodes{
            if(touchedNode.name == "player"){
                movingPlayer = true
            }
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
    func setupLabels(){
        scoreLable.name = "score"
        scoreLable.fontName = "Nosifer"
        scoreLable.fontColor = .yellow
        scoreLable.fontSize = 35.0
        scoreLable.horizontalAlignmentMode = .right
        scoreLable.verticalAlignmentMode = .center
        scoreLable.zPosition=Layer.ui.rawValue
        scoreLable.position = CGPoint(x: frame.maxX - 50, y: viewTop()-100)
        scoreLable.text = "Score : 0"
        addChild(scoreLable)
        
        levelLable.name = "level"
        levelLable.fontName = "Nosifer"
        levelLable.fontColor = .yellow
        levelLable.fontSize = 35.0
        levelLable.horizontalAlignmentMode = .left
        levelLable.verticalAlignmentMode = .center
        levelLable.zPosition=Layer.ui.rawValue
        levelLable.position = CGPoint(x: frame.minX + 50, y: viewTop()-100)
        levelLable.text = "Level : \(level)"
        addChild(levelLable)
        
    }
    func showMessage(_ message : String){
        let messageLable = SKLabelNode()
        messageLable.name = "message"
        messageLable.position = CGPoint(x: frame.midX, y: player.frame.maxY+100)
        messageLable.zPosition = Layer.ui.rawValue
        messageLable.numberOfLines=2
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributes:[NSAttributedString.Key:Any] = [
            .foregroundColor : SKColor(red: 251.0/255.0, green: 155.0/255.0, blue: 24.0/255.0, alpha: 1.0 ),
            .backgroundColor : UIColor.clear,
            .font:UIFont(name: "Nosifer", size: 45.0)!,
            .paragraphStyle : paragraph
        ]
        
        messageLable.attributedText = NSAttributedString(string: message, attributes: attributes)
        
        messageLable.run(SKAction.fadeIn(withDuration: 0.25))
        addChild(messageLable)
    }
    
    func hideMessage(){
        if let messageLable = childNode(withName: "//message") as? SKLabelNode{
            messageLable.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.25),SKAction.removeFromParent()]))
        }
    }
    
    func spawnGloop(){
        let collectible = Collectible(collectibleType: CollectibleType.gloop)
        let margin = collectible.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX+margin,upperLimit: frame.maxX-margin)
        var randomX = CGFloat.random(in: dropRange.lowerLimit...dropRange.upperLimit)
        
        let randomModifier = SKRange(lowerLimit: 50+CGFloat(level), upperLimit: 60*CGFloat(level))
        var modifier = CGFloat.random(in: randomModifier.lowerLimit...randomModifier.upperLimit)
        
        if modifier > 400 { modifier = 400}
        
        if prevDropLocation == 0.0 {
            prevDropLocation = randomX
        }
        
        if prevDropLocation < randomX {
            randomX = prevDropLocation + modifier
        } else {
            randomX = prevDropLocation - modifier
        }
        
        if randomX <= (frame.minX+margin) {
            randomX = frame.minX+margin
        } else if randomX > frame.maxX-margin{
            randomX = frame.maxX-margin
        }
        
        prevDropLocation = randomX
        
        collectible.position=CGPoint(x: randomX, y: player.position.y*2.5)
        
        let xLable = SKLabelNode()
        xLable.name = "dropNumber"
        xLable.fontName = "AvenirNext-DemiBold"
        xLable.fontColor = UIColor.yellow
        xLable.fontSize = 22.0
        xLable.text = "\(numberOfDrops)"
        xLable.position = CGPoint(x: 0, y: 2)
        collectible.addChild(xLable)
        numberOfDrops-=1
        addChild(collectible)
        collectible.drop(dropSpeed: TimeInterval(1.0), floorLevel: player.frame.minY)
    }
    func spawnMultipleGloop(){
        player.mumble()
        player.walk()
        hideMessage()
        if !gameInProgress{
            score = 0
            level = 1
        }
        gameInProgress = true
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
        
        dropsCollected = 0
        dropsExpected=numberOfDrops
        
        
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
    
    func gameOver (){
        showMessage("Game over\nTap to try again")
        gameInProgress = false
        resetPlayerPosition()
        popRemainingDrops()
        player.die()
        removeAction(forKey: "gloop")
        enumerateChildNodes(withName: "//co_*"){
            (node,stop) in
            node.removeAction(forKey: "drop")
            node.physicsBody=nil
        }
    }
    func resetPlayerPosition(){
        let resetPoint = CGPoint(x: frame.midX, y: player.position.y)
        let distance = hypot(resetPoint.x-player.position.x,0)
        let calculateSpeed = TimeInterval(distance / (playerSpeed * 2)) / 255
        if player.position.x > frame.midX {
            player.moveToPosition(pos: resetPoint, direction: "L", speed: calculateSpeed)
        } else{
            player.moveToPosition(pos: resetPoint, direction: "R", speed: calculateSpeed)
        }
    }
    func popRemainingDrops(){
        var i = 0
        enumerateChildNodes(withName: "//co_*"){
            (node,stop) in
            let initialWait = SKAction.wait(forDuration: 1.0)
            let wait = SKAction.wait(forDuration: TimeInterval(0.15*CGFloat(i)))
            let removeFromParent = SKAction.removeFromParent()
            let actionSequence = SKAction.sequence([initialWait,wait,removeFromParent])
            
            node.run(actionSequence)
            i+=1
        }
    }
    func checkForRemainingDrops(){
if dropsCollected == dropsExpected{
            nextLevel()
        }
    }
    func nextLevel(){
        showMessage("Get Ready")
        let wait = SKAction.wait(forDuration: 2.25)
        run(wait,completion:{
            [unowned self] in self.level+=1
        })
        self.spawnMultipleGloop()
    }
    //MARK:- Gloop Flow & Particle Effects
    func setupGloopFlow(){
        let gloopFlow = SKNode()
        gloopFlow.name = "gloopFlow"
        gloopFlow.zPosition = Layer.foreground.rawValue
        gloopFlow.position = CGPoint(x: 0.0, y: -60.0)
        
        gloopFlow.setupScrollingView(imageNamed: "flow_1", layer: Layer.foreground, blocks: 3, speed: 30.0,emitterNamed: "GloopFlow.sks")
        
        addChild(gloopFlow)
    }
}
//MARK:-COLLLISION DETECTIO
extension GameScene : SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision =  contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.player | PhysicsCategory.collectible{
             print("player hit collectable")
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ?
            contact.bodyA.node:
            contact.bodyB.node
            
            if let sprite = body as? Collectible{
                sprite.collected()
                score += level
                dropsCollected += 1
                checkForRemainingDrops()
                let chomp = SKLabelNode(fontNamed: "Nosifer")
                chomp.name = "chomp"
                chomp.alpha = 0.0
                chomp.fontSize = 22.0
                chomp.text="gloop"
                chomp.horizontalAlignmentMode = .center
                chomp.verticalAlignmentMode = .bottom
                chomp.position = CGPoint(x: player.position.x, y: player.frame.maxY+25)
                chomp.zRotation = CGFloat.random(in: -0.15...0.15)
                addChild(chomp)
                
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.45)
                let moveUp = SKAction.moveBy(x: 0.0, y: 45, duration: 0.45)
                let groupAction = SKAction.group([fadeOut,moveUp])
                let removeFromParent = SKAction.removeFromParent()
                let chompActions = SKAction.sequence([fadeIn,groupAction,removeFromParent])
                
                chomp.run(chompActions)
            }
            
        }
        if collision == PhysicsCategory.foreground | PhysicsCategory.collectible{
            print("collectable hit ground")
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ?
            contact.bodyA.node:
            contact.bodyB.node
            
            
            if let sprite = body as? Collectible{
                sprite.missed()
                gameOver()
            }
        }
    }
}
