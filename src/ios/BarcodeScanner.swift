import ZXingObjC
import UIKit

@available(iOS 13.0, *)
class BarcodeScanner: CDVPlugin, ZXCaptureDelegate {
	// Properties
	private var onCallbacks = [String: String]()
	private var currentCommand: CDVInvokedUrlCommand?
	private var zxingCapture: ZXCapture?
	
	// Initialization
	@objc func initialize(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		return sendPluginResult(true)
	}

	func sendPluginResult(_ success: Bool, data: Any? = nil, callbackId: String? = nil) {
		var pluginResult: CDVPluginResult?
		let status = success ? CDVCommandStatus_OK : CDVCommandStatus_ERROR
		
		switch data {
		case let data as String:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as Int:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as CGFloat:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as Double:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as Bool:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as [Any]:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case let data as [String: Any]:
			pluginResult = CDVPluginResult(status: status, messageAs: data)
		case nil:
			pluginResult = CDVPluginResult(status: status)
		default:
			print("Unexpected data type: \(type(of: data))")
			return
		}
		
		pluginResult?.setKeepCallbackAs(true)
		self.commandDelegate?.send(pluginResult, callbackId: callbackId != nil ? callbackId : self.currentCommand?.callbackId)
	}


	@objc func scan(_ command: CDVInvokedUrlCommand) {
		self.currentCommand = command
		
		// Create a view controller for the modal
		let modalViewController = UIViewController()
		modalViewController.modalPresentationStyle = .pageSheet
		
		// ZXing Capture setup
		let capture = ZXCapture()

		// Selecting the ultra-wide camera if available, otherwise the main camera
		let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
		if let videoCaptureDevice = videoDeviceDiscoverySession.devices.first {
		    capture.captureDevice = videoCaptureDevice
		}

		capture.focusMode = .continuousAutoFocus
		capture.layer.frame = modalViewController.view.bounds
		modalViewController.view.layer.addSublayer(capture.layer)

		// Keep a reference to the ZXing capture
		self.zxingCapture = capture

		// Set ZXing delegate
		capture.delegate = self

		// Start ZXing capture
		capture.start()
		
		// Create the overlay
		let overlayView = UIView(frame: modalViewController.view.frame)
		overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
		modalViewController.view.addSubview(overlayView)
		
		// Create a transparent square
		let squareSize = CGSize(width: 200, height: 200)
		let squareOrigin = CGPoint(x: (overlayView.bounds.width - squareSize.width) / 2, y: (overlayView.bounds.height - squareSize.height) / 2)
		let transparentSquare = CGRect(origin: squareOrigin, size: squareSize)
		
		let maskLayer = CAShapeLayer()
		let path = CGMutablePath()
		path.addRect(overlayView.bounds)
		path.addRoundedRect(in: transparentSquare, cornerWidth: 20, cornerHeight: 20)
		maskLayer.path = path
		maskLayer.fillRule = .evenOdd
		overlayView.layer.mask = maskLayer
		
		// Present the modal
		self.viewController.present(modalViewController, animated: true, completion: nil)
		return sendPluginResult(true)
	}
	
	func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
		if let result = result {
			let scannedData = result.text
			
			sendPluginResult(true, data: scannedData)
			
			capture.stop()
		}
	}
}
