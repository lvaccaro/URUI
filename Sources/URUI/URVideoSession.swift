//
//  URVideoSession.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation
import AVFoundation
import Combine
import os

@available(iOS 14.0, *)
let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "URUI")

public struct URVideoSessionError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    public var errorDescription: String? {
        return description
    }
}

public final class URVideoSession: ObservableObject {
    let isSupported: Bool
    let codesPublisher: URCodesPublisher

    @Published public private(set) var captureDevices: [AVCaptureDevice] = []
    @Published public private(set) var currentCaptureDevice: AVCaptureDevice?

    private(set) var captureSession: AVCaptureSession!
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?
    private var discoverySession: AVCaptureDevice.DiscoverySession!
    private var metadataObjectsDelegate: MetadataObjectsDelegate!
    private let queue = DispatchQueue(label: "codes", qos: .userInteractive)
    
    public func setCaptureDevice(_ newDevice: AVCaptureDevice) {
        do {
            guard let captureSession = captureSession else {
                return
            }

            captureSession.beginConfiguration()
            if let currentInput = captureSession.inputs.first {
                captureSession.removeInput(currentInput)
            }
            let newInput = try AVCaptureDeviceInput(device: newDevice)
            captureSession.addInput(newInput)
            
            captureSession.commitConfiguration()
            currentCaptureDevice = newDevice
        } catch {
            if #available(iOS 14.0, *) {
                logger.error("⛔️ \(error.localizedDescription)")
            }
        }
    }

    public init(codesPublisher: URCodesPublisher) {
        self.codesPublisher = codesPublisher

        #if targetEnvironment(simulator)
        isSupported = false
        return
        #else

        isSupported = true
        
        do {
            discoverySession = .init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            captureDevices = discoverySession.devices

            guard let currentCaptureDevice = AVCaptureDevice.default(for: .video) else {
                throw URVideoSessionError("Could not open video capture device.")
            }
            
            self.currentCaptureDevice = currentCaptureDevice

            let videoInput = try AVCaptureDeviceInput(device: currentCaptureDevice)
            captureSession = AVCaptureSession()
            guard captureSession.canAddInput(videoInput) else {
                throw URVideoSessionError("Could not add video input device.")
            }
            captureSession.addInput(videoInput)

            metadataObjectsDelegate = MetadataObjectsDelegate(codesPublisher: codesPublisher)

            let metadataOutput = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(metadataOutput) else {
                throw URVideoSessionError("Could not add metadata output.")
            }
            captureSession.addOutput(metadataOutput)

            metadataOutput.metadataObjectTypes = [.qr]
            metadataOutput.setMetadataObjectsDelegate(metadataObjectsDelegate, queue: queue)

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.videoGravity = .resizeAspectFill
        } catch {
            if #available(iOS 14.0, *) {
                logger.error("⛔️ \(error.localizedDescription)")
            }
        }
        #endif
    }

    func startRunning() {
        guard let captureSession = captureSession else { return }
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func stopRunning() {
        guard let captureSession = captureSession else { return }
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    var isRunning: Bool {
        captureSession?.isRunning ?? false
    }

    @objc
    class MetadataObjectsDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let codesPublisher: URCodesPublisher
        var lastFound: Set<String> = []

        init(codesPublisher: URCodesPublisher) {
            self.codesPublisher = codesPublisher
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            let codes = Set(metadataObjects.compactMap {
                ($0 as? AVMetadataMachineReadableCodeObject)?.stringValue
            })
            if !codes.isEmpty, codes != lastFound {
                lastFound = codes
                codesPublisher.send(codes)
            }
        }
    }
}
