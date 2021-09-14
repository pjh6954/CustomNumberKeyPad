//
//  ViewController.swift
//  CustomNumberKeyPadExample
//
//  Created by Dannian Park on 2021/09/13.
//

import UIKit

import NumberPadFramework

class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var btnChecker: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setView()
    }
    
    
    private func setView() {
        self.textField.delegate = self
        let numberpad = NumberPad(frame: .init(x: 0, y: 0, width: self.view.bounds.width, height: 250))
        numberpad.containerBackgroundColor = .gray
        numberpad.containerTopBottomMargin = 3
        numberpad.containerLeadTrailMargin = 3
        numberpad.elementSpace = 5
        self.textField.inputView = numberpad
        
        self.btnChecker.addTarget(self, action: #selector(actionBtnChecker(_:)), for: .touchUpInside)
        
        let newTempPad = NumberPad(frame: .zero)
        newTempPad.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(newTempPad)
        newTempPad.containerBackgroundColor = .gray
        newTempPad.doneBackgroundColor = .systemBlue
        newTempPad.doneColor = .white
        newTempPad.backSpaceColor = .white
        NSLayoutConstraint.activate([
            .init(item: newTempPad, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: newTempPad, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            .init(item: newTempPad, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
            .init(item: newTempPad, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 400)
        ])
    }
}

// MARK: - Button Actions
extension ViewController {
    @objc private func actionBtnChecker(_ sender: UIButton) {
        NSLog("Checker is clicked : \(self.textField.text ?? "")")
        _ = self.view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAssistantItem.leadingBarButtonGroups.removeAll()
        textField.inputAssistantItem.trailingBarButtonGroups.removeAll()
        if let view = textField.inputView as? NumberPad {
            if view.containerLeadTrailMargin == 3 {
                view.containerLeadTrailMargin = 10
            } else {
                view.containerLeadTrailMargin = 3
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

