//
//  HQPlayerToolBarViewDelegate.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 17.02.25.
//

import Foundation
import UIKit

protocol HQPlayerToolBarViewDelegate: NSObject {
    func toolbarView(_ toolbarView: PlayerToolBarView, didTapPlayPause button: UIButton)
    func toolbarView(_ toolbarView: PlayerToolBarView, tapGestureRecognised tapGestureRecogniser: UITapGestureRecognizer)
}
