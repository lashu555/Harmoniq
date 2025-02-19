//
//  UIButtonConfig.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 17.02.25.
//

import Foundation
import UIKit

extension UIButton.Configuration {
    static func toolbar() -> UIButton.Configuration {
        var configuration: UIButton.Configuration = .plain()
        configuration.baseForegroundColor = .label
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18)
        
        return configuration
    }
}
