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

    lazy var w3wLbl: UILabel = {
        let label = PaddingUILabel(withInsets: 8, 8, 8, 8)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.text = "///summer.drag.clever"
        label.backgroundColor = Config.Font.Color.background
        label.textAlignment = .left
        label.font = label.font.withSize(12.0)
        label.sizeToFit()
        return label
    }()
    
    lazy var tableview: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
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
        self.backgroundColor = UIColor.white
        // set up w3wlabel
        self.addSubview(w3wLbl)
        self.w3wLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
        // set up table view
        self.addSubview(tableview)
        self.tableview.snp.makeConstraints { (make) in
            make.top.equalTo(w3wLbl).offset(50)
            make.bottom.right.left.equalToSuperview()
        }
    }
}
