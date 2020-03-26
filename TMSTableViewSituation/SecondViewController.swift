//
//  SecondViewController.swift
//  TMSTableViewSituation
//
//  Created by TMS on 2020/3/23.
//  Copyright © 2020 TMS. All rights reserved.
//

import UIKit
import SnapKit

class SecondViewController: UIViewController {

    var model : FirstModel!
    
    private var countdownLabel : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.cyan

        countdownLabel = UILabel.init()
        countdownLabel!.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(countdownLabel!)
        countdownLabel!.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let timeInterval = OYCountDownManager.sharedManager.timeIntervalWithIdentifier(identifier: self.model!.identifier)
        let countDown = self.model!.interVal - timeInterval
        if countDown <= 0 { // 倒计时结束时回调
            countdownLabel?.text = "开奖中"
        } else {
            countdownLabel?.text = String(format: "%02d:%02d:%02d", countDown/3600, (countDown/60)%60, countDown%60)
        }
                
        NotificationCenter.default.addObserver(self, selector: #selector(self.countDownNotification), name: .OYCountDownNotification, object: nil)
    }
    
    func updateVc(model:FirstModel!) {
        
        if model?.identifier != self.model!.identifier {
            return
        }
        
        print("倒计时结束，详情页刷新:"+self.model.identifier)
        
        self.model = model
        self.countDownNotification()
    }
    
    @objc private func countDownNotification() {
                
        let intervalModel = OYCountDownManager.sharedManager.timeIntervalDict[self.model!.identifier]
        
        if intervalModel == nil {
            return
        }
        
        let timeInterval = OYCountDownManager.sharedManager.timeIntervalWithIdentifier(identifier: self.model!.identifier)

        let countDown = self.model!.interVal - timeInterval
        
//        print(self.model!.identifier+":"+"\(self.model!.interVal)" + "--" + "\(timeInterval)")
        
        if countDown <= 0 { // 倒计时结束时回调
            countdownLabel?.text = "开奖中"
        } else {
            countdownLabel?.text = String(format: "%02d:%02d:%02d", countDown/3600, (countDown/60)%60, countDown%60)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit: \(type(of: self))")
    }
}
