//
//  BetterTheaterModeApp.swift
//  BetterTheaterMode
//
//  Created by David Sun on 9/23/26.
//

import SafariServices
import SwiftUI
import WebKit

let extensionBundleIdentifier = "com.dsun.BetterTheaterMode.Extension"

@main
struct BetterTheaterModeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ExtensionStatusView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

struct ExtensionStatusView: View {
    var body: some View {
        ExtensionWebView()
            .frame(minWidth: 425, idealWidth: 425, minHeight: 325, idealHeight: 325)
    }
}

struct ExtensionWebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(context.coordinator, name: "controller")
        webView.loadFileURL(
            Bundle.main.url(forResource: "Main", withExtension: "html")!,
            allowingReadAccessTo: Bundle.main.resourceURL!
        )
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { (state, error) in
                guard let state = state, error == nil else {
                    // Insert code to inform the user that something went wrong.
                    return
                }

                Task { @MainActor in
                    if #available(macOS 13, *) {
                        try? await webView.evaluateJavaScript("show(\(state.isEnabled), true)")
                    } else {
                        try? await webView.evaluateJavaScript("show(\(state.isEnabled), false)")
                    }
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.body as? String == "open-preferences" else {
                return
            }

            SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { (error) in
                Task { @MainActor in
                    NSApplication.shared.terminate(nil)
                }
            }
        }

    }
}
