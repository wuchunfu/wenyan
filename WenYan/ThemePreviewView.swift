//
//  ThemePreviewView.swift
//  WenYan
//
//  Created by Lei Cao on 2024/10/23.
//

import SwiftUI
import WebKit

struct ThemePreviewView: NSViewRepresentable {
    @EnvironmentObject var viewModel: ThemePreviewViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        let userController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.isInspectable = true
        viewModel.setupWebView(webView)
        viewModel.loadIndex()
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {

    }
    
}

class ThemePreviewViewModel: NSObject, WKNavigationDelegate, WKScriptMessageHandler, ObservableObject {
    @Published var appState: AppState
    weak var webView: WKWebView?
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // 初始化 WebView
    func setupWebView(_ webView: WKWebView) {
        webView.navigationDelegate = self
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.allowsMagnification = false
        self.webView = webView
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 处理来自 JavaScript 的消息
    }
    
}

extension ThemePreviewViewModel {
    
    func loadIndex() {
        do {
            let html = try loadFileFromResource(forResource: "example", withExtension: "html")
            webView?.loadHTMLString(html, baseURL: getResourceBundle())
        } catch {
            appState.appError = AppError.bizError(description: error.localizedDescription)
        }
    }
    
    func onUpdate(css: String) {
        callJavascript(javascriptString: "setCss(\(css.toJavaScriptString()));")
    }
    
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }
}
