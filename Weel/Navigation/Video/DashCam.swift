//
//  DashCam.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/15/25.
//

import SwiftUI
import AVFoundation

struct DashCam: UIViewRepresentable {
    @EnvironmentObject var videoManager: VideoManager

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // Ensure that the preview layer will be updated when the view is laid out
        DispatchQueue.main.async {
            // Add the preview layer to the view
            if let previewLayer = self.videoManager.videoPreviewLayer, videoManager.showDashCam {
                previewLayer.frame = view.bounds
                view.layer.addSublayer(previewLayer)
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the preview layer frame when the view bounds change
        if let previewLayer = videoManager.videoPreviewLayer, videoManager.showDashCam {
            previewLayer.frame = uiView.bounds
            
            // Add the preview layer if it is not already added
            if previewLayer.superlayer == nil {
                uiView.layer.addSublayer(previewLayer)
            }
        } else {
            // Remove the preview layer if it is not needed
            uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
        
        // Layout the view if needed
        uiView.layoutIfNeeded()
    }
}
