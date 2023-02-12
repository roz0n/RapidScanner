//
//  BarcodeCaptureViewController.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/10/23.
//

import UIKit
import ScanditCaptureCore
import ScanditBarcodeCapture

class BarcodeCaptureViewController: UIViewController {
  
  var context: DataCaptureContext?
  var barcodeCapture: BarcodeCapture?
  var captureView: DataCaptureView?
  var camera: Camera?
  
  var captureResultController = CheckoutCartTableViewController()
  
  var latestScanResult: BarcodeScanResult? {
    didSet {
      if let latestScanResult = latestScanResult {
        print("New scan: \(latestScanResult) :: \(Date())")
        
        DispatchQueue.main.async { [weak self] in
          self?.presentCaptureResultTable()
        }
      }
    }
  }
  
  var licenseKey: Dictionary<String, String>? {
    return NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Scandit", ofType: "plist")!) as? Dictionary
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    configureScandit()
    configureLayout()
  }
  
  private func configureScandit() {
    configureCapture()
    configureFrameSource()
    configureCaptureView()
  }
  
}

// MARK: - Move to Coordinator

private extension BarcodeCaptureViewController {
  
  func presentCaptureResultTable() {
    let resultController = CheckoutCartTableViewController()
    resultController.modalPresentationStyle = .formSheet
    resultController.isModalInPresentation = true
    
    if let sheet = resultController.sheetPresentationController {
      sheet.prefersGrabberVisible = true
      sheet.detents = [.medium(), .large(), .custom(resolver: { context in
        return 100
      })]
    }
    
    tabBarController?.present(resultController, animated: true)
  }
  
}

// MARK: - Scandit Configuration

private extension BarcodeCaptureViewController {
  
  private func getBarcodeSettings() -> BarcodeCaptureSettings {
    let settings = BarcodeCaptureSettings()
    
    settings.set(symbology: .code128, enabled: true)
    settings.set(symbology: .code39, enabled: true)
    settings.set(symbology: .qr, enabled: true)
    settings.set(symbology: .ean8, enabled: true)
    settings.set(symbology: .upce, enabled: true)
    settings.set(symbology: .ean13UPCA, enabled: true)
    
    return settings
  }
  
  private func getCamera() -> Camera {
    let cameraSettings = BarcodeCapture.recommendedCameraSettings
    let camera = Camera.default!
    
    camera.apply(cameraSettings)
    
    return camera
  }
  
  private func configureCapture() {
    let settings = getBarcodeSettings()
    let camera = getCamera()
    
    self.context = DataCaptureContext(licenseKey: self.licenseKey!["0"]!)
    self.barcodeCapture = BarcodeCapture(context: context, settings: settings)
    self.barcodeCapture?.addListener(self)
    self.barcodeCapture?.feedback.success = Feedback(vibration: nil, sound: nil)
    self.camera = camera
  }
  
  private func configureFrameSource() {
    context?.setFrameSource(camera)
    camera?.switch(toDesiredState: .on)
  }
  
  private func configureCaptureView() {
    captureView = DataCaptureView(context: context, frame: view.bounds)
    
    let overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture!, view: captureView)
    captureView?.addOverlay(overlay)
  }
  
}

// MARK: - BarcodeCaptureListener

extension BarcodeCaptureViewController: BarcodeCaptureListener {
  
  func barcodeCapture(_ barcodeCapture: BarcodeCapture, didScanIn session: BarcodeCaptureSession, frameData: FrameData) {
    let recognizedBarcodes = session.newlyRecognizedBarcodes
    let scanResultString = recognizedBarcodes.first?.jsonString
    
    // Decode scan data
    guard let scanData = scanResultString,
          let scanDataRaw = scanData.data(using: .utf8) else {
      return
    }
    
    guard let decodedScanData = try? JSONDecoder().decode(BarcodeScanResult.self, from: scanDataRaw) else {
      return
    }
    
    // If scan result is new, update the stored variable and do some processing
    if decodedScanData != latestScanResult {
      latestScanResult = decodedScanData
      UINotificationFeedbackGenerator().notificationOccurred(.success)
      
      // Set camera to standby, stagger return to "on" state by half a second
      camera?.switch(toDesiredState: .standby) { _ in
          DispatchQueue.main.asyncAfter(deadline: .now() + 0) { [weak self] in
            self?.camera?.switch(toDesiredState: .on)
          }
      }
    }
  }
  
}

// MARK: - Layout

private extension BarcodeCaptureViewController {
  
  func configureLayout() {
    layoutCaptureView()
    layoutResultView()
  }
  
  func layoutCaptureView() {
    guard let captureView = captureView else {
      return
    }
    
    view.addSubview(captureView)
    captureView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      captureView.topAnchor.constraint(equalTo: view.topAnchor),
      captureView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      captureView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      captureView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
  
  func layoutResultView() {
    captureResultController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(captureResultController.view)
    
    NSLayoutConstraint.activate([
      captureResultController.view.heightAnchor.constraint(equalToConstant: 64),
      captureResultController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      captureResultController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      captureResultController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
  
}
