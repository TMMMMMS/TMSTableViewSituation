//
//  LoginViewController.swift
//  TMSTableViewSituation
//
//  Created by TMS on 2020/3/23.
//  Copyright © 2020 TMS. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        let loginBtn = UIButton.init(type: .system)
        loginBtn.setTitle("登录", for: .normal)
        loginBtn.backgroundColor = UIColor.orange
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        loginBtn.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        self.view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 45, height: 30))
        }
    }

    @objc private func loginAction() {
        
        let keyWindow = UIApplication.shared.windows[1]
        
        keyWindow.rootViewController = UINavigationController.init(rootViewController: FirstViewController())
    }

    deinit {
        print("deinit: \(type(of: self))")
    }
}
