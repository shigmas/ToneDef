//
//  ToneDefTests.swift
//  ToneDefTests
//
//  Created by Masa Jow on 12/31/15.
//  Copyright © 2015 Futomen. All rights reserved.
//

import XCTest
@testable import ToneDef

class ToneDefTests: XCTestCase {

    // Some constants. Type it as a CGFloat to avoid double errors
    let StaffInterval: CGFloat = 0.05
    let StaffSpace: CGFloat = 0.15
    let StaffMargin: CGFloat = 0.2

    var converter: FrequencyConverter?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        converter = FrequencyConverter(tablePath: "notes",
            staffInterval: StaffInterval,
            staffSpace: StaffSpace, staffBottom: StaffMargin)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetNoteExact() {
        let aFreq: Float = 440.0
        var ratio: Float?
        var noteIndex: Int?
        (noteIndex, ratio) = converter!.getNote(aFreq)
        XCTAssertEqual(ratio, 0)
        XCTAssertEqual(noteIndex, 57)
        let noteName = converter!.getNameForIndex(noteIndex!)
        XCTAssertEqual(noteName, "A4")
    }

    func testNoteIndices() {
        let startIndex = converter!.getIndexForName("C2")
        XCTAssertEqual(converter!.getIndexForName("C#2/Db2"),startIndex + 1)
        XCTAssertEqual(converter!.getIndexForName("D2"),startIndex + 2)
        XCTAssertEqual(converter!.getIndexForName("C3"),startIndex + 12)
        XCTAssertEqual(converter!.getIndexForName("C4"),startIndex + 24)
        XCTAssertEqual(converter!.getIndexForName("A4"),startIndex + 33)
    }

    func _verifyNotePosition(index: Int, expected: CGFloat) {
        let (position, _) = converter!.noteToPosition(index)
        XCTAssertEqualWithAccuracy(position!, expected, accuracy: 0.00001)
    }
    
    func testNotePosition() {
        let startIndex = converter!.getIndexForName("G2")
        _verifyNotePosition(startIndex, expected: StaffMargin)

        // Test from C3
        let indexC3 = converter!.getIndexForName("C3")
        // Should be 1.5 up from the margin
        _verifyNotePosition(indexC3, expected: 1.5 * StaffInterval + StaffMargin)

        let indexC4 = converter!.getIndexForName("C4")
        // Should be 1.5 up from the margin
        _verifyNotePosition(indexC4,
            expected: 4.0 * StaffInterval + StaffMargin + StaffSpace)

    }

    func _verifyStaffPosition(index: Int, expected: Bool) {
        let (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.staffLineThroughNote, expected,
            "Unexpected value for \(index)")
    }

    func testStaffLineScale() {
        // Just two octave test. I *think* it should alternate
        _verifyStaffPosition(converter!.getIndexForName("C2"), expected: true)
        _verifyStaffPosition(converter!.getIndexForName("C#2/Db2"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("D2"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("D#2/Eb2"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("E2"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("F2"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("F#2/Gb2"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("G2"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("G#2/Ab2"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("A2"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("A#2/Bb2"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("B2"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("C3"), expected: false)
        _verifyStaffPosition(converter!.getIndexForName("C#3/Db3"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("D3"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("D#3/Eb3"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("E3"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("F3"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("F#3/Gb3"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("G3"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("G#3/Ab3"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("A3"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("A#3/Bb3"), expected:true)
        _verifyStaffPosition(converter!.getIndexForName("B3"), expected:false)
        _verifyStaffPosition(converter!.getIndexForName("C4"), expected:true)
    }

    func testExtraStaves() {
        // For the notes below and above the grand staff
        var index = converter!.getIndexForName("C2")
        var (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.numStaffLines, 2)

        index = converter!.getIndexForName("D2")
        (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.numStaffLines, 1)
        
        index = converter!.getIndexForName("E2")
        (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.numStaffLines, 1)

        index = converter!.getIndexForName("F2")
        (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.numStaffLines, 0)

        index = converter!.getIndexForName("G5")
        (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.numStaffLines, 0)

        index = converter!.getIndexForName("A5")
        (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.numStaffLines, 1)

        index = converter!.getIndexForName("B5")
        (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.numStaffLines, 1)

        index = converter!.getIndexForName("C6")
        (_ , addOn) = converter!.noteToPosition(index)
        XCTAssertEqual(addOn!.numStaffLines, 2)
}
    
    func testGetNoteOffset() {
        var aFreq: Float = 450.0
        var ratio: Float?
        var noteIndex: Int?
        (noteIndex, ratio) = converter!.getNote(aFreq)
        XCTAssertGreaterThan(ratio!, 0)
        XCTAssertEqual(noteIndex, 57)

        aFreq = 430.0
        (noteIndex, ratio) = converter!.getNote(aFreq)
        XCTAssertLessThan(ratio!, 0)
        XCTAssertEqual(noteIndex, 57)
    }
    
}
