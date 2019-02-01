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
  
  private let KEY__LAST_WEBSITE       = "KEY__LAST_WEBSITE"
  
  private let defaultActionBarHeight  : CGFloat = 94.0
  
  
  // MARK: -- Public Properties --
  
  // MARK: -- Internal Properties --
  
  // MARK: -- Private Properties --
  
  private var lastBrowsingWebsiteURL : URL? {
    get {
      return UserDefaults.standard.url(forKey: KEY__LAST_WEBSITE)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: KEY__LAST_WEBSITE)
    }
  }
  
  
  private var beginDraggingPositionY        : CGFloat?
  
  private var beginDraggingActionBarHeight  : CGFloat?
  
  
  // MARK: -- Enums --
  
  // MARK: -- Init --
  
  // MARK: -- Override --
  
  
  // **********************
  // MARK: - UI & Actions -
  // **********************
  
  // MARK: -- UI --
  
  @IBOutlet weak var myActionBar: UIView!
  
  @IBOutlet weak var myActionBarHeightConstraint: NSLayoutConstraint!
  
  
  @IBOutlet weak var lblWebsiteTitle: UILabel!
  
  @IBOutlet weak var btnGoBack: UIButton!
  
  @IBOutlet weak var btnGoFoward: UIButton!
  
  @IBOutlet weak var myTextField: UITextField!
  
  @IBOutlet weak var myIndicator: UIActivityIndicatorView!
  
  
  @IBOutlet weak var myWebView: WKWebView!
  
  
  @IBOutlet var bigActionBarViews: [UIView]!
  
  @IBOutlet var smallActionBarViews: [UIView]!
  
  
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

    myActionBarHeightConstraint.constant = defaultActionBarHeight
    
    lblWebsiteTitle.text = ""
    lblWebsiteTitle.alpha = 0
    
    btnGoBack.isEnabled = false
    btnGoFoward.isEnabled = false
    
    myTextField.autocorrectionType = .no
    myTextField.clearsOnBeginEditing = true
    myTextField.returnKeyType = .go

    // -- init Data --
    
    go(lastBrowsingWebsiteURL)
    
    // -- init Delegate --
    
    myTextField.delegate = self
    myWebView.navigationDelegate = self
    myWebView.scrollView.delegate = self
    
  }
  
}


// *******************
// MARK: - Functions -
// *******************

extension MainViewController {

  // MARK: -- Public Functions --

  // MARK: -- Internal Functions --

  // MARK: -- Private Functions (Action) --
  
  private func go(_ url: URL? = nil) {
    self.view.endEditing(true)

    // Go with url
    if url != nil {
      myWebView.load(URLRequest(url: url!))
      return
    }
    
    // Go with string
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
  
  // MARK: -- Private Functions (Layout) --
  
  private func updateActionBarHeight(_ height: CGFloat) {
    var newHeight = min(height, defaultActionBarHeight)
    newHeight = max(newHeight, 20)
    myActionBarHeightConstraint.constant = newHeight
    
    let alpha = (newHeight - 20) / (defaultActionBarHeight-20)
    _ = bigActionBarViews.map({ $0.alpha = alpha })
    _ = smallActionBarViews.map({ $0.alpha = 1-alpha })
  }
  
  private func enlargeActionBarWithAnimation() {
    
    UIView.animate(withDuration: 0.25) {
      self.myActionBarHeightConstraint.constant = self.defaultActionBarHeight
      self.view.layoutIfNeeded()
      
      _ = self.bigActionBarViews.map({ $0.alpha = 1 })
      _ = self.smallActionBarViews.map({ $0.alpha = 0 })
    }
  }
  
}


// *******************
// MARK: - Delegates -
// *******************

extension MainViewController: UITextFieldDelegate {
  
  // MARK: -- UITextFieldDelegate --
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.go()
    
    return true
  }
  
}

extension MainViewController: WKNavigationDelegate {

  // MARK: -- WKNavigationDelegate --

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
    
    self.lblWebsiteTitle.text = webView.title ?? ""
    self.myTextField.text = webView.url?.absoluteString ?? ""
    self.btnGoBack.isEnabled = webView.canGoBack
    self.btnGoFoward.isEnabled = webView.canGoForward
    
    lastBrowsingWebsiteURL = webView.url
  }
  
}

extension MainViewController: UIScrollViewDelegate {
  
  // MARK: -- UIScrollViewDelegate --

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let positionY = beginDraggingPositionY, let height = beginDraggingActionBarHeight else { return }
    
    if scrollView.contentOffset.y > positionY {  // Scroll Down
      self.updateActionBarHeight(height - (scrollView.contentOffset.y - positionY))
    
    } else {  // Scroll Up
      let velocity = scrollView.panGestureRecognizer.velocity(in: myWebView)
      if velocity.y > 1000 {
        self.enlargeActionBarWithAnimation()
      }
    }
    
    if (scrollView.contentOffset.y < -20) {  // Bouncing Top
      self.enlargeActionBarWithAnimation()
    
    } else if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height + 20.0)) {  // Bouncing Bottom
      self.enlargeActionBarWithAnimation()
    }
    
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    beginDraggingPositionY = scrollView.contentOffset.y
    beginDraggingActionBarHeight = self.myActionBarHeightConstraint.constant
  }
  
  func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    self.enlargeActionBarWithAnimation()
  }
  
}
