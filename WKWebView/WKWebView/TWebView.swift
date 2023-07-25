//
//  TWebView.swift
//  WebViewTestApp
//
//  Created by Mac on 2023/07/25.
//

import Foundation
import WebKit
import AVFoundation

public class TWebView: WKWebView {

    init(rect: CGRect = CGRect.zero) {
        super.init(frame: rect, configuration: WKWebViewConfiguration())
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func overrideLogging() {
                      let JS = """
                          function log(emoji, type, args) {
                            if(!args && !type) {
                                let message = emoji
                                window.webkit.messageHandlers.logging.postMessage(`${message}`)
                            } else if(!args) {
                                 let message = type
                                 window.webkit.messageHandlers.logging.postMessage(`${emoji} ${message}`)
                            } else {
                               window.webkit.messageHandlers.logging.postMessage(
                                 `${emoji} JS ${type}: ${Object.values(args)
                                   .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v) : v.toString())
                                   .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
                                   .join(", ")}`
                                )
                            }
                          }

                          let originalLog = console.log
                          let originalWarn = console.warn
                          let originalError = console.error
                          let originalDebug = console.debug

                          console.log = function() { log("📗", "log", arguments); originalLog.apply(null, arguments) }
                          console.warn = function() { log("📙", "warning", arguments); originalWarn.apply(null, arguments) }
                          console.error = function() { log("📕", "error", arguments); originalError.apply(null, arguments) }
                          console.debug = function() { log("📘", "debug", arguments); originalDebug.apply(null, arguments) }

                          window.addEventListener("error", function(e) {
                             log("💥", "Uncaught", [`${e.message} at ${e.filename}:${e.lineno}:${e.colno}`])
                          })
                      """
        configuration.userContentController.addUserScript(WKUserScript(source: JS, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        configuration.userContentController.add(LoggingMessageHandler(), name: "logging")
    }
    
    public func enumerateDevices(completionHandler: @escaping (String) -> Void) -> Void {
        let JS = """
                 //# sourceURL=enumerateDevices.js
                 var _ = getDevices();
                 """
        self.evaluateJavaScript(JS) { (result, error) in
            if error != nil {
                print("getDevices error: \(String(describing: error))")
                completionHandler("")
            } else {
                print("getDevices result: \(String(describing: result))")
                completionHandler(result as? String ?? "")
            }
        }
    }

    public func getUserMedia(completionHandler: @escaping (Bool) -> Void) -> Void {
//        AVCaptureDevice.requestAccess(for: .audio) { granted in
//            if granted {
//                print("audio granted")
//            } else {
//                print("audio denied")
//            }
//        }
        let JS = """
                 //# sourceURL=getUserMedia.js
                 var _ = getUserMedia();
                 """
        self.evaluateJavaScript(JS) { (result, error) in
            if error != nil {
                print("getUserMedia error: \(String(describing: error))")
                completionHandler(false)
            } else {
                print("getUserMedia result: \(String(describing: result))")
                completionHandler(result as? Bool ?? false)
            }
        }
    }
}

public class LoggingMessageHandler: NSObject, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("[WebView:\(message.name)] \(message.body)")
    }
}
