//
//  FrequencyConverter.swift
//  ToneDef
//
//  Created by Masa Jow on 1/6/16.
//  Copyright © 2016 Futomen. All rights reserved.
//

import Foundation

public enum AccidentalType: Int {
    case FlatType
    case SharpType
    case NaturalType
}

public enum StaffLineDirection {
    case Up
    case Down
}

public struct NoteAddOns {
    let accidental: AccidentalType
    let numStaffLines: Int
    let staffLineDirection: StaffLineDirection
    let staffLineThroughNote: Bool
    
    init(accidentalType: AccidentalType, numStaffLines: Int,
        staffLineDirection: StaffLineDirection, staffLineThroughNote: Bool) {
        self.accidental = accidentalType
        self.numStaffLines = numStaffLines
        self.staffLineDirection = staffLineDirection
        self.staffLineThroughNote = staffLineThroughNote
    }
}

func _loadFileByName(name: String) -> AnyObject? {
    let path = NSBundle.mainBundle().pathForResource(name,
        ofType:"json")
    guard let nonOptPath = path as String! else {
        return nil
    }
    let fh = NSFileHandle(forReadingAtPath: nonOptPath)
    guard let fileHandle = fh as NSFileHandle! else {
        return nil
    }
    
    let contents = fileHandle.readDataToEndOfFile()
    var jsonObject: AnyObject?
    do {
        try
            jsonObject = NSJSONSerialization.JSONObjectWithData(contents,
                options: .MutableContainers)
    } catch let error as NSError {
        print("Error in deserialization: \(error)")
    }
    
    return jsonObject
}

public class FrequencyConverter {
    typealias StringDict = Dictionary<String, AnyObject>
    
    private var frequencyTable: Array<StringDict>
    private var previousIndex: Int

    private let FrequencyKey = "frequency"
    private let NameKey      = "name"
    private let Wavelength   = "wavelength"

    let staffInterval: CGFloat
    let staffSpace: CGFloat
    let staffBottom: CGFloat

    // for the enharmonic pairs, we set the mode so we know which one to
    // return of the flat and sharp. Sharp by default
    var mode: AccidentalType = .SharpType

    init(let tablePath: String, let staffInterval: CGFloat,
        let staffSpace: CGFloat, let staffBottom: CGFloat) {
        self.staffInterval = staffInterval
        self.staffSpace = staffSpace
        self.staffBottom = staffBottom

        let jsonResult = _loadFileByName(tablePath)
        
        if let jsonDict = jsonResult as! Array<StringDict>! {
            frequencyTable = jsonDict
        } else {
            frequencyTable = Array<StringDict>()
        }

        // We may have decreased in pitch from the previous, so we'll go back
        // one when we search again.  So, initialize at 1 so we'll step back
        // to 0.
        previousIndex = 1
    }
    
    func getIndexForName(name: String) -> Int {
        for index in 0...frequencyTable.count {
            let entry = frequencyTable[index]
            let entryName = entry[NameKey] as! String
            if entryName == name {
                return index
            }
        }

        return -1
    }

    func getNameForIndex(index: Int?) -> String {
        guard let noteIndex = index as Int! else {
            return ""
        }
        let entry = frequencyTable[noteIndex]
        let entryName = entry[NameKey] as! String
        return entryName
    }
    
    func getFrequencyAtIndex(let index: Int) -> Float? {
        var freqVal: Float?

        if frequencyTable.count < index {
            return freqVal
        }
        
        let freqEntry = frequencyTable[index]
        if let val = freqEntry["frequency"] as? Float {
            freqVal = val
        }
        
        return freqVal
    }

    func getPositionForName(name: String) -> (CGFloat?, NoteAddOns?) {
        let noteIndex = getIndexForName(name)
        return noteToPosition(noteIndex)
    }

    // This should take a position, and we just calculate it from how far we
    // are from the stave
    func _getNumExtraStaves(index: Int) -> (Int, StaffLineDirection) {
        let lowerBound = getIndexForName("G2")
        let upperBound = getIndexForName("G#5/Ab5")
        var direction: StaffLineDirection = .Up
        var extra = 0
        if index < lowerBound {
            direction = .Down
            let diff = lowerBound - index
            if diff < 3 {
                extra = 0
            } else if diff < 7 {
                extra = 1
            } else {
                extra = 2
            }
        } else if index > upperBound {
            direction = .Up
            let diff = index - upperBound
            if diff < 1 {
                extra = 0
            } else if diff < 4 {
                extra = 1
            } else if diff < 8 {
                extra = 2
            } else {
                extra = 3
            }
        }

        return (extra, direction)
    }

    func noteToPosition(index: Int?) -> (CGFloat?, NoteAddOns?){
        var accidentalType: AccidentalType = .NaturalType
        guard let noteIndex = index as Int! else {
            return (nil, nil)
        }
        
        // position starts at C2 (two octaves below middle C)
        let startIndex = getIndexForName("C2")
        if (startIndex < 0) {
            return (nil, nil)
        }
        
        let indexOffset = noteIndex - startIndex
        // For the cycle of twelve, we add the octave offset.
        let numOctaves = indexOffset / 12
        let octaveOffset = indexOffset % 12
        let evenOctave = numOctaves % 2 == 0

        // Now, calculate the position
        // we're starting from C2, calculate the octave "jump", and then
        // exactly which note
        let increment: CGFloat = staffInterval/2.0
        let octaveSize: CGFloat = 7.0 * increment
        var position: CGFloat = staffBottom - staffInterval * 2.0
        if position < 0.0 {
            print("WARN: C2 is below zero (offscreen)")
        }
        position += octaveSize * CGFloat(numOctaves)
        var needsStave = false
        if numOctaves > 1 {
            // We have to add the jump in between clefs, but C4 is
            position += staffSpace - staffInterval
        }
        // This is the stuff we have to do by hand
        if octaveOffset == 0 {
            // C
            needsStave = evenOctave
        } else if octaveOffset == 1 {
            // C#/Db
            accidentalType = self.mode
            if self.mode == .FlatType {
                needsStave = !evenOctave
                position += increment
            } else {
                needsStave = evenOctave
            }
        } else if octaveOffset == 2 {
            // D
            needsStave = !evenOctave
            position += increment
        } else if octaveOffset == 3 {
            // D#/Eb
            accidentalType = self.mode
            position += increment
            if self.mode == .FlatType {
                position += increment
                needsStave = evenOctave
            } else {
                needsStave = !evenOctave
            }
        } else if octaveOffset == 4 {
            // E
            needsStave = evenOctave
            position += increment * 2.0
        } else if octaveOffset == 5 {
            // F
            needsStave = !evenOctave
            position += increment * 3.0
        } else if octaveOffset == 6 {
            // F#/Gb
            accidentalType = self.mode
            position += increment * 3.0
            if self.mode == .FlatType {
                position += increment
                needsStave = evenOctave
            } else {
                needsStave = !evenOctave
            }
        } else if octaveOffset == 7 {
            // G
            needsStave = evenOctave
            position += increment * 4.0
        } else if octaveOffset == 8 {
            // G#/Ab
            accidentalType = self.mode
            position += increment * 4.0
            if self.mode == .FlatType {
                position += increment
                needsStave = !evenOctave
            } else {
                needsStave = evenOctave
            }
        } else if octaveOffset == 9 {
            // A
            needsStave = !evenOctave
            position += increment * 5.0
        } else if octaveOffset == 10 {
            // A#/Bb
            accidentalType = self.mode
            position += increment * 5.0
            if self.mode == .FlatType {
                position += increment
                needsStave = evenOctave
            } else {
                needsStave = !evenOctave
            }
        } else if octaveOffset == 11 {
            // B
            needsStave = evenOctave
            position += increment * 6.0
        }

        // Just use indices for the number of extra staff lines, and only up to
        // 2
        let (extra, direction) = _getNumExtraStaves(noteIndex)
        let addOn = NoteAddOns(accidentalType: accidentalType,
            numStaffLines: extra, staffLineDirection: direction, staffLineThroughNote: needsStave)
        return (position, addOn)
    }

    // Returns the note that the frequency is closest to
    func getNote(let frequency: Float) -> (Int?, Float?) {
        // To avoid iterating through a hundred elements, we test for the
        // likely case where we are close to the previous.
        var upperIndex = previousIndex - 1

        let lastFreq = getFrequencyAtIndex(upperIndex)
        if let lastFreqNO = lastFreq as Float! {
            if lastFreqNO > frequency {
                upperIndex = 0
            } // else, leave it as it is
        } else {
            // Not sure if we didn't actually get a frequency back (maybe the
            // index was too high?  If so, it gets reset.
            upperIndex = 0
        }

        // This is higher than the piano and likely any value we'll be getting.
        var lowerFreq: Float = 0.0
        var upperFreq: Float = 0.0
        while lowerFreq < frequency && upperIndex < frequencyTable.count {
            // guaranteed at least once
            let current = getFrequencyAtIndex(upperIndex)
            if let currentFreq = current as Float! {
                if currentFreq < frequency {
                    // We don't do <= so if we're equal, we'll have the upper
                    lowerFreq = currentFreq
                    upperIndex++
                } else {
                    upperFreq = currentFreq
                    break
                }
            } else {
                // No value at the current index.  break out and exit
                break
            }
        }
        // Now, we have either too high (upperIndex is out of bounds),
        // too low (lowerFreq is still 0), or two bounding frequencies, where
        // [lower,upper)
        if upperIndex == frequencyTable.count || lowerFreq == 0.0 {
            return (nil, 0.0)
        }
        
        // With the lower and upper bound, find one is closer, and how close
        let diff = upperFreq - lowerFreq
        let mid = lowerFreq + diff/2.0
        var ratio: Float = 0.0
        if frequency <= mid {
            // lower bound
            previousIndex = upperIndex - 1
            ratio = (frequency - lowerFreq)/diff
        } else {
            // upper bound
            previousIndex = upperIndex
            ratio = (frequency - upperFreq)/diff
        }
        return (previousIndex, ratio)
    }

}