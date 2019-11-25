//
//  String.swift
//  Spotibar
//
//  Created by Viktor Strate Kløvedal on 10/11/2019.
//  Copyright © 2019 viktorstrate. All rights reserved.
//

import Cocoa

extension String {
  func truncate(length: Int, trailing: String = "…") -> String {
    return (self.count > length) ? self.prefix(length) + trailing : self
  }
}
