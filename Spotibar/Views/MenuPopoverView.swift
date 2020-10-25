//
//  MenuPopoverView.swift
//  Spotibar
//
//  Created by Viktor Strate Kløvedal on 25/10/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftUI

struct MenuPopoverView: View {
  
  @ObservedObject var appState: AppState
  
  @State private var hovering = false
  
  fileprivate func mediaOverlay() -> some View {
    VStack {
      VStack {
        Text(appState.spotify.currentTrack?.artist ?? "").fontWeight(.medium)
        Text(appState.spotify.currentTrack?.name ?? "").foregroundColor(Color.init(white: 0.25))
      }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 42)
      .background(Color.white.opacity(0.5))
      .offset(y: hovering ? 0 : -42)
      
      Spacer()
      
      VStack(spacing: 4) {
        Spacer()
        
        HStack {
          
          
          Button(action: {
            if let shuffling = appState.spotify.shuffling {
              appState.spotify.setShuffling?(!shuffling)
              updateSpotifyState()
            }
          }) {
            Image("media-shuffle").colorInvert().colorMultiply(appState.spotify.shuffling == true ? .red : .black)
          }.buttonStyle(PlainButtonStyle())
          
          
          Spacer()
          HStack(spacing: 14) {
            
            Button(action: {
              appState.spotify.previousTrack?()
              updateSpotifyState()
            }) {
              Image("media-arrow").rotationEffect(Angle(degrees: 180))
            }.buttonStyle(PlainButtonStyle())
            
            Button(action: {
              if let playerState = appState.spotify.playerState, playerState == .playing {
                appState.spotify.pause?()
              } else {
                appState.spotify.play?()
              }
              updateSpotifyState()
            }) {
              if let playerState = appState.spotify.playerState, playerState == .playing {
                Image("media-pause")
              } else {
                Image("media-play")
              }
            }.buttonStyle(PlainButtonStyle())
            
            Button(action: {
              appState.spotify.nextTrack?()
              updateSpotifyState()
            }) {
              Image("media-arrow")
            }.buttonStyle(PlainButtonStyle())
            
          }
          Spacer()
          
          Button(action: {
            if let repeating = appState.spotify.repeating {
              appState.spotify.setRepeating?(!repeating)
              updateSpotifyState()
            }
          }) {
            Image("media-repeat").colorInvert().colorMultiply(appState.spotify.repeating == true ? .red : .black)
          }.buttonStyle(PlainButtonStyle())
          
        }.padding([.leading, .trailing], 14)
        
        HStack {
          
          Text(appState.spotify.trackPlaytimeFormatted()).frame(width: 30, alignment: .trailing)
          
          GeometryReader { geometry in
            ZStack {
              Rectangle().frame(maxHeight: 2)
              
              HStack {
                Rectangle().fill(Color.red).frame(width: geometry.size.width * CGFloat(appState.spotify.trackProgress()), height: 2)
                Spacer()
              }
              
              HStack {
                RoundedRectangle(cornerRadius: 2).fill(Color.white).shadow(color: Color(white: 0, opacity: 0.6), radius: 1)
                  .frame(width: 4, height: 12)
                  .offset(x: geometry.size.width * CGFloat(appState.spotify.trackProgress()))
                Spacer()
              }
              
            }.offset(y: 1)
          }
          
          Text(appState.spotify.trackDurationFormatted()).frame(width: 30, alignment: .leading)
        }.padding([.leading, .trailing], 14)
        
        Spacer()
      }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 72)
      .background(Color.white.opacity(0.5))
      .offset(y: hovering ? 0 : 72)
      
    }
  }
  
  var body: some View {
    ZStack {
      if let img = appState.coverImage {
        Image(nsImage: img)
          .resizable()
          .scaledToFill()
          .blur(radius: hovering ? 10 : 0)
          .brightness(hovering ? 0.15 : 0)
          .scaleEffect(hovering ? 1.1 : 1)
      }
      
      mediaOverlay()
      
    }.frame(maxWidth: 280, maxHeight: 280)
    .onHover(perform: { hovering in
      
      let animation: Animation = hovering ? .easeOut(duration: 0.2) : .easeOut(duration: 0.4)
      
      withAnimation(animation) {
        self.hovering = hovering
      }
    })
  }
  
  static func makeViewController(appState: AppState) -> NSViewController {
    return NSHostingController(rootView: MenuPopoverView(appState: appState))
  }
  
  fileprivate func updateSpotifyState() {
    DispatchQueue.main.async {
      appState.objectWillChange.send()
    }
  }
}

struct MenuPopoverView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MenuPopoverView(appState: AppState())
    }
  }
}
