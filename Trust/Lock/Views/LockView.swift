// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockView: UIView {
    var characterView = UIStackView()
    var lockTitle = UILabel()
    lazy var characters: [PasscodeCharacterView] = {
        var characters = [PasscodeCharacterView]()
        for _ in 0..<model.charCount {
            let passcodeCharacterView = PasscodeCharacterView()
            passcodeCharacterView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
            passcodeCharacterView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            characters.append(passcodeCharacterView)
        }
        return characters
    }()
    var model: LockViewModel!
    init(_ model: LockViewModel) {
        super.init(frame: CGRect.zero)
        self.model = model
        configCharacterView()
        configLabel()
        addUiElements()
        applyConstraints()
    }
    private func configCharacterView() {
        characterView = UIStackView(arrangedSubviews: self.characters)
        characterView.axis = .horizontal
        characterView.distribution = .fillEqually
        characterView.alignment = .fill
        characterView.spacing = 20
        characterView.translatesAutoresizingMaskIntoConstraints = false
    }
    private func configLabel() {
        lockTitle.textAlignment = .center
        lockTitle.translatesAutoresizingMaskIntoConstraints = false
    }
    private func applyConstraints() {
        characterView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        characterView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        characterView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        lockTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        lockTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lockTitle.bottomAnchor.constraint(equalTo: characterView.topAnchor, constant: -20).isActive = true
    }
    private func addUiElements() {
        self.backgroundColor = UIColor.white
        self.addSubview(lockTitle)
        self.addSubview(characterView)
    }
    func shake() {
        let keypath = "position"
        let animation = CABasicAnimation(keyPath: keypath)
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: characterView.center.x - 10, y: characterView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: characterView.center.x + 10, y: characterView.center.y))
        characterView.layer.add(animation, forKey: keypath)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
