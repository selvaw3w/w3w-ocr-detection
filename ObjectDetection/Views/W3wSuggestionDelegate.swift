//
//  W3wSuggestionDelegate.swift
//  ObjectDetection
//
//  Created by Lshiva on 05/05/2020.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import UIKit

//protocol W3wSuggestionProtocol: class {
//    func currentSelected(_ indexPath: IndexPath)
//}


class W3wSuggestionDelegate: NSObject,UITableViewDelegate{

    //var delegate: W3wSuggestionProtocol?

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //delegate?.currentSelected(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / CGFloat(3.0)
    }
}

