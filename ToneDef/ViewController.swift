//
//  ViewController.swift
//  ToneDef
//
//  Created by Masa Jow on 12/31/15.
//  Copyright © 2015 Futomen. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    // Some constants. Type it as a CGFloat to avoid double errors
    let StaffInterval: CGFloat = 0.05
    let StaffSpace: CGFloat = 0.15
    let StaffMargin: CGFloat = 0.2
    let AccidentalOffset: CGFloat = 0.025

    private var analyzer: AKAudioAnalyzer?
    private var microphone: AKMicrophone?
    @IBOutlet weak var frequencyTextBox: UITextField!
    @IBOutlet weak var amplitudeTextBox: UITextField!
    @IBOutlet weak var noteTextBox: UITextField!
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var enableButton: UIButton!

    var converter: FrequencyConverter
    var scene: SKScene = SKScene()

    var timer: NSTimer?

    // Grand staff.
    // We have unicode for these, but not all fonts support them, so let's just
    // be safe and use images
    var bassClef = SKSpriteNode(imageNamed: "bass")
    var trebleClef = SKSpriteNode(imageNamed: "treble")
    var staffLines: Array<SKShapeNode> = [
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine)]

    // Now, for the other sprites that we'll move around
    // No Only quarters and eights have unicode, AFAIK
    var note = SKSpriteNode(imageNamed:"whole")
    var extraStaffLines = [
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine),
        LineNode(lineType: .Horizontal,lineThickness: .SingleLine)]
    // These are more widely supported than the clef's, so lets use these
    // until there's a problem
    var sharp = SKLabelNode(text: "♯")
    var flat = SKLabelNode(text: "♭")
    // We'll draw this one extra short
    var shortStaff = LineNode(lineType: .Horizontal,lineThickness: .SingleLine)

    var running = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        converter = FrequencyConverter(tablePath: "notes",
            staffInterval: StaffInterval, staffSpace: StaffSpace,
            staffBottom: StaffMargin)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        converter = FrequencyConverter(tablePath: "notes",
            staffInterval: StaffInterval, staffSpace: StaffSpace,
            staffBottom: StaffMargin)
        super.init(coder: aDecoder)
    }
    
    func _scaleClef(clef: SKSpriteNode, yPos: CGFloat) {
        clef.size = CGSize(width: 0.1, height: 0.2)
        clef.position = CGPoint(x: 0.05, y: yPos + 0.1)
    }

    func _scaleAccidental(accid: SKLabelNode, xPos: CGFloat) {
        // Font big enough so that when we scale it down, it's still clear
        accid.fontSize = 32
        accid.setScale(0.0025)
        accid.fontColor = SKColor.blackColor()
        accid.position = CGPoint(x: xPos, y: 0.5)
    }

    func _setupSKView() {
        scene.backgroundColor = SKColor.whiteColor()

        // Starting staf line position
        var startingPosition = CGPoint(x: 0.0,y: StaffMargin)
        var trebleYStart: CGFloat = 0.0

        var count = 0
        for staffLine in self.staffLines {
            staffLine.position = startingPosition
            // We want the width to be one, and height to be .01
            staffLine.xScale = 1.0/staffLine.frame.width
            staffLine.yScale = 0.01/staffLine.frame.height
            self.scene.addChild(staffLine)

            startingPosition.y += self.StaffInterval
            if count == 4 {
                // Add the spacing between the staves
                startingPosition.y += self.StaffSpace
                trebleYStart = startingPosition.y
            }
            count++
        }

        _scaleClef(self.bassClef, yPos: StaffMargin)
        self.scene.addChild(self.bassClef)
        _scaleClef(self.trebleClef, yPos: trebleYStart)
        self.scene.addChild(self.trebleClef)

        _scaleAccidental(self.sharp, xPos: 0.5)
        self.sharp.hidden = true
        self.scene.addChild(self.sharp)
        _scaleAccidental(self.flat, xPos: 0.5)
        self.flat.hidden = true
        self.scene.addChild(self.flat)

        // Y will change, but just set the x for now.
        let (ypos, _) = converter.getPositionForName("C2")
        self.note.position = CGPoint(x: 0.55, y: ypos!)
        self.note.size = CGSize(width: 0.05, height: 0.05)
        //self.note.hidden = true
        self.scene.addChild(self.note)

        for staffLine in self.extraStaffLines {
            staffLine.position = CGPoint(x: 0.5175, y: ypos!)
            staffLine.xScale = 0.07/staffLine.frame.width
            staffLine.yScale = 0.01/staffLine.frame.height
            //self.extraStaffLine.hidden = true
            self.scene.addChild(staffLine)
        }

        print("sprite kit view size: \(skView.frame.size.width), \(skView.frame.size.height)")
        print("note size: \(note.size.width), \(note.size.height)")
        print("clef size: \(self.trebleClef.frame.width), \(self.trebleClef.frame.height)")
        skView.presentScene(scene)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self._setupSKView()
        self.enableButton.setTitle("Start", forState: .Normal)

        AKSettings.shared().audioInputEnabled = true
        microphone = AKMicrophone()
        analyzer = AKAudioAnalyzer(input: microphone!.output)
        AKOrchestra.addInstrument(microphone!)
        AKOrchestra.addInstrument(analyzer!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func _toggleRunning() {
        if self.running {
            self.enableButton.setTitle("Start", forState: .Normal)
            self.running = false
            microphone!.stop()
            analyzer!.stop()
  
            // Stop the timer
            if (self.timer != nil) {
                self.timer?.invalidate()
                self.timer = nil
            }
        } else {
            self.enableButton.setTitle("Stop", forState: .Normal)
            self.running = true
            if (self.timer == nil) {
                self.timer = NSTimer(timeInterval: 0.01, target: self,
                    selector: "getInput:", userInfo: nil, repeats: true)
            }
            microphone!.start()
            analyzer!.start()
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: "NSDefaultRunLoopMode")
        }
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        _toggleRunning()
    }


    func getInput(timer: NSTimer) -> Void {
        guard let anal = analyzer as AKAudioAnalyzer! else {
            print("No analyzer")
            return
        }

        frequencyTextBox.text = String(format: "%f",
            arguments: [anal.trackedFrequency.value])
        amplitudeTextBox.text = String(format: "%f",
            arguments: [anal.trackedAmplitude.value])
        var noteIndex: Int?
        var ratio: Float?
        (noteIndex, ratio) = converter.getNote(anal.trackedFrequency.value)
        print("note: \(noteIndex), ratio: \(ratio)")
        noteTextBox.text = converter.getNameForIndex(noteIndex)

        if anal.trackedAmplitude.value < 0.01 {
            return
        }

        var position: CGFloat?
        var addOns: NoteAddOns?
        (position, addOns) = converter.noteToPosition(noteIndex)
        // Calculate the note position
        if let yValC = position as CGFloat! {
            var curPos = self.note.position
            curPos.y = CGFloat(yValC)
            self.note.position = curPos
            self.note.hidden = false

            var accidental : AccidentalType = .NaturalType
            var numExtraStaves = 0
            var direction: StaffLineDirection = .Up
            var needsStave = false
            if let add = addOns as NoteAddOns! {
                accidental = add.accidental
                numExtraStaves = add.numStaffLines
                direction = add.staffLineDirection
                needsStave = add.staffLineThroughNote
            }

            // Hide all
            _ = self.extraStaffLines.map {
                $0.hidden = true
            }
            if numExtraStaves > 0 {
                // Draw from the end up to the note
                switch direction {
                case .Up:
                    // Starting from the top stave
                    let topIndex = converter.getIndexForName("E5")
                    let (top, _) = converter.noteToPosition(topIndex)
                    for i in 0...numExtraStaves-1 {
                        curPos = self.extraStaffLines[i].position
                        curPos.y = top! + CGFloat(i+1) * StaffInterval
                        self.extraStaffLines[i].position = curPos
                        self.extraStaffLines[i].hidden = false
                    }
                case .Down:
                    // Starting from the bottom stave
                    let bottomIndex = converter.getIndexForName("G2")
                    let (bottom, _) = converter.noteToPosition(bottomIndex)
                    for i in 0...numExtraStaves-1 {
                        curPos = self.extraStaffLines[i].position
                        curPos.y = bottom! - CGFloat(i+1) * StaffInterval
                        self.extraStaffLines[i].position = curPos
                        self.extraStaffLines[i].hidden = false
                    }
                }
            } else if needsStave {
                curPos = self.extraStaffLines[0].position
                curPos.y = CGFloat(yValC)
                self.extraStaffLines[0].position = curPos
                self.extraStaffLines[0].hidden = false
            }

            var accidentalNode: SKLabelNode?
            switch accidental {
            case .NaturalType:
                self.sharp.hidden = true
                self.flat.hidden = true
            case .FlatType:
                self.sharp.hidden = true
                self.flat.hidden = false
                accidentalNode = self.flat
            case .SharpType:
                self.flat.hidden = true
                self.sharp.hidden = false
                accidentalNode = self.sharp
            }
            if let node = accidentalNode as SKLabelNode! {
                var curPos = node.position
                curPos.y = CGFloat(yValC - AccidentalOffset)
                node.position = curPos
            }
        }

    }
}

