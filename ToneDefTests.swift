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
