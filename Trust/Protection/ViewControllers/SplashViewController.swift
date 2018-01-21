// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import VENTouchLock

class SplashViewController: UIViewController {

    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center

        view.addSubview(label)

        let logoImageView = UIImageView(image: R.image.launch_screen_logo())
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
        ])
    }
}
