//
//  Asteroid.swift
//  Asteroids
//
//  Created by Shawky on 24/11/2019.
//  Copyright © 2019 Sorbonne. All rights reserved.
//

import Foundation
import SpriteKit

class Asteroid : SKSpriteNode {
    
    let RotationSpeed: CGFloat = CGFloat(Float.random(in: 1...5))
    var MaxAcceleration: CGFloat = 10.0
    static let Deceleration: CGFloat = 0.995
    static let MaxSpeed: CGFloat = 300.0

    var rotation: CGFloat = CGFloat(Float.random(in: 1...5))
    var acceleration = CGPoint(x: CGFloat(Float.random(in: 1...5)), y: CGFloat(Float.random(in: 1...5)))
    var velocity = CGPoint(x: CGFloat(Float.random(in: 1...5)), y: CGFloat(Float.random(in: 1...5)))
    
    init() {
          let astroids_textures = ["ast1","ast2","ast3","ast4","ast5","ast6","ast7","ast8"]
             let random_name = astroids_textures[Int.random(in: 0...7)]
        let texture = SKTexture(imageNamed: random_name)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        // node.zRotation = CGFloat(Double.pi / 2)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.3)
        self.name = "astroid"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     func update(timeDelta: CGFloat) {
        if  Int.random(in: 0...5) > Int.random(in: 0...5) {
            rotation = rotation - timeDelta * Ship.RotationSpeed
        } else if Int.random(in: 0...5) > Int.random(in: 0...5) {
            rotation = rotation + timeDelta * Ship.RotationSpeed
        }
        
        if  Int.random(in: 0...5) > Int.random(in: 0...5) {
            accelerate()
        } else {
            stop()
        }
        
        updateVelocity()
        updatePosition(timeDelta: timeDelta)
    }
    
    func accelerate() {
        if Int.random(in: 0...5) > Int.random(in: 0...5)
        {
            self.acceleration.x = cos(self.zRotation + CGFloat(Double.pi / 2))
        }
        if  Int.random(in: 0...5) > Int.random(in: 0...5)
        {
            self.acceleration.y = sin(self.zRotation + CGFloat(Double.pi / 2))
        }
        if  Int.random(in: 0...5) > Int.random(in: 0...5)
        {
            self.acceleration.y = sin(self.zRotation + CGFloat(Double.pi / 2))
        }
        if self.acceleration.length > self.MaxAcceleration {
           self.acceleration = acceleration * (self.MaxAcceleration / self.acceleration.length)
        }
        if  Int.random(in: 0...5) > Int.random(in: 0...5)
        {
            if acceleration.y > 0
            {
                acceleration.y = acceleration.y * -1
            }
        }
    }
    
    func stop() {
        acceleration = CGPoint(x: 0,y: 0)
    }
    
    func updateVelocity() {
        if acceleration.length > 0 {
            velocity = velocity + acceleration
        } else if acceleration.length < 0{
            velocity = velocity * acceleration
        }
        else {
            velocity = velocity * Ship.Deceleration
        }
        //velocity.x = node.zRotation
        if velocity.length > Ship.MaxSpeed {
            velocity = velocity * (Ship.MaxSpeed / velocity.length)
        }
    }
    
    func updatePosition(timeDelta: CGFloat) {
        self.zRotation = rotation
        self.position = self.position + velocity * timeDelta
    }
}

