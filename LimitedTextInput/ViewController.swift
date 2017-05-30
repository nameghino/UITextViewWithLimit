//
//  ViewController.swift
//  LimitedTextInput
//
//  Created by Nico Ameghino on 5/29/17.
//  Copyright © 2017 Nicolas Ameghino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var textView: UITextView!
    private var breakButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange

        let tv = UITextViewWithLimit()
        tv.textColor = .white
        tv.backgroundColor = .red
        view.addSubview(tv)
        tv.frame = CGRect(x: 10, y: 32, width: 200, height: 200)
        tv.limit = 1000
        
        tv.set(delegate: self)

        tv.labelConfigurator = { label, count in
            label.layer.cornerRadius = 2.0
            label.layer.masksToBounds = true
            label.backgroundColor = .white
            label.textColor = .red
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 14.0)
            label.text = "\(count)/\(tv.limit)"
            let ratio = CGFloat(count) / CGFloat(tv.limit)
            label.alpha = ratio

        }

        self.textView = tv

        let b = UIButton(type: .roundedRect)
        b.setTitle("break!", for: .normal)
        b.addTarget(self, action: #selector(`break`(sender:)), for: .primaryActionTriggered)
        view.addSubview(b)
        b.frame = CGRect(x: 10, y: 450, width: 200, height: 44)
        breakButton = b
    }

    func `break`(sender: UIControl) {
        NSLog("whoo!!!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITextViewWithLimitDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        NSLog("forwarding works!")
    }

    func textViewLimitReached(_ textView: UITextViewWithLimit) {
        NSLog("boo! limit reached!")
    }
}

