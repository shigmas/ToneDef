//
//  AboutController.swift
//  ToneDef
//
//  Created by Masa Jow on 1/17/16.
//  Copyright © 2016 Futomen. All rights reserved.
//

import UIKit
import WebKit

class AboutController: UIViewController {

    private var contentView = WKWebView()
    
    override func viewDidLoad() {
        let path = NSBundle.mainBundle().pathForResource("about",
            ofType:"html")
        let indexURL = NSURL.fileURLWithPath(path!)
        let req = NSURLRequest(URL:indexURL)
        self.contentView.loadRequest(req)
        
        self.view = contentView
    }
}
