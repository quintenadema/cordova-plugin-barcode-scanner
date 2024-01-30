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

		guard let title = command.arguments[0] as? String else {
			sendPluginResult(false, data: "Invalid title argument")
			return
		}
		
		guard let description = command.arguments[1] as? String else {
			sendPluginResult(false, data: "Invalid description argument")
			return
		}
		
		let titleLabel = UILabel()
		titleLabel.text = title
		titleLabel.font = UIFont.systemFont(ofSize: 48, weight: .semibold)
		titleLabel.textAlignment = .center
		titleLabel.frame = CGRect(x: 0, y: 40, width: modalViewController.view.frame.width, height: 48)

		let descriptionLabel = UILabel()
		descriptionLabel.text = description
		descriptionLabel.font = UIFont.systemFont(ofSize: 16)
		descriptionLabel.alpha = 0.7
		descriptionLabel.textAlignment = .center
		descriptionLabel.frame = CGRect(x: 20, y: 100, width: modalViewController.view.frame.width - 40, height: 16)


		
		let capture = ZXCapture()
		
		capture.hints = ZXDecodeHints.hints() as? ZXDecodeHints
		capture.hints?.addPossibleFormat(kBarcodeFormatAztec)
		capture.hints?.addPossibleFormat(kBarcodeFormatCodabar)
		capture.hints?.addPossibleFormat(kBarcodeFormatCode39)
		capture.hints?.addPossibleFormat(kBarcodeFormatCode93)
		capture.hints?.addPossibleFormat(kBarcodeFormatCode128)
		capture.hints?.addPossibleFormat(kBarcodeFormatDataMatrix)
		capture.hints?.addPossibleFormat(kBarcodeFormatEan8)
		capture.hints?.addPossibleFormat(kBarcodeFormatEan13)
		capture.hints?.addPossibleFormat(kBarcodeFormatITF)
		capture.hints?.addPossibleFormat(kBarcodeFormatMaxiCode)
		capture.hints?.addPossibleFormat(kBarcodeFormatPDF417)
		capture.hints?.addPossibleFormat(kBarcodeFormatQRCode)
		capture.hints?.addPossibleFormat(kBarcodeFormatRSS14)
		capture.hints?.addPossibleFormat(kBarcodeFormatRSSExpanded)
		capture.hints?.addPossibleFormat(kBarcodeFormatUPCA)
		capture.hints?.addPossibleFormat(kBarcodeFormatUPCE)
		capture.hints?.addPossibleFormat(kBarcodeFormatUPCEANExtension)
		

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
		
		let blurEffect = UIBlurEffect(style: .regular)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = overlayView.bounds
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		blurEffectView.alpha = 0.7
		
		overlayView.addSubview(blurEffectView)
		
		
		modalViewController.view.addSubview(overlayView)
		
		modalViewController.view.addSubview(titleLabel)
		modalViewController.view.addSubview(descriptionLabel)
		
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
