import ZXingObjC
import UIKit

@available(iOS 13.0, *)
class BarcodeScanner: CDVPlugin, ZXCaptureDelegate {
	private var currentCommand: CDVInvokedUrlCommand?
	private var zxingCapture: ZXCapture?

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
		
		let modalViewController = UIViewController()
		modalViewController.modalPresentationStyle = .pageSheet
		modalViewController.presentationController?.delegate = self
		
		let capture = ZXCapture()

		let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
		if let videoCaptureDevice = videoDeviceDiscoverySession.devices.first {
		    capture.captureDevice = videoCaptureDevice
		}

		capture.focusMode = .continuousAutoFocus
		capture.layer.frame = modalViewController.view.bounds
		modalViewController.view.layer.addSublayer(capture.layer)

		self.zxingCapture = capture

		capture.delegate = self

		capture.start()
		
		let overlayView = UIView(frame: modalViewController.view.frame)
		overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
		modalViewController.view.addSubview(overlayView)
		
		let squareSize = CGSize(width: 200, height: 200)
		let squareOrigin = CGPoint(x: (overlayView.bounds.width - squareSize.width) / 2,
								   y: (overlayView.bounds.height - squareSize.height) / 2)
		let transparentSquare = CGRect(origin: squareOrigin, size: squareSize)
		
		let maskLayer = CAShapeLayer()
		let path = CGMutablePath()
		path.addRect(overlayView.bounds)
		path.addRoundedRect(in: transparentSquare, cornerWidth: 20, cornerHeight: 20)
		maskLayer.path = path
		maskLayer.fillRule = .evenOdd
		overlayView.layer.mask = maskLayer
		
		self.viewController.present(modalViewController, animated: true, completion: nil)
	}
	
	func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
		if let result = result {
			let scannedData = result.text
			self.viewController.dismiss(animated: true, completion: nil)
			
			sendPluginResult(true, data: scannedData)
			
			capture.hard_stop()
		} else {
			self.viewController.dismiss(animated: true) {
				self.sendPluginResult(false, data: "No barcode detected")
			}
			
			capture.hard_stop()
		}
	}
	
	func closeModal() {
		self.zxingCapture?.hard_stop()
		self.viewController.dismiss(animated: true) {
			self.sendPluginResult(false, data: "No barcode detected")
		}
	}
}

@available(iOS 13.0, *)
extension BarcodeScanner: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		closeModal()
	}
}
