// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockViewController: UIViewController {
    var characterView = UIStackView()
    var lockTitle = UILabel()
    let model: LockViewModel
    init(model: LockViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        configCharacterView()
        configLabel()
        addUiElements()
        applyConstraints()
    }
    private func configCharacterView() {
        let arrangedSubview = createCharacters()
        characterView = UIStackView(arrangedSubviews: arrangedSubview)
        characterView.axis = .horizontal
        characterView.distribution = .fillEqually
        characterView.alignment = .fill
        characterView.spacing = 20
        characterView.translatesAutoresizingMaskIntoConstraints = false
    }
    private func configLabel() {
        lockTitle.text = model.lockTitle
        lockTitle.textAlignment = .center
        lockTitle.translatesAutoresizingMaskIntoConstraints = false
    }
    private func createCharacters() -> [UIView] {
        var characters = [UIView]()
        for _ in 0..<model.charCount {
            let passcodeCharacterView = PasscodeCharacterView()
            passcodeCharacterView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
            passcodeCharacterView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            characters.append(passcodeCharacterView)
        }
        return characters
    }
    private func applyConstraints() {
        characterView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        characterView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        characterView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        lockTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        lockTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        lockTitle.bottomAnchor.constraint(equalTo: characterView.topAnchor, constant: -20).isActive = true
    }
    private func addUiElements() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(lockTitle)
        self.view.addSubview(characterView)
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
