//
//  AppDelegate.swift
//  Spotibar
//
//  Created by Viktor Strate Kløvedal on 10/11/2019.
//  Copyright © 2019 viktorstrate. All rights reserved.
//

import Cocoa
import ScriptingBridge

class AppState: ObservableObject {
  @Published var coverImage: NSImage?
  @Published var spotify: SpotifyApplication = SBApplication(bundleIdentifier: "com.spotify.client")!
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  //lazy var spotify: SpotifyApplication = SBApplication(bundleIdentifier: "com.spotify.client")!
  let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
  var eventMonitor: EventMonitor?
  
  let popover = NSPopover()
  var spotifyTimer: Timer?
  var appState = AppState()
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    
    if let button = statusItem.button {
      button.image = NSImage(named: NSImage.Name("StatusBarIcon"))
      button.imagePosition = .imageLeft
      button.attributedTitle = NSAttributedString(string: "Hello")
      button.action = #selector(pressItem)
    }
    
    popover.contentViewController = MenuPopoverViewController.makeViewController(appState: appState)
    
    let _eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
      if let strongSelf = self, strongSelf.popover.isShown {
        strongSelf.closePopover(sender: event)
      }
    }
    _eventMonitor.start()
    self.eventMonitor = _eventMonitor
    
    periodicUpdate()
    
  }
  
  var lastUpdateArtworkUrl: String? = nil
  
  @objc func periodicUpdate() {
    spotifyTimer?.invalidate()
    
    let spotify = self.appState.spotify
    
    if spotify.isRunning {
      if let button = statusItem.button {
        
        let topLine = "\(spotify.currentTrack!.artist!)".truncate(length: 20)
        let bottomLine = "\(spotify.currentTrack!.name!)".truncate(length: 20)
        
        let sharedPS = NSMutableParagraphStyle()
        sharedPS.alignment = .left
        
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
          .font: NSFont.menuBarFont(ofSize: 10),
          .paragraphStyle: sharedPS,
        ]
        
        let lineHeightPS = NSMutableParagraphStyle()
        lineHeightPS.maximumLineHeight = 8
        
        let title = NSMutableAttributedString(string: "\(topLine)\n\(bottomLine)", attributes: titleAttributes)
        title.addAttribute(.paragraphStyle, value: lineHeightPS, range: NSRange(location: topLine.count+1, length: bottomLine.count))
        
        button.attributedTitle = title
        
        guard let newArtworkUrl = spotify.currentTrack!.artworkUrl else {
          button.image = nil
          return
        }
        
        if (newArtworkUrl != lastUpdateArtworkUrl) {
          // Upgrade cover art url to https
          let imageUrl = NSURLComponents(string: newArtworkUrl)!
          imageUrl.scheme = "https"
          
          guard let originalImage = NSImage(contentsOf: imageUrl.url!) else {
            return
          }
          
          appState.coverImage = originalImage
          let thumbnailImage = originalImage.asThumbnail()
          
          button.image = thumbnailImage
          
          lastUpdateArtworkUrl = newArtworkUrl
        }
      }
      
      appState.objectWillChange.send()
      
      spotifyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(periodicUpdate), userInfo: nil, repeats: false)
    } else {
      if let button = self.statusItem.button {
        button.attributedTitle = NSAttributedString(string: "")
        button.image = NSImage(named: NSImage.Name("StatusBarIcon"))
      }
      
      spotifyTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(periodicUpdate), userInfo: nil, repeats: false)
    }
    
    self.statusItem.isVisible = spotify.isRunning
  }
  
  func showPopover(sender: Any?) {
    if let button = statusItem.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }
  }
  
  func closePopover(sender: Any?) {
    popover.close()
  }
  
  @objc func pressItem(_ sender: Any) {
    //periodicUpdate()
    
    if popover.isShown {
      closePopover(sender: sender)
    } else {
      showPopover(sender: sender)
    }
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  
}

