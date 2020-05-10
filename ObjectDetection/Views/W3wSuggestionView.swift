//
//  W3wSuggestionView.swift
//  ObjectDetection
//
//  Created by Lshiva on 05/05/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit
import SnapKit

class W3wSuggestionView: UIView {

    fileprivate var tableViewdataSource : W3wSuggestionDataSource!
    
    internal lazy var closebtn : UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        button.contentMode = .center
        button.tintColor = UIColor.black
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    internal lazy var w3wLbl: UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.white
        label.textAlignment = .left
        label.font = UIFont.init(name: Config.Font.type.sourceSanRegular, size: 22.0)
        label.textColor  = Config.Font.Color.text
        label.sizeToFit()
        return label
    }()
    
    internal lazy var tableview: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
        return tableView
    }()
        
    init() {
        super.init(frame: CGRect.zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        self.backgroundColor = Config.Font.Color.backgroundLight
        self.tableview.backgroundColor = UIColor.red
        // set up w3wlabel
        self.addSubview(w3wLbl)
        self.w3wLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        
        //add close btn
        self.addSubview(closebtn)
        self.bringSubviewToFront(closebtn)
        self.closebtn.addTarget(self, action: #selector(self.closeView), for: .touchUpInside)
        self.closebtn.snp.makeConstraints { (make) in
            //make.top.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(self.w3wLbl.snp.centerY)
            make.width.equalTo(14)
            make.height.equalTo(16)
        }
        let attributedString = NSMutableAttributedString(string: "///index.home.raft")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
        w3wLbl.attributedText = attributedString
        
        // set up table view
        tableViewdataSource = W3wSuggestionDataSource(tableview: tableview)
        self.tableview.dataSource = tableViewdataSource
        self.tableview.delegate = tableViewdataSource
        self.tableview.register(W3wSuggestionTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableview)
        self.tableview.snp.makeConstraints { (make) in
            make.top.equalTo(self.w3wLbl.snp.bottom).offset(5)
            make.right.left.equalToSuperview()
            make.bottom.equalTo(self).offset(-30)
        }
    }
    
    @objc func closeView() {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.alpha = 0
            self.layoutIfNeeded()
            self.removeFromSuperview()
        }, completion: nil)
    }
}
