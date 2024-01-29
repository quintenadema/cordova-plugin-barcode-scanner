var exec = require('cordova/exec');

var barcodeScanner = {};

barcodeScanner['scan'] = async function() {
	return new Promise((resolve, reject) => {
		exec(resolve, reject, "BarcodeScanner", "scan", []);
	});
}

module.exports = barcodeScanner;