//
//  ImgCfViewController.swift
//  Guidy
//
//  Created by seunghwan Lee on 2020/05/18.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import AVFoundation
import UIKit

class ImgCfViewController: UIViewController {

  // MARK: Storyboards Connections
  @IBOutlet weak var previewView: PreviewView!
  @IBOutlet weak var cameraUnavailableLabel: UILabel!
  @IBOutlet weak var resumeButton: UIButton!

  // MARK: Constants
//  private let animationDuration = 0.5
//  private let collapseTransitionThreshold: CGFloat = -40.0
//  private let expandThransitionThreshold: CGFloat = 40.0
  private let delayBetweenInferencesMs: Double = 1000

  // MARK: Instance Variables
  // Holds the results at any time
  private var result: Result?
  private var initialBottomSpace: CGFloat = 0.0
  private var previousInferenceTimeMs: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000

  // MARK: Controllers that manage functionality
  // Handles all the camera related functionality
  private lazy var cameraCapture = CameraFeedManager(previewView: previewView)

  // Handles all data preprocessing and makes calls to run inference through the `Interpreter`.
  private var modelDataHandler: ModelDataHandler? =
    ModelDataHandler(modelFileInfo: MobileNet.modelInfo, labelsFileInfo: MobileNet.labelsInfo)

  // Handles the presenting of results on the screen
//  private var inferenceViewController: InferenceViewController?

  // MARK: View Handling Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    guard modelDataHandler != nil else {
      fatalError("Model set up failed")
    }
    
#if targetEnvironment(simulator)
    previewView.shouldUseClipboardImage = true
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(classifyPasteboardImage),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
#endif
    cameraCapture.delegate = self

//    addPanGesture()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

//    changeBottomViewState()

#if !targetEnvironment(simulator)
    cameraCapture.checkCameraConfigurationAndStartSession()
#endif
  }

#if !targetEnvironment(simulator)
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    cameraCapture.stopSession()
  }
#endif

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  func presentUnableToResumeSessionAlert() {
    let alert = UIAlertController(
      title: "Unable to Resume Session(세션 재개 불가)",
      message: "There was an error while attempting to resume session.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    self.present(alert, animated: true)
  }
    
  @objc func classifyPasteboardImage() {
    guard let image = UIPasteboard.general.images?.first else {
      return
    }

    guard let buffer = CVImageBuffer.buffer(from: image) else {
      return
    }

    previewView.img = image

    DispatchQueue.global().async {
      self.didOutput(pixelBuffer: buffer)
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

}

// MARK: InferenceViewControllerDelegate Methods
//extension ImgCfViewController: InferenceViewControllerDelegate {
//
//  func didChangeThreadCount(to count: Int) {
//    if modelDataHandler?.threadCount == count { return }
//    modelDataHandler = ModelDataHandler(
//      modelFileInfo: MobileNet.modelInfo,
//      labelsFileInfo: MobileNet.labelsInfo,
//      threadCount: count
//    )
//  }
//}

// MARK: CameraFeedManagerDelegate Methods
extension ImgCfViewController: CameraFeedManagerDelegate {

  func didOutput(pixelBuffer: CVPixelBuffer) {
    let currentTimeMs = Date().timeIntervalSince1970 * 1000
    guard (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else { return }
    previousInferenceTimeMs = currentTimeMs

    // Pass the pixel buffer to TensorFlow Lite to perform inference.
    result = modelDataHandler?.runModel(onFrame: pixelBuffer)
    
    print(result)
    
    if result!.inferences[0].confidence > 0.9 {
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuideVC") as! GuideViewController

            guard self.result?.inferences[0].label != "땅" && self.result?.inferences[0].label != "하늘" else{
                return
            }

            vc.name = self.result!.inferences[0].label
            self.navigationController?.pushViewController(vc, animated: true)
            //   vc.modalPresentationStyle = .fullScreen
            //   self.present(vc, animated: true, completion: nil)
        }
    }
  }

  // MARK: Session Handling Alerts
  func sessionWasInterrupted(canResumeManually resumeManually: Bool) {

    // Updates the UI when session is interupted.
    if resumeManually {
      self.resumeButton.isHidden = false
    } else {
      self.cameraUnavailableLabel.isHidden = false
    }
  }

  func sessionInterruptionEnded() {
    // Updates UI once session interruption has ended.
    if !self.cameraUnavailableLabel.isHidden {
      self.cameraUnavailableLabel.isHidden = true
    }

    if !self.resumeButton.isHidden {
      self.resumeButton.isHidden = true
    }
  }

  func sessionRunTimeErrorOccured() {
    // Handles session run time error by updating the UI and providing a button if session can be manually resumed.
    self.resumeButton.isHidden = false
    previewView.shouldUseClipboardImage = true
  }

  func presentCameraPermissionsDeniedAlert() {
    let alertController = UIAlertController(title: "Camera Permissions Denied", message: "Camera permissions have been denied for this app. You can change this by going to Settings", preferredStyle: .alert)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)

    present(alertController, animated: true, completion: nil)

    previewView.shouldUseClipboardImage = true
  }

  func presentVideoConfigurationErrorAlert() {
    let alert = UIAlertController(title: "Camera Configuration Failed", message: "There was an error while configuring camera.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    self.present(alert, animated: true)
    previewView.shouldUseClipboardImage = true
  }
}








