//
//  GameScene.swift
//  lolrus
//
//  Created by Alyx on 5/30/23.
//

import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Check for collisions
        if firstBody.categoryBitMask == PhysicsCategory.walrus && secondBody.categoryBitMask == PhysicsCategory.fish {
            if let fish = secondBody.node as? SKSpriteNode {
                fishDidCollide(withWalrus: firstBody.node as! SKSpriteNode, fish: fish)
            }
        } else if firstBody.categoryBitMask == PhysicsCategory.walrus && secondBody.categoryBitMask == PhysicsCategory.thief {
            if let thief = secondBody.node as? SKSpriteNode {
                thiefDidCollide(withWalrus: firstBody.node as! SKSpriteNode, thief: thief)
            }
        }
        
        //happy birthday to the ground
        let ground = SKNode()
        ground.position = CGPoint(x: frame.midX, y: frame.minY)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.none
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.fish | PhysicsCategory.thief
        addChild(ground)

        
        // Handle fish and ground collision
        if contact.bodyA.node == ground {
            contact.bodyB.node?.removeFromParent()
        } else if contact.bodyB.node == ground {
            contact.bodyA.node?.removeFromParent()
        }
    }
    private func fishDidCollide(withWalrus walrus: SKSpriteNode, fish: SKSpriteNode) {
        fish.removeFromParent()
        score += 10
        scoreLabel.text = "Score: \(score)"
        run(SKAction.playSoundFileNamed("success.mp3", waitForCompletion: false)) // Add success sound effect
    }

    private func thiefDidCollide(withWalrus walrus: SKSpriteNode, thief: SKSpriteNode) {
        thief.removeFromParent()
        lives -= 1
        livesLabel.text = "Lives: \(lives)" // Update lives label
        run(SKAction.playSoundFileNamed("failure.mp3", waitForCompletion: false)) // Add failure sound effect
        if lives <= 0 {
            // Game over
            walrus.removeFromParent()
            gameOver() // Call game over function when lives are zero

        }
    }

}


class GameScene: SKScene {

    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let all: UInt32 = UInt32.max
        static let walrus: UInt32 = 0b1 // 1
        static let fish: UInt32 = 0b10 // 2
        static let thief: UInt32 = 0b100 // 4
    }
    
    // Define nodes
    private var walrus: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var fallingSpeed: CGFloat = -40.0 //was -1.0
    
    // Define properties
    private var score = 0
    private var lives = 3
    
    
    override func didMove(to view: SKView) {
        // Initialize nodes
        initializeWalrus()
        initializeScoreLabel()
        
        // background music
        let backgroundMusic = SKAudioNode(fileNamed: "backgroundMusic.mp3")
        backgroundMusic.autoplayLooped = true
        backgroundMusic.run(SKAction.changeVolume(to: 0.6, duration: 0)) //drops volume
        addChild(backgroundMusic)
        
        //black background
        backgroundColor = SKColor.black
        
        /*can add a background image here later instead if u want
         let bgImage = SKSpriteNode(imageNamed: "bg")
         bgImage.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
         bgImage.zPosition = -1 // Ensure the background is behind other elements.
         addChild(bgImage)
         */
        
        //lives label
        livesLabel = SKLabelNode(fontNamed: "Arial")
        livesLabel.text = "Lives: \(lives)"
        livesLabel.fontSize = 15
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: self.size.width - 30, y: self.size.height - 40)
        addChild(livesLabel)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        let timer = SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnFallingObjects), SKAction.wait(forDuration: 3.0)])) //was 1.0
        run(timer)
        run(SKAction.repeatForever(
                   SKAction.sequence([
                       SKAction.wait(forDuration: 30.0), // wait for 30 seconds
                       SKAction.run(increaseFallingSpeed) // then run this function
                   ])
               ))
        func increaseFallingSpeed() {
            fallingSpeed -= 2.0 // increase the speed, was 0.2
        }
    }
    
    // Initialize walrus
    private func initializeWalrus() {
        walrus = SKSpriteNode(imageNamed: "walrus") // Add your walrus asset
        walrus.position = CGPoint(x: frame.midX, y: walrus.size.height/2)
        walrus.zPosition = 1
        addChild(walrus)
        walrus.physicsBody = SKPhysicsBody(texture: walrus.texture!, size: walrus.size)
        walrus.physicsBody?.isDynamic = false
        walrus.physicsBody?.categoryBitMask = PhysicsCategory.walrus
        walrus.physicsBody?.contactTestBitMask = PhysicsCategory.fish | PhysicsCategory.thief
        walrus.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    // Initialize score label
    private func initializeScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.fontSize = 15
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: 30, y: self.size.height - 40)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "Score: \(score)"
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
    }


    
    private func spawnFallingObjects() {
        let object: SKSpriteNode
        let objectType = Int.random(in: 0...5) //was 9

        if objectType < 1 {
            object = SKSpriteNode(imageNamed: "thief")
            object.physicsBody = SKPhysicsBody(texture: object.texture!, size: object.size)
            object.physicsBody?.categoryBitMask = PhysicsCategory.thief
        } else {
            object = SKSpriteNode(imageNamed: "fish")
            object.physicsBody = SKPhysicsBody(texture: object.texture!, size: object.size)
            object.physicsBody?.categoryBitMask = PhysicsCategory.fish
        }

        object.physicsBody?.contactTestBitMask = PhysicsCategory.walrus
        object.physicsBody?.collisionBitMask = 0
        object.physicsBody?.velocity.dy = fallingSpeed
        object.physicsBody?.angularVelocity = CGFloat.random(in: -3...3)
        object.physicsBody?.linearDamping = 0

        let xPos = CGFloat.random(in: object.size.width/2...size.width-object.size.width/2)
        object.position = CGPoint(x: xPos, y: size.height + object.size.height/2)

        addChild(object)
    }


    // Touch handling
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            // Add boundary conditions to restrict walrus within screen width
            let minBound = walrus.size.width/2
            let maxBound = self.size.width - walrus.size.width/2
            
            if location.x >= minBound && location.x <= maxBound {
                walrus.position.x = location.x
            }
        }
    }

    private func gameOver() {
        // Create and configure the scene.
        let gameOverScene = GameOverScene(size: size)
        gameOverScene.scaleMode = .aspectFill

        // Present the scene.
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }

    
}

class GameOverScene: SKScene {
   override init(size: CGSize) {
        super.init(size: size)
        
        // Set up your game over scene here
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = "Game Over. Tap To Play Again"
        label.fontSize = 20
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Transition back to the GameScene
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameScene, transition: reveal)
    }
}
