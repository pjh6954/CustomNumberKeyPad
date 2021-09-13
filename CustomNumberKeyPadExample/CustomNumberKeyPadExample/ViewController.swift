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
        self.textField.inputView = numberpad
        
        self.btnChecker.addTarget(self, action: #selector(actionBtnChecker(_:)), for: .touchUpInside)
    }
}

// MARK: - Button Actions
extension ViewController {
    @objc private func actionBtnChecker(_ sender: UIButton) {
        NSLog("Checker is clicked : \(self.textField.text ?? "")")
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAssistantItem.leadingBarButtonGroups.removeAll()
        textField.inputAssistantItem.trailingBarButtonGroups.removeAll()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

