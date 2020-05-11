//
//  W3wSuggestionDataSource.swift
//  ObjectDetection
//
//  Created by Lshiva on 05/05/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit
import SnapKit
import what3words

public struct flag {
    static let rows         = 16
    static let cols         = 16
    static let width        = 64
    static let height       = 48
}

protocol W3wSuggestionProtocol: class {
    func currentSelected(_ indexPath: IndexPath)
}

class W3wSuggestionDataSource : UIView {

    var delegate: W3wSuggestionProtocol?

    var viewModel : CameraViewModel?

    fileprivate weak var tableview : UITableView?
    
    fileprivate var threeWordAddress : String?
    
    let countries = ["ad", "ae", "af", "ag", "ai", "al", "am", "ao", "aq", "ar", "as", "at", "au", "aw", "ax", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bl", "bm", "bn", "bo", "bq", "br", "bs", "bt", "bv", "bw", "by", "bz", "ca", "cc", "cd", "cf", "cg", "ch", "ci", "ck", "cl", "cm", "cn", "co", "cr", "cu", "cv", "cw", "cx", "cy", "cz", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "eh", "er", "es", "et", "eu", "fi", "fj", "fk", "fm", "fo", "fr", "ga", "gb-eng", "gb-nir", "gb-sct", "gb-wls", "gb", "gd", "ge", "gf", "gg", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gs", "gt", "gu", "gw", "gy", "hk", "hm", "hn", "hr", "ht", "hu", "id", "ie", "il", "im", "in", "io", "iq", "ir", "is", "it", "je", "jm", "jo", "jp", "ke", "kg", "kh", "ki", "km", "kn", "kp", "kr", "kw", "ky", "kz", "la", "lb", "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv", "ly", "ma", "mc", "md", "me", "mf", "mg", "mh", "mk", "ml", "mm", "mn", "mo", "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "nc", "ne", "nf", "ng", "ni", "nl", "no", "np", "nr", "nu", "nz", "om", "pa", "pe", "pf", "pg", "ph", "pk", "pl", "pm", "pn", "pr", "ps", "pt", "pw", "py", "qa", "re", "ro", "rs", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sj", "sk", "sl", "sm", "sn", "so", "sr", "ss", "st", "sv", "sx", "sy", "sz", "tc", "td", "tf", "tg", "th", "tj", "tk", "tl", "tm", "tn", "to", "tr", "tt", "tv", "tw", "tz", "ua", "ug", "um", "un", "us", "uy", "uz", "va", "vc", "ve", "vg", "vi", "vn", "vu", "wf", "ws", "ye", "yt", "za", "zm", "zw", "zz"]

    init(tableview: UITableView) {
        super.init(frame: CGRect.zero)
        self.tableview = tableview
        viewModel = CameraViewModel(config: OCRManager.sharedInstance)
        viewModel?.suggestions(threeWordAddress: "test.test.test")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadSampleData() {
//        let a1 : W3wSuggestion = W3wSuggestion.init(threeWordAddress: "index.home.raft", languageCode: "en", distanceToFocus: 0, countryCode: "GB", nearestPlace: "234 staines road hounslow")
//        let a2 : W3wSuggestion = W3wSuggestion.init(threeWordAddress: "daring.lion.race", languageCode: "en", distanceToFocus: 0, countryCode: "GB", nearestPlace: "234 staines road hounslow")
//        let a3 : W3wSuggestion = W3wSuggestion.init(threeWordAddress: "daring.lion.race", languageCode: "en", distanceToFocus: 0, countryCode: "GB", nearestPlace: "234 staines road hounslow")
//        items.append(a1)
//        items.append(a2)
//        items.append(a3)
    }
}

extension W3wSuggestionDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel?.suggestion.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:W3wSuggestionTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "Cell") as! W3wSuggestionTableViewCell?)!
        cell.layer.borderColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        cell.layer.borderWidth = 0.5
        let attributedString = NSMutableAttributedString(string: "///\(viewModel?.suggestion[indexPath.row].threeWordAddress ?? "")")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
        let country_index = countries.firstIndex(of: (viewModel?.suggestion[indexPath.row].countryCode!.lowercased())!)
        cell.three_word_address.attributedText = attributedString
        cell.nearest_place.text = viewModel?.suggestion[indexPath.row].nearestPlace
        cell.country_flag.image = self.countryFlagCrop(countryIndex: country_index!)
        return cell
    }
    
    // Crop country flag
    func countryFlagCrop(countryIndex: Int) -> UIImage {
        let row = countryIndex % flag.cols
        let col = countryIndex / flag.rows
        let x = row * flag.width
        let y = col * flag.height
        let clearImage = UIImage(named: "flags")
        let croppedImage = UIImage(cgImage: (clearImage?.cgImage?.cropping(to: CGRect(x: x, y: y, width: flag.width, height: flag.height)))!)
        return croppedImage
    }
}

extension W3wSuggestionDataSource: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.currentSelected(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / CGFloat(3.0)
    }
}

