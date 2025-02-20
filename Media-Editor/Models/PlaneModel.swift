//
//  PlaneModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 09/02/2024.
//

import Foundation
import SwiftUI

struct PlaneModel {
    let lowerToolbarHeight: Double = 100

    var totalLowerToolbarHeight: Double?
    var totalNavBarHeight: Double?
    var furthestPlanePointAllowed: CGPoint?
    var currentPosition: CGPoint?
    var initialPosition: CGPoint?
    var size: CGSize?
    var scale: Double? = 1.0

    var lineXPosition: CGFloat?
    var lineYPosition: CGFloat?

    var (minScale, maxScale) = (1.0, 10.0)
    var (previewMinScale, previewMaxScale) = (0.2, 20.0)

    let minDimension = 30.0
}

extension PlaneModel {
    mutating func setupPlaneView(workspaceSize: CGSize) {
        guard let totalLowerToolbarHeight,
              let totalNavBarHeight else { return }

        currentPosition =
            CGPoint(x: workspaceSize.width / 2,
                    y: (workspaceSize.height - totalLowerToolbarHeight) / 2 + totalNavBarHeight)
        initialPosition = currentPosition

        furthestPlanePointAllowed =
            CGPoint(x: workspaceSize.width,
                    y: workspaceSize.height + totalLowerToolbarHeight)
    }

    var globalPosition: CGPoint {
        guard let size else { return .zero }
        return CGPoint(x: size.width / 2, y: size.height / 2)
    }
}
