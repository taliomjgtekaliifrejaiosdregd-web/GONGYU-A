// @dart = 3.3
// QR Scanner - Web implementation using html5-qrcode JS library
// For Flutter Web platform only. Mobile uses mobile_scanner package.

@JS()
library html5_qrcode;

import 'dart:js_interop';

@JS('Html5Qrcode')
extension type Html5Qrcode._(JSObject _) implements JSObject {
  external Html5Qrcode(String elementId);
  external JSPromise start(
    String cameraId,
    JSAny config, // { fps: number, qrbox: { width: number, height: number } }
    JSFunction successCallback, // (decodedText: string, decodedResult: any) => void
    JSFunction errorCallback, // (errorMessage: string, error: any) => void
  );
  external JSPromise stop();
  external JSPromise clear();
}

@JS('Html5Qrcode.getCameras')
external JSPromise getCameras();

@JS()
extension type CameraDevice._(JSObject _) implements JSObject {
  external String get id;
  external String get label;
}
