//
//  GameScene.swift
//  Cinnamoroll-Game
//
//  Created by Vanessa Dubouzet on 2024-04-04.
//
import SpriteKit

class GameScene: SKScene {
    let playerSpeed: CGFloat = 150.0
    let catSpeed: CGFloat = 60.0
    
    var chest: SKSpriteNode?
    var player: SKSpriteNode?
    var heart1: SKSpriteNode?
    var heart2: SKSpriteNode?
    var heart3: SKSpriteNode?
    var heart4: SKSpriteNode?
    var key: SKSpriteNode?
    var cats: [SKSpriteNode] = []
    
    var lastTouch: CGPoint? = nil
    
    var lifeLabel: UILabel!
    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
    
    var life = 1
    
    var hasKey = false
    
    override func didMove(to view: SKView) {
        // Set up physics world's contact delegate
        physicsWorld.contactDelegate = self
        
        // Set up player
        player = childNode(withName: "player") as? SKSpriteNode
        listener = player
        let backgroundMusic = SKAudioNode(fileNamed: "bgmusic.wav")
        addChild(backgroundMusic)
        
        // Set the initial volume
        backgroundMusic.run(SKAction.changeVolume(to: 0.1, duration: 0))
        
        // Set up cats
        for child in self.children {
            if child.name == "cat", let cat = child as? SKSpriteNode {
                cats.append(cat)
            }
        }
        
        // Set up goal
        chest = childNode(withName: "chest") as? SKSpriteNode
        
        // Set up heart/lives
        heart1 = childNode(withName: "heart1") as? SKSpriteNode
        heart2 = childNode(withName: "heart2") as? SKSpriteNode
        heart3 = childNode(withName: "heart3") as? SKSpriteNode
        heart4 = childNode(withName: "heart4") as? SKSpriteNode
        
        // Set up key
        key = childNode (withName: "key") as? SKSpriteNode
        
        // Set up initial camera position
        updateCamera()
        
        // Set up life label if it doesn't exist
        if lifeLabel == nil {
            lifeLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 200, height: 30))
            lifeLabel.text = "Lives: \(life)"
            lifeLabel.textColor = UIColor.white
            lifeLabel.font = UIFont.systemFont(ofSize: 20)
            view.addSubview(lifeLabel)
        }
        
        messageLabel.center = view.center
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor.red
        messageLabel.font = UIFont.systemFont(ofSize: 20)
    }
    
    // Touch Handling...
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        handleTouches(touches)
    }
    
    fileprivate func handleTouches(_ touches: Set<UITouch>) {
        lastTouch = touches.first?.location(in: self)
    }
    
    override func didSimulatePhysics() {
        if player != nil {
            updatePlayer()
            updateCats()
        }
    }
    
    // Determines whether the player's position should be updated
    fileprivate func shouldMove(currentPosition: CGPoint,
                                touchPosition: CGPoint) -> Bool {
        guard let player = player else { return false }
        return abs(currentPosition.x - touchPosition.x) > player.frame.width / 2 ||
        abs(currentPosition.y - touchPosition.y) > player.frame.height / 2
    }
    
    fileprivate func updatePlayer() {
        guard let player = player,
              let touch = lastTouch
        else { return }
        let currentPosition = player.position
        if shouldMove(currentPosition: currentPosition,
                      touchPosition: touch) {
            updatePosition(for: player, to: touch, speed: playerSpeed)
            updateCamera()
        } else {
            player.physicsBody?.isResting = true
        }
    }
    
    fileprivate func updateCamera() {
        guard let player = player else { return }
        camera?.position = player.position
    }
    
    // Updates the position of all zombies by moving towards the player
    func updateCats() {
        guard let player = player else { return }
        let targetPosition = player.position
        
        for cat in cats {
            updatePosition(for: cat, to: targetPosition, speed: catSpeed)
        }
    }
    
    fileprivate func updatePosition(for sprite: SKSpriteNode,
                                    to target: CGPoint,
                                    speed: CGFloat) {
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y,
                                       currentPosition.x - target.x)

        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
        
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        sprite.physicsBody?.velocity = newVelocity
    }
}

// MARK: - SKPhysicsContactDelegate
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
        
        if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            cats.contains(secondBody.node as! SKSpriteNode) {
            life -= 1
            updateLifeLabel(life)
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
                    secondBody.categoryBitMask == chest?.physicsBody?.categoryBitMask {
            if hasKey{
                messageLabel.removeFromSuperview()
                gameOver(true)
            } else {
                messageLabel.text = "Find the key first!"
                view!.addSubview(messageLabel)
            }
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
                    secondBody.categoryBitMask == heart1?.physicsBody?.categoryBitMask {
            heart1?.removeFromParent()
            life += 1
            updateLifeLabel(life)
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
                    secondBody.categoryBitMask == heart2?.physicsBody?.categoryBitMask {
            heart2?.removeFromParent()
            life += 1
            updateLifeLabel(life)
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
                    secondBody.categoryBitMask == heart3?.physicsBody?.categoryBitMask {
            heart3?.removeFromParent()
            life += 1
            updateLifeLabel(life)
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
                    secondBody.categoryBitMask == heart4?.physicsBody?.categoryBitMask {
            heart4?.removeFromParent()
            life += 1
            updateLifeLabel(life)
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
                    secondBody.categoryBitMask == key?.physicsBody?.categoryBitMask {
            hasKey = true
            messageLabel.removeFromSuperview()
            key?.isHidden = true
        }
    }
    
    func updateLifeLabel(_ life: Int) {
        if life > 4 {
            self.life = 5
        } else if life == 0 {
            gameOver(false)
        }
        lifeLabel.text = "Lives: \(life)"
    }
    
    func resetLives() {
        life = 0
    }
    
    fileprivate func gameOver(_ didWin: Bool) {
        let menuScene = MenuScene(size: size, didWin: didWin)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        view?.presentScene(menuScene, transition: transition)
        lifeLabel.removeFromSuperview()
        messageLabel.removeFromSuperview()
        resetLives()
    }
}
