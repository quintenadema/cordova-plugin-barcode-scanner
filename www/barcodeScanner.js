var exec = require('cordova/exec');

var barcodeScanner = {};

barcodeScanner['scan'] = async function(title = '', description = '') {
	return new Promise((resolve, reject) => {
		exec(resolve, reject, "BarcodeScanner", "scan", [title, description]);
	});
}

module.exports = barcodeScanner;