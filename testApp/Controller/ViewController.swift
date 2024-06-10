//
//  ViewController.swift
//  Test App
//
//  Created by Rui Reis on 05/03/2021.
//

import UIKit
import WebKit
import Usercentrics

class ViewController: UIViewController, WKUIDelegate {
    
    // Usercentrics
    let LOG_TAG = "[USERCENTRICS][ERROR]: "
    let uc = Usercentrics()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnShowCMPAction(_ sender: UIButton) {
        let btnAIdentifier = sender.accessibilityIdentifier
        print("Show CMP Button(\(btnAIdentifier ?? "Not Defined")) Clicked ")
        uc.showCMP(self, buttonIdentifier: sender.accessibilityIdentifier)
    }
    
    @IBAction func btnResetAction(_ sender: Any) {
        print("Reset Button Tapped")
        uc.resetCMP()
    }
    
    private func restoreSessionOnWebview(url: String) {
        var myWebView: WKWebView
        let sessionData = UsercentricsCore.shared.getUserSessionData()
        
        let script = """
            window.UC_UI_USER_SESSION_DATA = \(sessionData);
        """
        
        let log = """
            console.log(window.UC_UI_USER_SESSION_DATA);
        """
        
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let logScript = WKUserScript(source: log, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        contentController.addUserScript(logScript)
        
        print("Open Webview Button Tapped")
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        webConfiguration.userContentController = contentController
        myWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        //for debugging only - webview can be inspected in Safari on devices iOS 16.4+
        if #available(iOS 16.4, *) {
            myWebView.isInspectable = true
        }
        myWebView.uiDelegate = self
        
        myWebView.frame = view.bounds
        myWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(myWebView)
        
        let myUrl = URL(string: url)
        if myUrl == nil {
            print("\(LOG_TAG) URL provided is not properly formatted.")
            
        }
        
        let myRequest = URLRequest(url: myUrl!)
        myWebView.load(myRequest)
        
    }
    
//    private func restoreSessionOnWebview(url: String, webView: WKWebView){
//        var myWebView: WKWebView
//        let sessionData = UsercentricsCore.shared.getUserSessionData()
//
//        let script = """
//            window.UC_UI_USER_SESSION_DATA = \(sessionData);
//        """
//
//        let log = """
//            console.log(window.UC_UI_USER_SESSION_DATA);
//        """
//
//        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
//        let logScript = WKUserScript(source: log, injectionTime: .atDocumentStart, forMainFrameOnly: true)
//        let contentController = WKUserContentController()
//        contentController.addUserScript(userScript)
//        contentController.addUserScript(logScript)
//
//        let webConfiguration = WKWebViewConfiguration()
//        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
//        webConfiguration.userContentController = contentController
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
//
//        let url = URL(string: url)
//        if url == nil {
//            print("\(LOG_TAG) URL provided is not properly formatted.")
//
//        }
//
//        let myRequest = URLRequest(url: url!)
//        webView.load(myRequest)
//    }
    
    @IBAction func btnOpenWebviewAction(_ sender: Any) {
        let url = "https://uc-piotukh.github.io/gtm.html"
        
        //
        restoreSessionOnWebview(url: url)
        
        
        //uc.openWebview(webView: self.webView, viewController: self)
    }
}
