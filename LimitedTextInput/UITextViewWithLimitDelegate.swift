//
//  UITextViewWithLimitDelegate.swift
//  LimitedTextInput
//
//  Created by Nico Ameghino on 5/30/17.
//  Copyright © 2017 Nicolas Ameghino. All rights reserved.
//

import Foundation
import UIKit

@objc protocol UITextViewWithLimitDelegate: UITextViewDelegate {
    @objc optional func textViewLimitReached(_ textView: UITextViewWithLimit)
}
