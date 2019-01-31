//
//  ViewController.swift
//  my-UIWebView-demo
//
//  Created by Kevin Chiang on 2018/12/13.
//  Copyright © 2018年 Kevin Chiang. All rights reserved.
//

import UIKit
import WebKit

class MainViewController: UIViewController {
  
  // **********************
  // MARK: - Declarations -
  // **********************
  
  // MARK: -- Constants --
  
  private let defaultWebsiteUrl = "https://www.youtube.com"
  
  // MARK: -- Public Properties --
  
  // MARK: -- Internal Properties --
  
  // MARK: -- Private Properties --
  
  // MARK: -- Enums --
  
  // MARK: -- Init --
  
  // MARK: -- Override --
  
  
  // **********************
  // MARK: - UI & Actions -
  // **********************
  
  // MARK: -- UI --
  
  @IBOutlet weak var myWebTitleView: UIView!
  
  
  @IBOutlet weak var btnGoBack: UIButton!
  
  @IBOutlet weak var btnGoFoward: UIButton!
  
  @IBOutlet weak var myTextField: UITextField!
  
  @IBOutlet weak var myIndicator: UIActivityIndicatorView!
  
  
  @IBOutlet weak var myWebView: WKWebView!
  
  
  // MARK: -- Actions --
  
  @IBAction func onClickBtnGoBack(_ sender: Any) {
    myWebView.goBack()
  }
  
  @IBAction func onClickBtnGoForward(_ sender: Any) {
    myWebView.goForward()
  }
  
  @IBAction func onClickBtnReload(_ sender: Any) {
    myWebView.reload()
  }
  
  @IBAction func onClickBtnStopLoading(_ sender: Any) {
    myWebView.stopLoading()
    myIndicator.stopAnimating()
  }
  
  @IBAction func onClickBtnGo(_ sender: Any) {
    go()
  }
  
}


// *******************
// MARK: - Lifecycle -
// *******************

extension MainViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // -- init Layout --

    btnGoBack.isEnabled = false
    btnGoFoward.isEnabled = false
    
    myTextField.autocorrectionType = .no
    myTextField.clearsOnBeginEditing = true
    myTextField.returnKeyType = .go

    // -- init Data --
    myTextField.text = defaultWebsiteUrl
    go()
    
    // -- init Delegate --
    
    myTextField.delegate = self
    myWebView.navigationDelegate = self
    
  }
  
}


// *******************
// MARK: - Functions -
// *******************

extension MainViewController {

  // MARK: -- Public Functions --

  // MARK: -- Internal Functions --

  // MARK: -- Private Functions --
  
  private func go() {
    self.view.endEditing(true)
    
    guard let urlString = myTextField.text, urlString != "" else { return }
    
    var finalString = ""
    if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") { finalString = urlString }
    else if urlString.hasPrefix("www") { finalString = "http://" + urlString }
    else { finalString = "http://www." + urlString }
    
    if !finalString.hasSuffix(".com") { finalString += ".com" }
    
    if let url = URL(string: finalString) {
      myWebView.load(URLRequest(url: url))
    }
  }

}


// *******************
// MARK: - Delegates -
// *******************

extension MainViewController: UITextFieldDelegate {
  
  // MARK: -- UITextFieldDelegate  --
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.go()
    
    return true
  }
  
}

extension MainViewController: WKNavigationDelegate {
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    self.view.makeToast(error.localizedDescription)
    self.myIndicator.stopAnimating()
  }
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    self.myIndicator.startAnimating()
    
    self.btnGoBack.isEnabled = webView.canGoBack
    self.btnGoFoward.isEnabled = webView.canGoForward
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.myIndicator.stopAnimating()
    
    self.myTextField.text = webView.url?.absoluteString ?? ""
    self.btnGoBack.isEnabled = webView.canGoBack
    self.btnGoFoward.isEnabled = webView.canGoForward
  }
  
}
