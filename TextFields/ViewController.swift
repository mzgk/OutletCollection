//
//  ViewController.swift
//  TextFields
//
//  Created by Mizugaki on 2018/04/11.
//  Copyright © 2018年 edu.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    // outletCollectionを使うことでパーツ処理を減らせるし、配列で処理できる
    @IBOutlet var numberFields: [UITextField]!
    @IBOutlet var waterFields: [UITextField]!
    @IBOutlet var totalLabels: [UILabel]!


    var ActiveField: UITextField?
    var KeyboardFrame: CGRect?
    var Duration: Double = 0.3

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // delegate, Tag付け（Tagは入力された時の識別に必要）
        // numberField.tagは0~
        numberFields.enumerated().forEach {
            $0.element.delegate = self
            $0.element.tag = $0.offset
        }

        // waterField.tagは20~
        waterFields.enumerated().forEach {
            $0.element.delegate = self
            $0.element.tag = $0.offset + 20
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(textField.tag)

        var number: Int = 0
        var water: Double = 0.0
        var total: Double = 0.0
        let text = textField.text! as NSString
        let value = text.replacingCharacters(in: range, with: string)

        // tagがoutletCollection配列のindexと一致する
        var index = textField.tag
        if index < 20 { // -> 20より小さい＝numberField
            number = Int(value) ?? 0
            water = Double(waterFields[index].text!) ?? 0
        } else {
            index -= 20
            number = Int(numberFields[index].text!) ?? 0
            water = Double(value) ?? 0
        }
        total = Double(number) * water
        totalLabels[index].text = String(total)
        return true
    }










// ---------------------------------------------------------------------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        ActiveField = textField
        moveView(shouldUP: true, field: ActiveField, keybord: KeyboardFrame, duration: Duration)
        return true
    }

    @objc
    func keyboardWillShow(_ notification: Notification) {
        // キーボードの高さを取得
        if let keyboard = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            Duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? Double)!
            KeyboardFrame = keyboard
            // 最初のタッチが上にズラす必要のある場所だった場合のために
            moveView(shouldUP: true, field: ActiveField, keybord: KeyboardFrame, duration: Duration)
        }
    }

    @objc
    func keyboardWillHide(_ notification: Notification) {
        Duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? Double)!
        moveView(shouldUP: false, field: ActiveField, keybord: KeyboardFrame, duration: Duration)
    }

    func moveView(shouldUP: Bool, field: UITextField?, keybord: CGRect?, duration: Double) {
        // 元に戻す
        if !shouldUP {
            UIView.animate(withDuration: duration) {
                self.view.transform = CGAffineTransform.identity
            }
            return
        }

        // 早期リターン
        guard let field = field else { return }
        guard let keybord = keybord else { return }

        // アクティブなfieldの座標をself.viewを基準にした座標に変換する（変換しない場合は親ViewであるUIStackViewが基準になるので）
        let fieldFrame = field.convert(field.frame, to: self.view)
        if fieldFrame.minY + 40 > keybord.minY {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: -(keybord.size.height))
                self.view.transform = transform
            }
        }
    }
}

