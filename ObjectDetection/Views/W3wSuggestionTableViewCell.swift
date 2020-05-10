//
//  W3wSuggestionTableViewCell.swift
//  ObjectDetection
//
//  Created by Lshiva on 05/05/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit

class W3wSuggestionTableViewCell: UITableViewCell {

    //DropDowncell view
    let containerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    // W3wSuggestion -words
    let three_word_address : UILabel = {
        let label = PaddingUILabel(withInsets: 8.0, 8.0, 16.0, 8.0)
        label.textColor = Config.Font.Color.text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.init(name: Config.Font.type.sourceLight, size: 22.0)
        return label
        
    }()
    // W3wSuggestion -nearest_place
    let nearest_place : UILabel = {
        let label = UILabel()
        label.textColor = Config.Font.Color.textGrayColor
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont .systemFont(ofSize: 12)
        return label

    }()
    // W3wSuggestion -country
    let country_flag : UIImageView = {
        let flag = UIImageView()
        flag.translatesAutoresizingMaskIntoConstraints = false
        flag.clipsToBounds = true
        return flag
    }()
    
    var label : UILabel!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        self.containerView.addSubview(three_word_address)
        self.containerView.addSubview(country_flag)
        self.containerView.addSubview(nearest_place)
        self.contentView.addSubview(containerView)

        // set up container view
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo:self.contentView.heightAnchor).isActive = true
        
        // set up three word address
        three_word_address.topAnchor.constraint(equalTo:self.containerView.topAnchor, constant: self.frame.height / 8.0 ).isActive = true
        three_word_address.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        three_word_address.widthAnchor.constraint(equalTo: self.containerView.widthAnchor).isActive = true
        three_word_address.heightAnchor.constraint(equalTo: self.containerView.heightAnchor, multiplier: 0.5 ).isActive = true
        three_word_address.sizeToFit()
        
        // set up nearest place
        nearest_place.topAnchor.constraint(equalTo:self.three_word_address.bottomAnchor, constant: self.frame.height / 8.0 ).isActive = true
        nearest_place.leadingAnchor.constraint(equalTo:self.country_flag.trailingAnchor, constant: 5.0).isActive = true
        nearest_place.sizeToFit()
        
        // set up country flag
        country_flag.leadingAnchor.constraint(equalTo:self.three_word_address.leadingAnchor, constant: 16.0).isActive = true
        country_flag.centerYAnchor.constraint(equalTo: self.nearest_place.centerYAnchor).isActive = true
        country_flag.widthAnchor.constraint(equalToConstant:self.frame.height / 2.0 ).isActive = true
        country_flag.heightAnchor.constraint(equalToConstant: self.frame.height / 2.0 / 1.3).isActive = true
    }
    
}
