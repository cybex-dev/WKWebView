//
//  WKWebViewApp.swift
//  WKWebView
//
//  Created by Mac on 2023/07/25.
//

import SwiftUI

@main
struct WKWebViewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    let webView = TWebView();

    var body: some View {
        VStack {
            Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            EnumerateButton(webView)
            GetMediaButton(webView)
        }.padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let webView = TWebView();
//        ContentView(webView)
//    }
//}

struct EnumerateButton: View {
    @State var webView = TWebView();

    init(_ webView: TWebView) {
        self.webView = webView
    }

    var body: some View {
        Button(action: {
            webView.enumerateDevices { (result) in
                print("\(result)")
            }
        }) {
            Text("Enumerate Devices")
        }
    }
}

struct GetMediaButton: View {

    @State var webView = TWebView();

    init(_ webView: TWebView) {
        self.webView = webView
    }

    var body: some View {
        Button(action: {
            webView.getUserMedia { (result) in
                print("\(result ? "Success" : "Failed")")
            }
        }) {
            Text("Get User Media")
        }
    }
}
