// PoseDetectionViewController.swift

import UIKit
import AVFoundation
import Vision

class PoseDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - UI Elements
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    private let captureSession = AVCaptureSession()
    private var detectedPosePoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Setup preview layer
        previewLayer.session = captureSession
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Setup feedback label
        view.addSubview(feedbackLabel)
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedbackLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            feedbackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            feedbackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            feedbackLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
    
    private func setupCamera() {
        // Configure capture session
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }
        
        // Add video input
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Configure video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Start capture session
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    // MARK: - Pose Detection Methods
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            guard let observations = request.results as? [VNHumanBodyPoseObservation],
                  let observation = observations.first else {
                return
            }
            
            self?.processPoseObservation(observation)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        try? handler.perform([request])
    }
    
    private func processPoseObservation(_ observation: VNHumanBodyPoseObservation) {
        // Get points of interest
        let pointsOfInterest: [VNHumanBodyPoseObservation.JointName] = [
            .leftShoulder, .rightShoulder,
            .leftElbow, .rightElbow,
            .leftWrist, .rightWrist,
            .leftHip, .rightHip,
            .leftKnee, .rightKnee,
            .leftAnkle, .rightAnkle
        ]
        
        var detectedPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        
        for joint in pointsOfInterest {
            guard let point = try? observation.recognizedPoint(joint) else { continue }
            if point.confidence > 0.7 {
                detectedPoints[joint] = CGPoint(x: point.location.x, y: 1 - point.location.y)
            }
        }
        
        DispatchQueue.main.async {
            self.detectedPosePoints = detectedPoints
            self.analyzePose()
        }
    }
    
    private func analyzePose() {
        // Example pose analysis for a simple standing posture
        guard let leftShoulder = detectedPosePoints[.leftShoulder],
              let rightShoulder = detectedPosePoints[.rightShoulder],
              let leftHip = detectedPosePoints[.leftHip],
              let rightHip = detectedPosePoints[.rightHip] else {
            return
        }
        
        // Calculate shoulder alignment
        let shoulderDiff = abs(leftShoulder.y - rightShoulder.y)
        
        // Calculate hip alignment
        let hipDiff = abs(leftHip.y - rightHip.y)
        
        // Provide feedback based on alignment
        if shoulderDiff < 0.05 && hipDiff < 0.05 {
            updateFeedback("Good posture! Shoulders and hips are well aligned.", isGood: true)
        } else {
            var feedback = "Posture needs adjustment:\n"
            if shoulderDiff >= 0.05 {
                feedback += "• Level your shoulders\n"
            }
            if hipDiff >= 0.05 {
                feedback += "• Align your hips\n"
            }
            updateFeedback(feedback, isGood: false)
        }
    }
    
    private func updateFeedback(_ message: String, isGood: Bool) {
        feedbackLabel.text = message
        feedbackLabel.backgroundColor = isGood ?
            UIColor.systemGreen.withAlphaComponent(0.7) :
            UIColor.systemRed.withAlphaComponent(0.7)
    }
}
