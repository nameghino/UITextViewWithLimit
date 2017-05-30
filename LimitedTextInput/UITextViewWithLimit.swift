//
//  UITextViewWithLimit.swift
//  LimitedTextInput
//
//  Created by Nico Ameghino on 5/30/17.
//  Copyright © 2017 Nicolas Ameghino. All rights reserved.
//

import Foundation
import UIKit

@objc class UITextViewWithLimit: UITextView {
    var limit: Int = Int.max

    /// Receives the count label and the current text count as parameters
    var labelConfigurator: ((UILabel, Int) -> Void)? = nil

    private var limitLabelToSuperviewHorizontalSpacingConstraint: NSLayoutConstraint!
    private var limitLabelToSuperviewVerticalSpacingConstraint: NSLayoutConstraint!

    var limitLabelSpacing: CGSize = CGSize(width: 4.0, height: 4.0)

    private let limitLabel: UILabel = UILabel()
    private var interceptor: UITextViewWithLimitForwardingDelegate? = nil

    /// Use this method instead of assigning directly to the delegate property
    /// This method wraps the delegate you set into the one required for the component
    func set(delegate: UITextViewWithLimitDelegate) {
        self.interceptor = UITextViewWithLimitForwardingDelegate(with: delegate)
        self.delegate = interceptor
    }

    fileprivate func updateLimitLabel(count: Int) {
        labelConfigurator?(limitLabel, count)
        setNeedsLayout()
    }

    private func setup() {
        addSubview(limitLabel)
    }

    override func awakeFromNib() {
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        limitLabel.sizeToFit()

        let newBounds = CGRect(x: 0, y: 0, width: limitLabel.bounds.width * 1.1, height: limitLabel.bounds.height * 1.05)
        limitLabel.bounds = newBounds

        limitLabel.frame.origin.x = contentOffset.x + bounds.width - limitLabel.bounds.width - limitLabelSpacing.width
        limitLabel.frame.origin.y = contentOffset.y + bounds.height - limitLabel.bounds.height - limitLabelSpacing.height

        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: limitLabel.bounds.height + limitLabelSpacing.height, right: 0)
    }
}

@objc private class UITextViewWithLimitForwardingDelegate: NSObject, UITextViewWithLimitDelegate {
    private var forwardingTarget: UITextViewWithLimitDelegate!

    init(with forwardingTarget: UITextViewWithLimitDelegate) {
        self.forwardingTarget = forwardingTarget
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return forwardingTarget.textViewShouldBeginEditing?(textView) ?? true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return forwardingTarget.textViewShouldEndEditing?(textView) ?? true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        forwardingTarget.textViewDidBeginEditing?(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        forwardingTarget.textViewDidEndEditing?(textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        forwardingTarget.textViewDidChange?(textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        forwardingTarget.textViewDidChangeSelection?(textView)
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return forwardingTarget.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }

    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return forwardingTarget.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textView = textView as? UITextViewWithLimit else {
            fatalError("This delegate should not be used with a non-TextViewWithLimit text view subclass")
        }
        let nextCharacterCount = textView.text.characters.count + (text.characters.count - range.length)
        textView.updateLimitLabel(count: nextCharacterCount)

        let characterCountIsUnderLimit = nextCharacterCount <= textView.limit
        if !characterCountIsUnderLimit {
            forwardingTarget.textViewLimitReached?(textView)
            textView.updateLimitLabel(count: textView.limit)
        } else {
            textView.updateLimitLabel(count: nextCharacterCount)
        }

        let r = forwardingTarget.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        
        return characterCountIsUnderLimit && r
    }
}

