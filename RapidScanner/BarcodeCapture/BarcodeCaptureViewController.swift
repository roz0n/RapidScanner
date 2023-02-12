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
  
  // MARK: - Increment Quantity
  
  var scanResultButtonsContainerTopConstraint: NSLayoutConstraint?
  
  lazy var adjustQuantityButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setImage(UIImage(systemName: "bag.badge.plus"), for: .normal)
    button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    button.layer.cornerRadius = 12
    button.tintColor = .white
    button.backgroundColor = .systemBackground.withAlphaComponent(0.5)
    return button
  }()
  
  lazy var addToCartButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
    button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    button.layer.cornerRadius = 12
    button.tintColor = .white
    button.backgroundColor = .systemBackground.withAlphaComponent(0.5)
    return button
  }()
  
  lazy var scanResultButtonsContainer: UIStackView = {
    let stack = UIStackView()
    stack.spacing = UIStackView.spacingUseSystem
    stack.distribution = .fillEqually
    return stack
  }()
  
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
    
    setupScandit()
    setupPanGesture()
    setupIncrementButton()
    setupContinueButton()
    
    setupContraints()
  }
  
}

// MARK: - Setup

private extension BarcodeCaptureViewController {
  
  private func setupScandit() {
    setupCapture()
    setupFrameSource()
    setupCaptureView()
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
  
  private func setupIncrementButton() {
    adjustQuantityButton.addTarget(self, action: #selector(handleIncrementButtonTap(_:)), for: .touchUpInside)
  }
  
  private func setupContinueButton() {
    addToCartButton.addTarget(self, action: #selector(handleContinueButtonTap(_:)), for: .touchUpInside)
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
  
}

// MARK: - Helpers

extension BarcodeCaptureViewController {
  
  private func hidePostScanButtons() {
    camera?.switch(toDesiredState: .on) { _ in
        DispatchQueue.main.async {
          UIView.animate(withDuration: 0.75,
                         delay: 0,
                         usingSpringWithDamping: 0.75,
                         initialSpringVelocity: 0.75,
                         options: .curveEaseInOut) {
            self.scanResultButtonsContainerTopConstraint?.constant = -(UIScreen.main.bounds.height / 2)
            self.view.layoutIfNeeded()
          }
        }
    }
  }
  
  private func showPostScanButtons() {
    camera?.switch(toDesiredState: .standby) { _ in
        DispatchQueue.main.async {
          UIView.animate(withDuration: 0.4,
                         delay: 0,
                         usingSpringWithDamping: 0.75,
                         initialSpringVelocity: 0.75,
                         options: .curveEaseInOut) {
            self.scanResultButtonsContainerTopConstraint?.constant = 8
            self.view.layoutIfNeeded()
          }
        }
    }
  }
  
  private func presentQuantityModal() {
    let alertController = UIAlertController(title: "Adjust Quantity",
                                            message: "Enter an amount including the scanned item",
                                            preferredStyle: .alert)
    
    alertController.addTextField { textField in
      textField.placeholder = "1 or more"
      textField.isSecureTextEntry = false
      textField.keyboardType = .decimalPad
    }
    
    let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
      guard let field = alertController.textFields?.first else {
        return
      }
      
      print("Quantity entered: \(field.text)")
      self.hidePostScanButtons()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
      print("Cancelled quantity entry")
      self.hidePostScanButtons()
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(confirmAction)
    alertController.isModalInPresentation = true
    
    present(alertController, animated: true)
  }
  
  private func animateContainerHeight(_ height: CGFloat) {
    UIView.animate(withDuration: 0.4,
                   delay: 0,
                   usingSpringWithDamping: 0.75,
                   initialSpringVelocity: 0.75,
                   options: .curveEaseInOut) { [weak self] in
      self?.checkoutCardHeightConstraint?.constant = height
      self?.view.layoutIfNeeded()
    }
    
    currentCheckoutCardHeight = height
  }
  
}

// MARK: - Gestures

extension BarcodeCaptureViewController {
  
  @objc func handleIncrementButtonTap(_ sender: UIButton) {
    print("Tapped increment button")
    presentQuantityModal()
  }
  
  @objc func handleContinueButtonTap(_ sender: UIButton) {
    print("Tapped continue button")
    hidePostScanButtons()
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
      
      // Set camera to standby, stagger return to "on" state by a quarter of a second (the delay might not be needed)
      camera?.switch(toDesiredState: .standby) { _ in
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.camera?.switch(toDesiredState: .on)
          }
      }
    } else {
      // Handle duplicate scan
      print("This is a duplicate scan")
      
      DispatchQueue.main.async {
        self.showPostScanButtons()
      }
    }
  }
  
}

// MARK: - Constraints

private extension BarcodeCaptureViewController {
  
  func setupContraints() {
    layoutCaptureView()
    layoutResultView()
    layoutPostScanContainer()
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
      checkoutCardController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      checkoutCardController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      checkoutCardController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    checkoutCardHeightConstraint = checkoutCardController.view.heightAnchor.constraint(equalToConstant: checkoutCardDefaultHeight)
    checkoutCardHeightConstraint?.isActive = true
  }
  
  func layoutPostScanContainer() {
    scanResultButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scanResultButtonsContainer)
    
    scanResultButtonsContainer.addArrangedSubview(adjustQuantityButton)
    scanResultButtonsContainer.addArrangedSubview(addToCartButton)
    
    NSLayoutConstraint.activate([
      scanResultButtonsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      scanResultButtonsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
    ])
    
    scanResultButtonsContainerTopConstraint = adjustQuantityButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                                                 constant: -(UIScreen.main.bounds.height / 2))
    scanResultButtonsContainerTopConstraint?.isActive = true
  }
  
}
