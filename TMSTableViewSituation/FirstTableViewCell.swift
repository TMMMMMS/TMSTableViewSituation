//
//  FirstTableViewCell.swift
//  TMSTableViewSituation
//
//  Created by TMS on 2020/3/23.
//  Copyright © 2020 TMS. All rights reserved.
//

import UIKit
import SnapKit

class FirstModel: NSObject {
    var interVal : Int = 0
    var identifier : String!
    var countdownFinished : Bool = false
}

protocol FirstTableViewCellDelegate : NSObjectProtocol {
    func countdownEnd(model:FirstModel)
}

class FirstTableViewCell: UITableViewCell {
    
    var countdownLabel : UILabel!
    weak var delegate : FirstTableViewCellDelegate? = nil
    private var model : FirstModel? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.countDownNotification), name: .OYCountDownNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func refreshModel(notification:Notification) {
        
        let userInfo = notification.userInfo
        
        let model = userInfo!["model"] as! FirstModel
        
        if model.identifier == self.model?.identifier {
            setupCell(model: model)
        }
    }
    
    func setupCell(model : FirstModel) {
        
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
        if countDown <= 0 { // 倒计时结束时回调
            
            countdownLabel.text = "开奖中"
            
            if self.delegate != nil {
                self.delegate?.countdownEnd(model: self.model!)
            }
        } else {
            countdownLabel.text = String(format: "%02d:%02d:%02d", countDown/3600, (countDown/60)%60, countDown%60)
        }
    }
    
    private func configViews() {
        
        countdownLabel = UILabel.init()
        countdownLabel.text = "开奖中"
        countdownLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(countdownLabel)
        countdownLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        let label = UILabel.init()
        label.text = "点击进入详情页"
        label.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
