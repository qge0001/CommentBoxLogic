//
//  ViewController.swift
//  CommentBoxLogic
//
//  Created by Chuckie Zhang on 2019/7/29.
//  Copyright © 2019 Chuckie. All rights reserved.
//

import UIKit

let cellId = "UITableViewCell"

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentInputView: UITextField!
    
    lazy var maskButton:UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        self.view.addSubview(button)
        button.frame = self.view.bounds
        button .addTarget(self, action: #selector(ViewController.hideKeyboard), for: .touchUpInside)
        return button
    }()
    
    var numOfCell = 10
    
    var targetViewBottom = CGFloat.leastNormalMagnitude
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupRightItem()
        self.addNotification()
        self.setupCommentInputView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 30 - self.getSafeAreaBottom())
        self.commentInputView.frame = CGRect(x: 0, y: self.view.bounds.size.height - self.getSafeAreaBottom() - 30, width: self.view.bounds.size.width, height: 30)
    }
    
    func setupTableView() {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellId);
    }
    
    func setupRightItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "setNumOfLines", style: .plain, target: self, action: #selector(ViewController.setNumOfLines))
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupCommentInputView() {
        self.commentInputView.delegate = self
    }
    
    @objc func keyBoardWillShow(_ notificaion:Notification) {
        self.maskButton.isHidden = false
        let keyboardHeight = (notificaion.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
        let duration = notificaion.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let option = UIView.AnimationOptions(rawValue: notificaion.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
        UIView.animate(withDuration: duration, delay: 0.0, options: option, animations: {
            var rect = self.commentInputView.frame
            rect.origin.y = self.view.bounds.size.height - keyboardHeight - rect.size.height
            self.commentInputView.frame = rect
            if(self.targetViewBottom != CGFloat.leastNormalMagnitude) {
                self.tableView.setContentOffset(CGPoint(x: 0, y: max(-self.getScrollViewInsetTop(),self.targetViewBottom - self.tableView.bounds.size.height + keyboardHeight - self.getSafeAreaBottom())), animated: true)
            }
        }, completion:nil)

    }
    
    @objc func keyBoardWillHide(_ notificaion:Notification) {
        self.maskButton.isHidden = true
        let duration = notificaion.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let option = UIView.AnimationOptions(rawValue: notificaion.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt)
        UIView.animate(withDuration: duration, delay: 0.0, options: option, animations: {
            var rect = self.commentInputView.frame
            rect.origin.y = self.view.bounds.size.height - self.getSafeAreaBottom() - 30
            self.commentInputView.frame = rect
            
            self.tableView.setContentOffset(CGPoint(x: 0, y: min(max( self.tableView.contentSize.height - self.tableView.frame.size.height,-self.getScrollViewInsetTop()) ,self.tableView.contentOffset.y)), animated: true)
        }, completion: { (finished) in
            if(finished) {
                self.targetViewBottom = CGFloat.leastNormalMagnitude
            }
        })
    }
    
    @objc func hideKeyboard() {
        self.commentInputView.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(self.targetViewBottom == CGFloat.leastNormalMagnitude) {
            self.targetViewBottom =  min(self.tableView.contentOffset.y + self.tableView.bounds.size.height,self.tableView.contentSize.height)
        }
        return true
    }
    
    func getScrollViewInsetTop()->CGFloat {
        if #available(iOS 11.0, *) {
            return self.tableView.adjustedContentInset.top + self.tableView.contentInset.top
        } else {
            return self.tableView.contentInset.top
        }
    }
    
    func getSafeAreaBottom()->CGFloat {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    @objc func setNumOfLines() {
        let alert = UIAlertController(title: "Choose line...", message: nil, preferredStyle: .alert)
        alert.addTextField {[weak self] (textField) in
            if let self = self {
                textField.placeholder = "\(self.numOfCell)"
                textField.keyboardType = .numberPad
            }
        }
        let action = UIAlertAction(title: "OK", style: .default) {[weak self] (action)  in
            if let self = self {
                if let numOfCell = Int((alert.textFields?.first?.text)!) {
                    self.numOfCell = numOfCell
                    self.tableView.reloadData()
                }
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.backgroundColor = UIColor.red
        cell.textLabel?.text = "\(indexPath.row)"
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView .cellForRow(at: indexPath)
        self.targetViewBottom = cell!.frame.origin.y + cell!.frame.size.height
        self.commentInputView.becomeFirstResponder()
    }

}

