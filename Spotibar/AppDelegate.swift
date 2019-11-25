//
//  AppDelegate.swift
//  Spotibar
//
//  Created by Viktor Strate Kløvedal on 10/11/2019.
//  Copyright © 2019 viktorstrate. All rights reserved.
//

import Cocoa
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var spotify: SpotifyApplication = SBApplication(bundleIdentifier: "com.spotify.client")!
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    var eventMonitor: EventMonitor?
    
    let popover = NSPopover()
    var spotifyTimer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarIcon"))
            button.imagePosition = .imageLeft
            button.attributedTitle = NSAttributedString(string: "Hello")
            button.action = #selector(pressItem)
        }
        
        
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
          if let strongSelf = self, strongSelf.popover.isShown {
            strongSelf.closePopover(sender: event)
          }
        }

        periodicUpdate()
        
    }
    
    var lastUpdateArtworkUrl: String? = nil
    
    @objc func periodicUpdate() {
        spotifyTimer?.invalidate()
        
        if self.spotify.isRunning {
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
                //title.addAttribute(.baselineOffset, value: -1, range: NSRange(location: 0, length: topLine.count))
                title.addAttribute(.paragraphStyle, value: lineHeightPS, range: NSRange(location: topLine.count+1, length: bottomLine.count))
                
                button.attributedTitle = title
                
                guard let newArtworkUrl = self.spotify.currentTrack!.artworkUrl else {
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
                    
                    let thumbnailImage = originalImage.asThumbnail()
                    
                    button.image = thumbnailImage
                    
                    lastUpdateArtworkUrl = newArtworkUrl
                }
            }
            
            spotifyTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(periodicUpdate), userInfo: nil, repeats: false)
        } else {
            if let button = self.statusItem.button {
                button.attributedTitle = NSAttributedString(string: "")
                button.image = NSImage(named: NSImage.Name("StatusBarIcon"))
            }
            
            spotifyTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(periodicUpdate), userInfo: nil, repeats: false)
        }
    }
    
    func closePopover(sender: Any?) {
        
    }

    @objc func pressItem(_ sender: Any) {
        periodicUpdate()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

