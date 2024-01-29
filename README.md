# Cordova Plugin Barcode Scanner

This plugin allows you to scan barcodes.

## Supported platforms

- iOS
- Android

## Barcode types

- QR Code
- Data matrix

## Requirements

- Cordova: at least version 9
- Android: Cordova-android of at least 8.0.0

## Installation

To install the plugin, run:
```
cordova plugin add https://github.com/quintenadema/cordova-plugin-barcode-scanner
```

## API

The API is available as a global `barcodeScanner` object

### Scan

```
try {
	const result = await barcodeScanner.scan();
	console.log("Got barcode result", result);
} catch (error) {
	console.log("Could not get barcode", error);
}
```