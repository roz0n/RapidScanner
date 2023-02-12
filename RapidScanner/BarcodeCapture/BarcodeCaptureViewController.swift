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
  
  // MARK: - Checkout Card
  
  var checkoutCardController = CheckoutCartTableViewController()
  var checkoutCardHeightConstraint: NSLayoutConstraint?
  
  let checkoutCardMaxHeight = (UIScreen.main.bounds.height - (CheckoutCartTableViewController.defaultShowHeight * 3))
  let checkoutCardDefaultHeight: CGFloat = CheckoutCartTableViewController.defaultShowHeight
  let checkoutCardDismissableHeight: CGFloat = (CheckoutCartTableViewController.defaultShowHeight * 2)
  
  // This variable will keep getting updated with the new height
  var currentCheckoutCardHeight: CGFloat = CheckoutCartTableViewController.defaultShowHeight
  
  // MARK: - Properties
  
  var latestScanResult: BarcodeScanResult? {
    didSet {
      if let latestScanResult = latestScanResult {
        print("New scan: \(latestScanResult) :: \(Date())")
        
        // Update checkoutCardController data here
      }
    }
  }
  
  var licenseKey: Dictionary<String, String>? {
    return NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Scandit", ofType: "plist")!) as? Dictionary
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupScandit()
    setupPanGesture()
    
    setupContraints()
  }
  
  private func setupScandit() {
    setupCapture()
    setupFrameSource()
    setupCaptureView()
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
  
  private func setupCapture() {
    let settings = getBarcodeSettings()
    let camera = getCamera()
    
    self.context = DataCaptureContext(licenseKey: self.licenseKey!["0"]!)
    self.barcodeCapture = BarcodeCapture(context: context, settings: settings)
    self.barcodeCapture?.addListener(self)
    self.barcodeCapture?.feedback.success = Feedback(vibration: nil, sound: nil)
    self.camera = camera
  }
  
  private func setupFrameSource() {
    context?.setFrameSource(camera)
    camera?.switch(toDesiredState: .on)
  }
  
  private func setupCaptureView() {
    captureView = DataCaptureView(context: context, frame: view.bounds)
    
    let overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture!, view: captureView)
    captureView?.addOverlay(overlay)
  }
  
  private func setupPanGesture() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    
    panGesture.delaysTouchesBegan = false
    panGesture.delaysTouchesEnded = false
    
    view.addGestureRecognizer(panGesture)
  }
  
  @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: view)
    let isDraggingUp = translation.y < 0
    let newHeight = currentCheckoutCardHeight - (translation.y)
    
    switch gesture.state {
      case .changed:
        if newHeight < checkoutCardMaxHeight {
          // Keep updating the height constraint as the translation value changes
          checkoutCardHeightConstraint?.constant = newHeight
          
          // Update update dynamic constraints
          view.layoutIfNeeded()
        }
      case .ended:
        if newHeight < checkoutCardDismissableHeight {
          self.animateContainerHeight(checkoutCardDefaultHeight)
        } else if newHeight < checkoutCardDefaultHeight {
          self.animateContainerHeight(checkoutCardDefaultHeight)
        } else if newHeight < checkoutCardMaxHeight && !isDraggingUp {
          animateContainerHeight(checkoutCardDefaultHeight)
        } else if newHeight > checkoutCardDefaultHeight && isDraggingUp {
          animateContainerHeight(checkoutCardMaxHeight)
        }
      default:
        break
    }
  }
  
  private func animateContainerHeight(_ height: CGFloat) {
    UIView.animate(withDuration: 0.4) { [weak self] in
      self?.checkoutCardHeightConstraint?.constant = height
      self?.view.layoutIfNeeded()
    }
    
    currentCheckoutCardHeight = height
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

// MARK: - Constraints

private extension BarcodeCaptureViewController {
  
  func setupContraints() {
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
    checkoutCardController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(checkoutCardController.view)
    
    NSLayoutConstraint.activate([
      //      checkoutCardController.view.heightAnchor.constraint(equalToConstant: 64),
      checkoutCardController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      checkoutCardController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      checkoutCardController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    checkoutCardHeightConstraint = checkoutCardController.view.heightAnchor.constraint(equalToConstant: checkoutCardDefaultHeight)
    checkoutCardHeightConstraint?.isActive = true
  }
  
}
