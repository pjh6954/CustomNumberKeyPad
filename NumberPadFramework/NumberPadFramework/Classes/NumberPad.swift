//
//  NumberPad.swift
//  NumberPadFramework
//
//  Created by Dannian Park on 2021/09/13.
//

import UIKit

public protocol NumberPadDelegate: AnyObject {
    
}
public enum NoneStringCases {
    // Img
    case Backspace
    // Attr Str. special type
    case Done
    // Img
    case Hide
    // custom imgae
    case Others(img: UIImage)
}
public enum ButtonsCases {
    case StringType(String)
    case NoneStringType(NoneStringCases)
    case EmptyView
}

public enum NumberPadType {
    case defaultType
}
// TODO: TODO: Designable을 추가하여 Xib나 Storyboard에서 사용할 때도 Preview가능하도록 할 예정
/// 외부에서 호출 가능하도록 Public. 다만 서브클래싱이나 오버라이드는 못 하도록 하기 위해 Open이 아니다.
/// XIB 또는 Storyboard없이 구현된 상태.
public class NumberPad: UIView {
    public weak var delegate : NumberPadDelegate?
    /// 기초가 되는 백그라운드 컨테이너
    private let containerStackView: UIStackView = {
        let stv = UIStackView()
        stv.translatesAutoresizingMaskIntoConstraints = false
        stv.axis = .horizontal
        return stv
    }()
    
    private var containerLeadingEqualSuperView : NSLayoutConstraint?
    
    /// center container
    private let containerPad: UIStackView = {
        let stv = UIStackView()
        stv.translatesAutoresizingMaskIntoConstraints = false
        stv.axis = .vertical
        return stv
    }()
    
    /// side button container
    private let containerSide: UIStackView = {
        let stv = UIStackView()
        stv.translatesAutoresizingMaskIntoConstraints = false
        stv.axis = .vertical
        return stv
    }()
    
    private var padAndSideConstraint : NSLayoutConstraint?
    
    private let defaultButtonsStr: [ButtonsCases] = [.StringType("1"), .StringType("2"), .StringType("3"), .StringType("4"), .StringType("5"), .StringType("6"), .StringType("7"), .StringType("8"), .StringType("9"), .NoneStringType(.Hide), .StringType("0"), .StringType(".")]
    
    private let defaultSideBtnStr: [ButtonsCases] = [.NoneStringType(.Backspace), .NoneStringType(.Done)]
    /// 각 버튼들의 최소 width 값. 0은 최소값이 없게 되는 상태이기 때문에 꽉 채워서 나오도록 구현
    public var minBtnWidth: CGFloat = 50 // default
    
    /// 각 라인에 들어갈 갯수를 정한다. Default type에서는 변경 안됨
    public var linePerElement : Int = 3 { didSet { if self.displayType != .defaultType { self.updateElementsSetting() } else {  } } }
    /// 키패드에 넣고자 하는 버튼들의 종류와 그 태그 값을 KeyValue로 사용한다. Value가 Nil인 경우에는 StringType은 해당 String을, 그 외(NoneStringType)은 NoneStrongCases로 반환을 한다. Default type에서는 변경 안됨
    public var lineElements: [(ButtonsCases, Int?)] = [] { didSet { if self.displayType != .defaultType { self.updateElementsSetting() } } }
    /// 측면에 넣으려는 element의 종류와 그 태그 값을 Key Value로 하여 사용한다. Default type에서는 변경 안됨
    public var sideElements: [(ButtonsCases, Int)] = [] { didSet { if self.displayType != .defaultType { self.updateElementsSetting() } } }
    
    /// 보여지는 타입 현재는 default만 존재.
    public var displayType: NumberPadType = .defaultType { didSet { self.updateElementsSetting() } }
    
    /// 각 element간의 간격
    public var elementSpace : CGFloat = 2 { didSet { self.updateElementsSetting() } }
    
    /// contain 하는 uiview의 백그라운드 컬러
    public var containerBackgroundColor : UIColor = .white { didSet { self.updateElementsSetting() } }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        // 여기서 element update를 해주는 이유는 suspended상태에 들어갔다 돌아오는 경우 draw가 다시 호출되는데, 이 때 상태가 바뀌어 있을 수 있다는 가정 하에 다시 제약조건을 그려주기 위해서 선언.
        self.updateElementsConstraintSetting()
    }
    
    deinit {
        NSLog("Deinit in Number Pad")
    }
    
    private func setupView() {
        // 기본 셋업
        self.addSubview(self.containerStackView)
        NSLayoutConstraint.activate([
            .init(item: self.containerStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            .init(item: self.containerStackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: self.containerStackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            .init(item: self.containerStackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        self.containerStackView.backgroundColor = .green
        
        self.containerStackView.addArrangedSubview(self.containerPad)
        self.containerStackView.addArrangedSubview(self.containerSide)
        
        self.containerPad.backgroundColor = .blue
        self.containerSide.backgroundColor = .red
        
        self.padAndSideConstraint = .init(item: self.containerPad, attribute: .width, relatedBy: .equal, toItem: self.containerSide, attribute: .width, multiplier: 3, constant: 0)
        NSLayoutConstraint.activate([
            self.padAndSideConstraint!
        ])
        
        self.updateElementsSetting()
    }
    
    private func updateElementsSetting() {
        // 각 element의 추가 및 제거 등의 동작 수행
        /*
        if padAndSideConstraint != nil {
            self.padAndSideConstraint?.isActive = false
            self.padAndSideConstraint = nil
        }
        */
        self.containerPad.arrangedSubviews.forEach { element in
            element.removeFromSuperview()
        }
        self.containerSide.arrangedSubviews.forEach { element in
            element.removeFromSuperview()
        }
        
        self.containerStackView.spacing = self.elementSpace
        self.containerPad.spacing = self.elementSpace
        self.containerPad.distribution = .fillEqually
        self.containerSide.spacing = self.elementSpace
        self.containerSide.distribution = .fillEqually
        
        for (index, element) in  self.defaultButtonsStr.enumerated() {
            if index % 3 == 0 {
                let stackview = UIStackView()
                stackview.translatesAutoresizingMaskIntoConstraints = false
                stackview.axis = .horizontal
                stackview.distribution = .fillEqually
                stackview.spacing = self.elementSpace
                self.containerPad.addArrangedSubview(stackview)
            }
            guard let stv = self.containerPad.arrangedSubviews.last as? UIStackView else {
                
                break
            }
            let view = self.createView(element, tag: index)
            stv.addArrangedSubview(view)
        }
        
        // self.containerStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        
        /*
        if self.displayType == .defaultType {
            self.containerStackView.addArrangedSubview(self.containerPad)
            self.containerStackView.addArrangedSubview(self.containerSide)
        } else {
            // ?
        }
        */
        self.updateElementsConstraintSetting()
    }
    
    private func updateElementsConstraintSetting() {
        /*
        if self.displayType == .defaultType {
            self.containerStackView.spacing = self.elementSpace
            self.containerPad.spacing = self.elementSpace
            self.containerSide.spacing = self.elementSpace
            
            self.containerPad.backgroundColor = .blue
            self.containerSide.backgroundColor = .blue
            
            self.containerLeadingEqualSuperView?.isActive = true
            self.padAndSideConstraint = .init(item: self.containerPad, attribute: .width, relatedBy: .equal, toItem: self.containerSide, attribute: .width, multiplier: 3, constant: 0)
            NSLayoutConstraint.activate([
                self.padAndSideConstraint!
            ])
            
            
        } else {
            self.containerLeadingEqualSuperView?.isActive = false
        }
        */
    }
    
    private func createView(_ btnCase: ButtonsCases, tag: Int?) -> UIView {
        let uiview = UIView()
        uiview.translatesAutoresizingMaskIntoConstraints = false
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        switch btnCase {
        case .StringType(let str):
            btn.setTitle(str, for: .normal)
            btn.addTarget(self, action: #selector(self.actionBtnStr(_:)), for: .touchUpInside)
            btn.setTitleColor(.green, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            btn.tag = tag ?? -1
            break
        case .NoneStringType(let notTypeCase):
            switch notTypeCase {
            case .Backspace:
                btn.setImage(.init(named: "ClearSymbolIcon"), for: .normal)
                break
            case .Done:
                btn.setTitle("DONE", for: .normal)
                break
            case .Hide:
                btn.setImage(.init(named: "ClearSymbolIcon"), for: .normal)
                btn.setTitle("HIDE", for: .normal)
                break
            case .Others( _):
                btn.setTitle("OTHERS", for: .normal)
                break
            }
            break
        case .EmptyView:
            btn.isUserInteractionEnabled = false
            break
        }
        uiview.addSubview(btn)
        btn.leadingAnchor.constraint(equalTo: uiview.leadingAnchor).isActive = true
        btn.topAnchor.constraint(equalTo: uiview.topAnchor).isActive = true
        btn.centerXAnchor.constraint(equalTo: uiview.centerXAnchor).isActive = true
        btn.centerYAnchor.constraint(equalTo: uiview.centerYAnchor).isActive = true
        return uiview
    }
}

extension NumberPad {
    @objc private func actionBtnStr(_ sender: UIButton) {
        NSLog("\(#function)")
    }
    
    @objc private func actionBtnBackspace(_ sender: UIButton) {
        NSLog("\(#function)")
    }
    
    @objc private func actionBtnDone(_ sender: UIButton) {
        NSLog("\(#function)")
    }
    
    @objc private func actionBtnHide(_ sender: UIButton) {
        NSLog("\(#function)")
    }
    
    @objc private func actionBtnOthers(_ sender: UIButton){
        NSLog("\(#function)")
    }
}
