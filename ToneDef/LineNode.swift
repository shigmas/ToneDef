//
//  LineNode.swift
//  ToneDef
//
//  Created by Masa Jow on 1/8/16.
//  Copyright © 2016 Futomen. All rights reserved.
//

import SpriteKit

enum LineNodeDirection {
    case Horizontal
    case Vertical
}

class LineNode: SKShapeNode {

    let DefaultLength: CGFloat = 1.0
    var lineDirection: LineNodeDirection

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Use this instead of scale
    var length: CGFloat {
        didSet {
            print("old: \(oldValue), new: \(self.length)")
            let pathToDraw = CGPathCreateMutable()
            CGPathMoveToPoint(pathToDraw, nil, 0.0, 0.0)
            switch self.lineDirection {
            case .Horizontal:
                CGPathAddLineToPoint(pathToDraw, nil, self.length, 0.0);
            case .Vertical:
                CGPathAddLineToPoint(pathToDraw, nil, 0.0, self.length);
            }
            self.path = pathToDraw
        }
    }

    init(direction: LineNodeDirection) {
        self.lineDirection = direction
        self.length = DefaultLength
        super.init()
        switch self.lineDirection {
        case .Horizontal:
            self.yScale = 0.01
        case .Vertical:
            self.xScale = 0.01
        }
        self.lineWidth = 0.1
        self.fillColor = SKColor.blackColor()
        self.strokeColor = SKColor.blackColor()
    }
}