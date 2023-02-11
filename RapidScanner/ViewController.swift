//
//  ViewController.swift
//  RapidScanner
//
//  Created by Arnaldo Rozon on 2/10/23.
//

import UIKit
import ScanditCaptureCore
import ScanditBarcodeCapture

class ViewController: UIViewController {
  
  var context: DataCaptureContext?
  var barcodeCapture: BarcodeCapture?
  var camera: Camera?
  
  var licenseKey: Dictionary<String, String>? {
    if let path = Bundle.main.path(forResource: "Scandit", ofType: "plist"),
       let licenseKey = NSDictionary(contentsOfFile: path) {
      return licenseKey as? Dictionary
    } else {
      return nil
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureCapture()
    configureFrameSource()
    configureCaptureView()
    
    configureView()
  }
  
  private func configureView() {
    view.backgroundColor = .systemRed
  }
  
}

// MARK: - Scandit Configuration

private extension ViewController {
  
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
    self.context = DataCaptureContext(licenseKey: self.licenseKey!["LicenseKey"]!)
    self.barcodeCapture = BarcodeCapture(context: context, settings: getBarcodeSettings())
    self.barcodeCapture?.addListener(self)
    
    self.camera = getCamera()
    
  }
  
  private func configureFrameSource() {
    context?.setFrameSource(camera)
    camera?.switch(toDesiredState: .on)
  }
  
  private func configureCaptureView() {
    let captureView = DataCaptureView(context: context, frame: view.bounds)
    let overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture!, view: captureView)
    
    captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    captureView.addOverlay(overlay)
    view.addSubview(captureView)
  }
  
}

// MARK: - BarcodeCaptureListener

extension ViewController: BarcodeCaptureListener {
  
  func barcodeCapture(_ barcodeCapture: BarcodeCapture, didScanIn session: BarcodeCaptureSession, frameData: FrameData) {
    let recognizedBarcodes = session.newlyRecognizedBarcodes
    
    for barcode in recognizedBarcodes {
      print("\(barcode.jsonString) :: \(barcode.symbology)")
    }
  }
  
}