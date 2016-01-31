//
//  BarGraphNode.swift
//  ToneDef
//
//  Created by Masa Jow on 1/30/16.
//  Copyright © 2016 Futomen. All rights reserved.
//

import SpriteKit

// Container for the BarGraph
class BarGraph {
    var graphBounds: Array<LineNode>
    var sharpGraph = SKSpriteNode(color: SKColor.greenColor(),
        size: CGSize(width: 1.0, height: 1.0))
    var flatGraph = SKSpriteNode(color: SKColor.redColor(),
        size: CGSize(width: 1.0, height: 1.0))

    var leftBottomAnchor: CGPoint
    var size: CGSize

    var scene: SKScene? {
        didSet {
            guard let s = scene as SKScene! else {
                return
            }
            for bound in self.graphBounds {
                s.addChild(bound)
            }
            s.addChild(self.sharpGraph)
            s.addChild(self.flatGraph)
        }
    }

    var ratio: CGFloat {
        didSet {
            _drawGraph()
        }
    }

    init(position: CGPoint, size: CGSize) {
        self.leftBottomAnchor = position
        self.size = size
        self.graphBounds = [
            LineNode(direction: .Vertical),
            LineNode(direction: .Vertical),
            LineNode(direction: .Horizontal),
            LineNode(direction: .Horizontal),
            LineNode(direction: .Horizontal),
        ]

        // left vertical
        self.graphBounds[0].position = position
        self.graphBounds[0].length = size.height
        // right vertical
        self.graphBounds[1].position = CGPoint(x: position.x + size.width,
            y: position.y)
        self.graphBounds[1].length = size.height

        // bottom limit
        self.graphBounds[2].position = position
        self.graphBounds[2].length = size.width
        self.graphBounds[3].position = CGPoint(x: position.x,
            y: position.y + size.height/2.0)
        self.graphBounds[3].length = size.width
        self.graphBounds[4].position = CGPoint(x: position.x,
            y: position.y + size.height)
        self.graphBounds[4].length = size.width

        self.ratio = 0.0
        self.flatGraph.hidden = true
        self.sharpGraph.hidden = true
    }

    func _drawGraph() {
        // The graphs for how out of tune we are
        let horizPos = leftBottomAnchor.x + size.width/2.0
        let hOffset = size.height*abs(ratio)
        if ratio > 0.0 {
            self.flatGraph.hidden = true
            self.sharpGraph.hidden = false
            self.sharpGraph.position = CGPoint(x: horizPos,
                y: hOffset/2.0 + size.height/2.0)
            self.sharpGraph.size = CGSize(width: size.width,
                height: hOffset)
        } else {
            self.flatGraph.hidden = false
            self.sharpGraph.hidden = true
            self.flatGraph.position = CGPoint(x: horizPos,
                y: size.height/2.0 - hOffset/2.0)
            self.flatGraph.size = CGSize(width: size.width,
                height: hOffset)

        }
    }
}
