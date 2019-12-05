//
//  Ship.swift
//  Asteroids
//
//  Created by Shawky on 24/11/2019.
//  Copyright © 2019 Sorbonne. All rights reserved.
//

import Foundation
import SpriteKit

public extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }
    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
    var length : CGFloat {
        return sqrt(x*x + y*y)
    }
    static func / (left: CGPoint, right: CGVector) -> CGPoint {
        return CGPoint(x: left.x / right.dx, y: left.y / right.dy)
    }
    static func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scalar, y: point.y / scalar)
    }
}

class Ship : SKSpriteNode {

    static let RotationSpeed: CGFloat = 2.0
    static let MaxAcceleration: CGFloat = 10.0
    static let Deceleration: CGFloat = 0.995
    static let MaxSpeed: CGFloat = 300.0
    
    var rotation: CGFloat = 0.0
    var acceleration = CGPoint(x: 0, y: 0)
    var velocity = CGPoint(x: 0, y: 0)
    
    init() {
        let texture = SKTexture(imageNamed: "ship")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
              self.name = "ship"
       // self.zRotation = CGFloat(Double.pi / 2)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(directions: [Int], timeDelta: CGFloat) {
        if directions.contains(1) {
            rotation = rotation - timeDelta * Ship.RotationSpeed
        } else if directions.contains(2) {
            rotation = rotation + timeDelta * Ship.RotationSpeed
        }
        
        if directions.contains(3) {
            accelerate(directions: directions)
        } else {
            stop()
        }
        
        updateVelocity()
        updatePosition(timeDelta: timeDelta)
    }
    
    func accelerate(directions : [Int]) {
        if directions.contains(2) || directions.contains(1)
        {
        acceleration.x = cos(self.zRotation + CGFloat(Double.pi / 2))
        }
        if directions.contains(3)
        {
            acceleration.y = sin(self.zRotation + CGFloat(Double.pi / 2))
        }
        if directions.contains(4)
        {
            acceleration.y = sin(self.zRotation + CGFloat(Double.pi / 2))
        }
        if acceleration.length > Ship.MaxAcceleration {
            acceleration = acceleration * (Ship.MaxAcceleration / acceleration.length)
        }
        if directions.contains(4)
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
        //velocity.x = self.zRotation
        if velocity.length > Ship.MaxSpeed {
            velocity = velocity * (Ship.MaxSpeed / velocity.length)
        }
    }
    
    func updatePosition(timeDelta: CGFloat) {
        self.zRotation = rotation
        self.position = self.position + velocity * timeDelta
    }
}
