//
//  VideoManager.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/10/25.
//

import AVFoundation
import UIKit

class VideoManager: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var movieOutput = AVCaptureMovieFileOutput()
    @Published var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    private let videoKey = "savedVideos"
    
    @Published var videos = [URL]()

    override init() {
        super.init()
        getSavedVideos()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession,
              let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Failed to set up camera input")
            return
        }

        captureSession.addInput(videoInput)

        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
    }
    
    func startSession() {
        captureSession?.startRunning()
    }
    
    func stopSession() {
        captureSession?.stopRunning()
    }

    func startRecording() {
        guard let captureSession = captureSession, captureSession.isRunning else { return }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
    }

    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
    }

    private func saveVideo(url: URL) {
        let fileManager = FileManager.default
        guard let documentsDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return
        }
            
        let filename = url.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try fileManager.moveItem(at: url, to: destinationURL)
        } catch {
            print("Error moving video: \(error)")
            return
        }
        
        // Retrieve existing videos from UserDefaults
        var savedVideos = UserDefaults.standard.stringArray(forKey: videoKey) ?? []
        
        // Append only the filename
        savedVideos.append(filename)
        
        // Save updated array
        UserDefaults.standard.set(savedVideos, forKey: videoKey)
    }

    func getSavedVideos() {
        guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true),
              let filenames = UserDefaults.standard.stringArray(forKey: videoKey) else {
            return
        }
        
        // Convert filenames to valid file URLs
        self.videos = filenames.compactMap { filename in
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
        }
    }

    func removeVideo(filename: String) {
        var savedVideos = UserDefaults.standard.stringArray(forKey: videoKey) ?? []
        savedVideos.removeAll { $0 == filename }
        
        let fileManager = FileManager.default
        guard let documentsDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return
        }
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("Error deleting video: \(error)")
        }
        
        UserDefaults.standard.set(savedVideos, forKey: videoKey)
        
        getSavedVideos()
    }

}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print("Error recording video: \(error!.localizedDescription)")
            return
        }
        
        saveVideo(url: outputFileURL)
    }
}
