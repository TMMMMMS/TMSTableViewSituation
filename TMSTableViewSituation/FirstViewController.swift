//
//  FirstViewController.swift
//  TMSTableViewSituation
//
//  Created by TMS on 2020/3/23.
//  Copyright © 2020 TMS. All rights reserved.
//

import UIKit
import SnapKit

let OYMultipleTableSource1 = "OYMultipleTableSource1"
let OYMultipleTableSource2 = "OYMultipleTableSource2"

let countdownSecond = 10

class FirstViewController: UIViewController {

    private var tableView : UITableView!
    private var dataSource : Array<FirstModel> = []
    private var detailVC : SecondViewController?
    
    private var timer1 : DispatchSourceTimer?
    private var timer2 : DispatchSourceTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        handleDatas()
        configViews()

        // 启动倒计时管理
        OYCountDownManager.sharedManager.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detailVC = nil
    }
    
    @objc private func logoutAction() {
        
        if timer1 != nil {
            timer1!.cancel()
        }
        if timer2 != nil {
            timer2!.cancel()
        }
        
        let keyWindow = UIApplication.shared.windows[1]
        
        keyWindow.rootViewController = LoginViewController()
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
}

extension FirstViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FirstTableViewCell
        
        cell.delegate = self
        
        cell.setupCell(model: dataSource[indexPath.row])
        
        // 如果详情页是数据驱动的，假如当前窗口展示的是详情页，不会触发此方法刷新详情页数据
//        if detailVC != nil {
//            detailVC!.updateVc(model: dataSource[indexPath.row])
//        }
        
        return cell
    }
}

extension FirstViewController : FirstTableViewCellDelegate {
    
    func countdownEnd(model: FirstModel) {
        
        var existIndex = -1
        if self.dataSource.count > 0 {
            
            for index in 0..<self.dataSource.count {
                let itemModel = self.dataSource[index]
                if itemModel.identifier == model.identifier {
                    existIndex = index
                    break;
                }
            }
        }
        
        if existIndex >= 0 {
            
            let itemModel = self.dataSource[existIndex]
            if itemModel.countdownFinished {
                return
            }
            itemModel.countdownFinished = true
            
            self.dataSource[existIndex] = model
            tableView.reloadData()
        }
     
        countdownStart(identifier: model.identifier)
    }
}

extension FirstViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SecondViewController.init()
        vc.model = dataSource[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
        detailVC = vc
    }
}

// MARK: - Private
extension FirstViewController {
    
    func countdownStart(identifier:String) {
        
        print(String(format: "%@开启倒计时,%zds后模拟请求接口刷新倒计时时间", identifier, countdownSecond))
        
        weak var WeakSelf = self
        
        var timeout = countdownSecond
        let queue = DispatchQueue.global()
        let timer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: queue)
        timer.schedule(deadline: .now(), repeating:  .milliseconds(1000))
        timer.setEventHandler {
            timeout = timeout - 1
            if timeout < 0 {
                DispatchQueue.main.async {
                    
                    var existIndex = -1
                    if WeakSelf!.dataSource.count > 0 {
                        
                        for index in 0..<WeakSelf!.dataSource.count {
                            let model = WeakSelf!.dataSource[index]
                            if model.identifier == identifier {
                                existIndex = index
                                break;
                            }
                        }
                    }
                    
                    if existIndex >= 0 {
                        let model = self.dataSource[existIndex]
                        model.interVal = Int(arc4random() % 100)
                        model.countdownFinished = false
                        
                        
                        if WeakSelf!.detailVC != nil {
                            WeakSelf!.detailVC?.updateVc(model: model)
                        }
                    }
                    
                    OYCountDownManager.sharedManager.reloadSourceWithIdentifier(identifier: identifier)
                    
                    WeakSelf?.tableView.reloadData()
                    
                }
                if identifier == OYMultipleTableSource1 {
                    WeakSelf?.timer1!.cancel()
                } else {
                    WeakSelf?.timer2!.cancel()
                }
            }
        }
        if #available(iOS 10.0, *) {
            timer.activate()
        } else {
            timer.resume()
        }
        if identifier == OYMultipleTableSource1 {
            timer1 = timer
        } else {
            timer2 = timer
        }
    }
}

extension FirstViewController {
    
    func configViews() {
        
        var statusBarHeight : CGFloat = 0
        if #available(iOS 13.0, *) {
            statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        }
        
        tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(FirstTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(statusBarHeight)
        }
        
        let item=UIBarButtonItem(title: "登出", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutAction))
        self.navigationItem.rightBarButtonItem = item
        
    }
    
    func handleDatas() {
        
        for index in 0..<2 {
            
            let model = FirstModel.init()
            model.identifier = index == 0 ? OYMultipleTableSource1 : OYMultipleTableSource2
            model.interVal = Int(arc4random() % 100)
            model.countdownFinished = false
            dataSource.append(model)
            
            OYCountDownManager.sharedManager.addSourceWithIdentifier(identifier: model.identifier)
        }
    }
    
}
