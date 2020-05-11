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
    
    public var threeWordAddress : String? {
        didSet {
            viewModel = CameraViewModel(config: OCRManager.sharedInstance)
            viewModel!.suggestions(threeWordAddress: threeWordAddress!)
        }
    }

    init(tableview: UITableView) {
        super.init(frame: CGRect.zero)
        self.tableview = tableview
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension W3wSuggestionDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.suggestion.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:W3wSuggestionTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "Cell") as! W3wSuggestionTableViewCell?)!
        cell.layer.borderColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        cell.layer.borderWidth = 0.5
        let attributedString = NSMutableAttributedString(string: "///\(viewModel!.suggestion[indexPath.row].threeWordAddress!)")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 3))
        let country_index = Config.w3w.countries.firstIndex(of: (viewModel!.suggestion[indexPath.row].countryCode!.lowercased()))
        cell.three_word_address.attributedText = attributedString
        cell.nearest_place.text = viewModel!.suggestion[indexPath.row].nearestPlace
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

