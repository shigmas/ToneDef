//
//  NavigationController.swift
//  ToneDef
//
//  Created by Masa Jow on 1/17/16.
//  Copyright © 2016 Futomen. All rights reserved.
//

import UIKit
import SafariServices

class NavigationController: UINavigationController,
    UINavigationControllerDelegate {

    var footer = UIToolbar()
    var rootController: UIViewController?
    
    override func viewDidLoad() {
        self.navigationBar.hidden = true
        self.delegate = self

        let prefsItem = UIBarButtonItem(title: "\u{2699}",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: "_handleGoToPrefs")
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: nil, action: nil)
        let aboutItem = UIBarButtonItem(title: "[info]",
            style: UIBarButtonItemStyle.Done,
            target: self,
            action: "_handleGoToAbout")

        let frame = CGRect(x: 0, y: self.view.frame.height-44,
            width: self.view.frame.width, height: 44)

        footer = UIToolbar(frame: frame)
        footer.setItems([prefsItem, spacerItem, aboutItem], animated: true)
        self.view.addSubview(footer)
        footer.hidden = false
    }

    // MARK UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController,
        willShowViewController viewController: UIViewController,
        animated: Bool) {
        if let vc = rootController as UIViewController! {
            if viewController == vc {
                self.footer.hidden = false
                self.navigationBar.hidden = true
                // Make sure we don't come back to ourselves
            }
        }
    }
    
    func _handleGoToPrefs() {
        self.navigationBar.hidden = false
        self.footer.hidden = true
        // We only go to the prefs from the root controller, so save that away
        rootController = self.visibleViewController
        performSegueWithIdentifier("showPreferencesController",
            sender: self)
    }
    func _handleGoToAbout() {
        self.navigationBar.hidden = false
        self.footer.hidden = true
        self.rootController = self.visibleViewController
        performSegueWithIdentifier("showAboutController",
            sender: self)
    }
}
