//
//  Settings.swift
//  ToneDef
//
//  Created by Masa Jow on 2/28/16.
//  Copyright © 2016 Futomen. All rights reserved.
//

class Settings: NSObject {
    static let SharpFlatModeKey = "SharpFlatMode"

    // I think we could make a template base class which could hold the didSet
    // method.
    var sharpFlatMode: AccidentalType {
        didSet {
            let defaults = NSUserDefaults.standardUserDefaults()
            switch sharpFlatMode {
            case .FlatType:
                defaults.setObject("Flat",
                    forKey: Settings.SharpFlatModeKey)
            default:
                defaults.setObject("Sharp",
                    forKey: Settings.SharpFlatModeKey)
            }
            defaults.synchronize()
        }
    }

    class var sharedInstance: Settings {
        struct Static {
            static let instance = Settings()
        }
        return Static.instance
    }

    override init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let sfMode = defaults.objectForKey(Settings.SharpFlatModeKey)
        if let obj = sfMode as? String {
            switch obj {
            case "Flat":
                self.sharpFlatMode = .FlatType
            default:
                self.sharpFlatMode = .SharpType
            }
        } else {
            self.sharpFlatMode = .SharpType
        }

    }
}
