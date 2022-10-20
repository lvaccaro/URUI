//
//  URVideo.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import SwiftUI
import AVFoundation
import Combine

/// A View that displays video from the camera and relays
/// values of scanned QR codes to to the provided `URScanState`.
public struct URVideo: UIViewRepresentable {
    let videoSession: URVideoSession

    public init(videoSession: URVideoSession) {
        self.videoSession = videoSession
    }

    public func makeUIView(context: Context) -> URUIVideoView {
        URUIVideoView(videoSession: videoSession)
    }

    public func updateUIView(_ uiView: URUIVideoView, context: Context) {
    }
}
