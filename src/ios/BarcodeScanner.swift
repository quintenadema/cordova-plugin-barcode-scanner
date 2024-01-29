class BarcodeScanner: CDVPlugin {
	// Properties
	private var onCallbacks = [String: String]()

	private var currentCommand: CDVInvokedUrlCommand?
	
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

        let modalViewController = UIViewController()
        modalViewController.view.backgroundColor = .white
        modalViewController.modalPresentationStyle = .fullScreen

        self.viewController.present(modalViewController, animated: true, completion: nil)

        return sendPluginResult(true)
    }
}