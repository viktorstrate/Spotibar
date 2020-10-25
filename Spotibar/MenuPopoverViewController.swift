//
//  MenuPopoverDelegate.swift
//  Spotibar
//
//  Created by Viktor Strate Kløvedal on 25/10/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import Cocoa
import SwiftUI

class MenuPopoverViewController: NSHostingController<MenuPopoverView> {
  
  static func makeViewController(appState: AppState) -> MenuPopoverViewController {
    let controller = MenuPopoverViewController(rootView: MenuPopoverView(appState: appState))
    return controller
  }
  
  override func viewDidAppear() {
    
  }
  
}
