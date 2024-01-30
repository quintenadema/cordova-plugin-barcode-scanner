# Cordova Plugin Barcode Scanner

This plugin allows you to scan barcodes.

## Supported platforms

- iOS
- Android

## Barcode types

- UPC-A and UPC-E
- EAN-8 and EAN-13
- Code 39
- Code 93
- Code 128
- ITF
- Codabar
- RSS-14 (all variants)
- QR Code
- Data Matrix
- Maxicode
- Aztec ('beta' quality)
- PDF 417 ('beta' quality)

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

To start the scanner, run the following command.
You can enter the `Title` and `Description` to show in the sheet, or leave it empty if you so desire.

```
try {
	const result = await barcodeScanner.scan('Title', 'Description');
	console.log("Got barcode result", result);
} catch (error) {
	console.log("Could not get barcode", error);
}
```