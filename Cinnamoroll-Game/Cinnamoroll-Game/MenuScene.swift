//
//  MenuScene.swift
//  Cinnamoroll-Game
//
//  Created by Vanessa Dubouzet on 2024-04-04.
//

import SpriteKit

class MenuScene: SKScene {
    var didWin: Bool
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(size: CGSize, didWin: Bool) {
        self.didWin = didWin
        super.init(size: size)
        scaleMode = .aspectFill
    }
    
    override func didMove(to view: SKView) {
        // Set background image based on whether player won or lost
        let backgroundImageName = didWin ? "win.png" : "lose.png"
        let backgroundImage = SKSpriteNode(imageNamed: backgroundImageName)
        backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundImage.zPosition = -1 // Ensure the background is behind other nodes
        addChild(backgroundImage)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameScene = GameScene(fileNamed: "GameScene") else {
            fatalError("GameScene not found")
        }
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: transition)
    }
}
