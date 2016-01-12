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

enum LineNodeType {
    case DoubleLine
    case SingleLine
}

class LineNode: SKShapeNode {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(lineType: LineNodeDirection, lineThickness: LineNodeType) {
        super.init()
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, 0.0, 0.0);
        switch lineType {
        case .Horizontal:
            CGPathAddLineToPoint(pathToDraw, nil, 50.0, 0.0);
        case .Vertical:
            CGPathAddLineToPoint(pathToDraw, nil, 0.0, 50.0);
        }

        self.path = pathToDraw
        switch lineThickness {
        case .DoubleLine:
            self.lineWidth = 1.0
        case .SingleLine:
            self.lineWidth = 0.5
        }
        self.fillColor = SKColor.blackColor()
        self.strokeColor = SKColor.blackColor()
    }
}