//
//  GameScene.swift
//  Asteroids
//
//  Created by Shawky on 11/11/2019.
//  Copyright © 2019 Sorbonne. All rights reserved.
//

import SpriteKit
import GameplayKit

public extension CGRect {
    func points() -> [CGPoint] {
        return [
            CGPoint(x: self.minX, y: self.minY),
            CGPoint(x: self.maxX, y: self.maxY),
            CGPoint(x: self.minX, y: self.maxY),
            CGPoint(x: self.maxX, y: self.minY),
        ]
    }
}

class MyScene: SKScene,SKPhysicsContactDelegate {
    
    class LaserShot : SKShapeNode{
        
        static let Speed: CGFloat = 500.0
        static let MaxTime: CGFloat = 0.9
        
        var velocity: CGPoint
        var totalTime: CGFloat = 0.0
        
        init(position: CGPoint, angle: CGFloat, velocity: CGPoint) {
            self.velocity = CGPoint(x:
                cos(angle + CGFloat(Double.pi / 2)),y:
                sin(angle + CGFloat(Double.pi / 2))
                ) * LaserShot.Speed
            super.init()
            // Draw Line
            let path = CGMutablePath()
            path.addLines(between: [CGPoint(x: 0,y: 0), CGPoint(x: 0,y: 20)])
            self.path = path
            self.strokeColor = .white
            self.lineWidth = 4
            self.fillColor = .white
            self.strokeColor = .white
            self.position = position
            self.zPosition = 2
            self.name = "laser"
            // Add the velocity of the ship?
            //        self.velocity = self.velocity + velocity
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // Update Laser Shots
        func update(timeDelta: CGFloat) {
            totalTime += timeDelta
            if totalTime > LaserShot.MaxTime {
                self.removeFromParent()
                return
            }
            self.position = self.position + velocity * timeDelta
        }
    }
    
    
    // Sprites & Globals
    var bgNode = SKSpriteNode(imageNamed: "stars")
    var backgroundMusic: SKAudioNode!
    var ship = Ship()
    static let FireRate: Double = 0.17
    var lastBulletFiredAt: TimeInterval?
    var previousFrameTime: TimeInterval?
    var shipMoves = [Int]()
    var maxTouchMoveTime = CGFloat(0.8)
    var maxFireEffectLife = CGFloat(5.8)
    var currentTouchMoveTime = CGFloat(0.0)
    var currentFireMovesTime = CGFloat(0.0)
    var currentTouches = 0
    var touches: Set<UITouch> = []
    var fires: [SKEmitterNode] = []
    var currentTouchX = 0.0
    var currentTouchY = 0.0
    var generated = 0
    var diff = 0
    var score = 0
    let blastSound = SKAction.playSoundFileNamed("Blast.mp3", waitForCompletion: false)
    let scorelbl = SKLabelNode(fontNamed: "Chalkduster")
    var gameRunning = true
    weak var viewController: GameViewController!

    // Init Game
    override func didMove(to view: SKView) {
        
        bgNode.zPosition = 1
        bgNode.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        bgNode.size = view.frame.size
        ship.position = CGPoint(x: self.frame.width/2, y: 50)
        self.addChild(ship)
        ship.zRotation = 0
        ship.zPosition = 2
        backgroundMusic = SKAudioNode(url: Bundle.main.url(forResource: "GameMusic", withExtension: ".mp3")!)
        addChild(backgroundMusic)
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .black
        backgroundMusic.run(.play())
        generateAstroids()
        physicsWorld.contactDelegate = self
        self.addChild(bgNode)
        
        scorelbl.text = "Score: 0"
        scorelbl.fontSize = 45
        scorelbl.zPosition = 3
        scorelbl.fontColor = SKColor.white
        scorelbl.position = CGPoint(x: frame.maxX - 150, y: frame.maxY - 50)
        
        addChild(scorelbl)
    }
    
    
    // Bound Objects to Screen
    func wrapObject(node: SKNode, frame: CGRect) {
        if node.frame.maxX > self.frame.width + node.frame.width {
            node.position.x = -node.frame.size.width / 2
        } else if node.frame.minX < 0 - node.frame.width {
            node.position.x = self.frame.width - node.frame.width / 2
        }
        
        if node.frame.maxY > self.frame.height + node.frame.height {
            node.position.y = -node.frame.size.height / 2
        } else if node.frame.minY < 0 - node.frame.height {
            node.position.y = self.frame.height + node.frame.height / 2
        }
        // print(node.position.debugDescription)
    }
    // Touch Began
    func touchDown(atPoint pos : CGPoint, totalCount : Int) {
        currentTouchX = Double(pos.x)
        currentTouchY = Double(pos.y)
    }
    // Movmement Handling
    func touchMoved(toPoint pos : CGPoint) {
        //print("Pos " + pos.debugDescription)
        if Float(pos.x) - Float(currentTouchX) > 0
        {
            shipMoves.append(1)
        }
        if Float(pos.x) - Float(currentTouchX) < 0
        {
            shipMoves.append(2)
        }
        if Float(pos.y) - Float(currentTouchY)  > 0
        {
            shipMoves.append(3)
        }
        if Float(pos.y) - Float(currentTouchY) < 0
        {
            shipMoves.append(4)
        }
        currentTouchX = Double(pos.x)
        currentTouchY = Double(pos.y)
    }
 
    //
    // Touch Handling
    //

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            // if touch is first one move ship
            if self.touches.first == t
            {
                self.touchDown(atPoint: t.location(in: self), totalCount: touches.count)
            }
                // for every other touch register it and shoot
            else
            {
                self.touches.insert(t)
            }
            if self.touches.count > 1
            {
                shoot()
            }
            currentTouches+=1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if touch is first one move ship
        for t in touches {
            if t == self.touches.first
            {
                self.touchMoved(toPoint: t.location(in: self))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            currentTouches-=1
            self.touches.remove(t)
        }
        if currentTouches < 1
        {
            shipMoves.removeAll()
        }
    }
    
    // Game Loop
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let timeDelta = CGFloat(currentTime - (previousFrameTime ?? currentTime))
        // update ship position and speed
        ship.update(directions: shipMoves, timeDelta: timeDelta)
        // Clear touch input every maxTouchMoveTime
        if (currentTouchMoveTime > maxTouchMoveTime)
        {
            shipMoves.removeAll()
        }
        // Remove old fire effects
        if (currentFireMovesTime > maxFireEffectLife)
        {
            currentFireMovesTime = 0
            fires.forEach { (node) in
                node.removeFromParent()
            }
            fires.removeAll()
        }
        // Bound ship to screen corners
        wrapObject(node: ship, frame: self.frame)
        // for each point in ship frame, cross check with other sprites
        // if found asteroid sprite node, crash ship and game is over
        for p in ship.frame.points()
        {
        var shipcol = nodes(at: p)
        // Filter everything but astroids
            shipcol = shipcol.filter({$0.name == "ast"})
        // Count found asteroids collision, if any stop game
        if (shipcol.count > 0)
        {
            if(gameRunning)
            {
            endGame()
            }
        }
        }
        // update asteroids rotation and position
        self.enumerateChildNodes(withName: "ast")
        {c,_ in
            let n = c as! Asteroid
            n.update(timeDelta: timeDelta)
            self.wrapObject(node: c, frame: self.frame)
            //n.updatePosition(timeDelta: timeDelta)
        }
        // update laser shots and see if it hits asteroids
        self.enumerateChildNodes(withName: "laser")
        {c,_ in
            let n = c as! LaserShot
            n.update(timeDelta: timeDelta)
            self.wrapObject(node: c, frame: self.frame)
            let objects = self.nodes(at: n.position)
            for o in objects
            {
                // if hit remove asteroid and laser
                if o != n && o.name == "ast"
                {
                    // Create Fire Effect
                    let particle = SKEmitterNode(fileNamed: "Fire.sks")!
                    particle.position = o.position
                    particle.zRotation = o.zRotation
                    particle.numParticlesToEmit = 250
                    particle.name = "fire"
                    particle.alpha = 0.9
                    particle.zPosition = 2
                    self.addChild(particle)
                    self.fires.append(particle)
                    o.removeFromParent()
                    n.removeFromParent()
                    self.run(self.blastSound)
                    self.score += 1
                    self.scorelbl.text = "Score: " + self.score.description
                    // Generate more asteroids if needed
                    if (self.score >= self.generated - 1) {
                        self.generateAstroids()
                    }
                }
            }
        }
        currentTouchMoveTime += timeDelta
        currentFireMovesTime += timeDelta
        previousFrameTime = currentTime
    }
    
    // Shoot a laser
    func shoot() {
        if (gameRunning)
        {
        let shot = LaserShot(position: ship.position, angle: ship.rotation, velocity: ship.velocity)
        shot.zRotation = ship.zRotation
        self.addChild(shot)
        }
    }
    
    // Make 6 new random Asteroids and try not to collide with ship
    func generateAstroids ()
    {
        for _ in 0...6
        {
            let a = Asteroid()
            a.name = "ast"
            a.position = CGPoint(x: CGFloat(Float.random(in: 0...Float(self.frame.width))), y: CGFloat(Float.random(in: 0...Float(self.frame.height))))
            while (a.frame.intersects(ship.frame) == true)
            {
                 a.position = CGPoint(x: CGFloat(Float.random(in: 0...Float(self.frame.width))), y: CGFloat(Float.random(in: 0...Float(self.frame.height))))
            }
            a.zPosition = 2
            if score > 5 && diff > 0
            {
                a.MaxAcceleration = CGFloat(diff * 10)
            }
            addChild(a)
        }
        generated += 6
    }
    
    // Game Over
    func endGame () {
        backgroundMusic.removeFromParent()
        let particle = SKEmitterNode(fileNamed: "Fire.sks")!
        particle.position = ship.position
        particle.zRotation = ship.zRotation
        particle.numParticlesToEmit = 250
        //particle.particleSize = 250
        particle.name = "fire"
        particle.alpha = 0.9
        particle.zPosition = 2
        particle.particleTexture = ship.texture
        addChild(particle)
        run(blastSound)
        ship.removeFromParent()
        gameRunning = false
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Remove Game Scene and Create New Main Menu
            self.view?.removeFromSuperview()
            let parent = self.viewController.view.superview
            self.viewController.view.removeFromSuperview()
            self.viewController.view = nil
            parent?.addSubview(self.viewController.view)
            self.viewController.askHighScoreName(score: self.score)
        }
}
}
