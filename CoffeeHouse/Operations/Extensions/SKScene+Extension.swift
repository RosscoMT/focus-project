//
//  SKScene+Extension.swift
//  Coffee House
//
//  Created by Ross Viviani on 30/04/2022.
//  Copyright © 2022 Coffee House. All rights reserved.
//

import SpriteKit
import Engine
import MetalKit

extension BaseScene {
    
    var bounds: CGRect {
        return CGRect(origin: .zero, size: Renderer.size)
    }
    
    var viewTop: CGFloat  {
        
        #if os(iOS) || os(tvOS)
        return convertPoint(fromView: CGPoint(x: 0.0, y: 0)).y
        #else
        
        guard let view = view else {
            return 0.0
        }
        
        return convertPoint(fromView: CGPoint(x: 0.0,
                                              y: view.bounds.size.height)).y
        #endif
    }
    
    var viewBottom: CGFloat {
        
        #if os(iOS) || os(tvOS)
        
        guard let view = view else {
            return 0.0
        }
        
        return convertPoint(fromView: CGPoint(x: 0.0,
                                              y: view.bounds.size.height)).y
        #else
        return convertPoint(fromView: CGPoint(x: 0.0, y: 0)).y
        #endif
    }
    
    var viewLeft: CGFloat {
        return convertPoint(fromView: CGPoint(x: 0, y: 0.0)).x
    }
    
    var viewRight: CGFloat {
        guard let view = view else { return 0.0 }
        return convertPoint(fromView: CGPoint(x: view.bounds.size.width,
                                              y: 0.0)).x
    }
    
    #if os(iOS)
    
    var insets: UIEdgeInsets {
        return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
    }
    
    #endif
    
    func centreSpawnLocation(point: CGPoint) -> CGPoint {
        var position = self.convertPoint(fromView: point)
        position.y -= self.size.height / 2
        position.x -= self.size.width / 2
        return position
    }
}
