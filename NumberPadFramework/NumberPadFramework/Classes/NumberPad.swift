//
//  NumberPad.swift
//  NumberPadFramework
//
//  Created by Dannian Park on 2021/09/13.
//

import UIKit

public protocol NumberPadDelegate: AnyObject {
    func padBtnTouchEvent(_ sender: UIButton, str: String)
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
    
    /// 보여지는 타입 현재는 default만 존재.
    public var displayType: NumberPadType = .defaultType { didSet { self.updateElementsSetting() } }
    
    /// 각 element간의 간격
    public var elementSpace : CGFloat = 2 { didSet { self.updateElementsSetting() } }
    /// Pad Container와 우측 Side element 간의 비율
    public var padAndSideMultiplier: CGFloat = 3 { didSet { self.updateElementsSetting() } }
    
    /// contain 하는 uiview의 백그라운드 컬러
    public var containerBackgroundColor : UIColor = .white { didSet { self.updateElementsSetting() } }
    /// Container의 상 하단 마진 값
    public var containerTopBottomMargin: CGFloat = 2.0 { didSet { self.updateElementsSetting() } }
    /// Container의 좌 우측 마진 값
    public var containerLeadTrailMargin: CGFloat = 2.0 { didSet { self.updateElementsSetting() } }
    
    /// Number 보이는 Button의 Background color
    public var padButtonsBackgroundColor : UIColor = .white { didSet { self.updateElementsSetting() } }
    public var padButtonsTextColor : UIColor = .black { didSet { self.updateElementsSetting() } }
    public var padButtonsTextFont : UIFont = .systemFont(ofSize: 20, weight: .bold) { didSet { self.updateElementsSetting() } }
    
    /// Backspace가 있는경우, 해당 버튼의 Background color:
    public var backSpaceBackgroundColor : UIColor = .lightGray { didSet { self.updateElementsSetting() } }
    public var backSpaceColor : UIColor? { didSet { self.updateElementsSetting() } }
    // TODO: Image Size edit
    /// 이미지 사이즈가 좀 작은 관계로 넣어둔 코드. 차후 큰 사이즈 이미지로 교체하면 없에버릴 예정
    public var backSpaceImageEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60) { didSet { self.updateElementsSetting() } }
    /// Done버튼이 존재하는 경우, 해당 버튼의 Background Color
    public var doneBackgroundColor : UIColor = .blue { didSet { self.updateElementsSetting() } }
    public var doneColor : UIColor? { didSet { self.updateElementsSetting() } }
    public var doneFont : UIFont? = .systemFont(ofSize: 24, weight: .bold) { didSet { self.updateElementsSetting() } }
    /// Hide Button이 존재하는 경우, 해당 버튼의 Background Color. nil인 경우는 padbutton의 color와 동일.
    public var hideBackgroundColor : UIColor? { didSet { self.updateElementsSetting() } }
    public var hideColor: UIColor? { didSet { self.updateElementsSetting() } }
    
    // MARK: - 아직 미 사용 부분
    /// 각 라인에 들어갈 갯수를 정한다. Default type에서는 변경 안됨
    public var linePerElement : Int = 3 { didSet { if self.displayType != .defaultType { self.updateElementsSetting() } else {  } } }
    /// 키패드에 넣고자 하는 버튼들의 종류와 그 태그 값을 KeyValue로 사용한다. Value가 Nil인 경우에는 StringType은 해당 String을, 그 외(NoneStringType)은 NoneStrongCases로 반환을 한다. Default type에서는 변경 안됨
    public var lineElements: [(ButtonsCases, Int?)] = [] { didSet { if self.displayType != .defaultType { self.updateElementsSetting() } } }
    /// 측면에 넣으려는 element의 종류와 그 태그 값을 Key Value로 하여 사용한다. Default type에서는 변경 안됨
    public var sideElements: [(ButtonsCases, Int)] = [] { didSet { if self.displayType != .defaultType { self.updateElementsSetting() } } }
    /// 각 버튼들의 최소 width 값. 0은 최소값이 없게 되는 상태이기 때문에 꽉 채워서 나오도록 구현
    public var minBtnWidth: CGFloat = 50 // default
    
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
        
        // self.containerPad.backgroundColor = .blue
        // self.containerSide.backgroundColor = .red
        
        self.updateElementsSetting()
    }
    
    private func updateElementsSetting() {
        self.containerStackView.arrangedSubviews.forEach { element in
            element.constraints.forEach { constElement in
                constElement.isActive = false
            }
            element.removeFromSuperview()
        }
        self.containerStackView.removeFromSuperview()
        
        self.addSubview(self.containerStackView)
        NSLayoutConstraint.activate([
            .init(item: self.containerStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: self.containerLeadTrailMargin),
            .init(item: self.containerStackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: self.containerStackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: self.containerTopBottomMargin),
            .init(item: self.containerStackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        
        self.backgroundColor = self.containerBackgroundColor
        
        self.containerStackView.addArrangedSubview(self.containerPad)
        self.containerStackView.addArrangedSubview(self.containerSide)
        
        self.padAndSideConstraint = .init(item: self.containerPad, attribute: .width, relatedBy: .equal, toItem: self.containerSide, attribute: .width, multiplier: self.padAndSideMultiplier, constant: 0)
        NSLayoutConstraint.activate([
            self.padAndSideConstraint!
        ])
        
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
        
        for (index, element) in self.defaultSideBtnStr.enumerated() {
            let view = self.createView(element, tag: index)
            self.containerSide.addArrangedSubview(view)
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
        uiview.backgroundColor = self.padButtonsBackgroundColor
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        switch btnCase {
        case .StringType(let str):
            btn.setTitle(str, for: .normal)
            btn.addTarget(self, action: #selector(self.actionBtnStr(_:)), for: .touchUpInside)
            btn.setTitleColor(self.padButtonsTextColor, for: .normal)
            btn.titleLabel?.font = self.padButtonsTextFont
            btn.tag = tag ?? -1
            break
        case .NoneStringType(let notTypeCase):
            // btn.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
            // btn.imageView?.contentMode = .scaleAspectFit
            switch notTypeCase {
            case .Backspace:
                btn.setImage(self.loadIcon(name: "ClearSymbolFilledIcon"), for: .normal)
                uiview.backgroundColor = self.backSpaceBackgroundColor
                btn.tintColor = self.backSpaceColor ?? self.padButtonsTextColor
                btn.contentVerticalAlignment = .fill
                btn.contentHorizontalAlignment = .fill
                btn.imageEdgeInsets = self.backSpaceImageEdgeInsets
                btn.addTarget(self, action: #selector(actionBtnBackspace(_:)), for: .touchUpInside)
                break
            case .Done:
                btn.setTitle("DONE", for: .normal)
                uiview.backgroundColor = self.doneBackgroundColor
                btn.setTitleColor(self.doneColor ?? self.padButtonsTextColor, for: .normal)
                btn.titleLabel?.font = self.doneFont ?? self.padButtonsTextFont
                btn.addTarget(self, action: #selector(actionBtnDone(_:)), for: .touchUpInside)
                break
            case .Hide:
                btn.setImage(self.loadIcon(name: "DismissKeyboard"), for: .normal)
                // btn.setTitle("HIDE", for: .normal)
                var bgColor = self.padButtonsBackgroundColor
                if let color = self.hideBackgroundColor {
                    bgColor = color
                }
                uiview.backgroundColor = bgColor
                btn.tintColor = self.hideColor ?? self.padButtonsTextColor
                btn.addTarget(self, action: #selector(actionBtnHide(_:)), for: .touchUpInside)
                break
            case .Others( _):
                btn.setTitle("OTHERS", for: .normal)
                btn.addTarget(self, action: #selector(actionBtnOthers(_:)), for: .touchUpInside)
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
        NSLog("\(#function) :: \(sender.tag)")
        if self.displayType == .defaultType {
            guard defaultButtonsStr.count > sender.tag else {
                return
            }
            if case .StringType(let str) = defaultButtonsStr[sender.tag] {
                self.delegate?.padBtnTouchEvent(sender, str: str)
            }
        }
    }
    
    @objc private func actionBtnBackspace(_ sender: UIButton) {
        NSLog("\(#function) :: \(sender.tag)")
    }
    
    @objc private func actionBtnDone(_ sender: UIButton) {
        NSLog("\(#function) :: \(sender.tag)")
    }
    
    @objc private func actionBtnHide(_ sender: UIButton) {
        NSLog("\(#function) :: \(sender.tag)")
    }
    
    @objc private func actionBtnOthers(_ sender: UIButton){
        NSLog("\(#function) :: \(sender.tag)")
    }
}


extension NumberPad {
    fileprivate func loadIcon(name: String) -> UIImage? {
        let image = UIImage(named: name, in: bundle(), compatibleWith: nil)
        let colorable = UIImage.RenderingMode.alwaysTemplate
        return image?.withRenderingMode(colorable)
    }
    
    private func bundle() -> Bundle {
        return Bundle(for: type(of: self))
    }
}
