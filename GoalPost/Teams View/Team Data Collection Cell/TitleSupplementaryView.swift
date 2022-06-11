//
//  TitleSupplementaryView.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

class TitleSupplementaryView: UICollectionReusableView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension TitleSupplementaryView {
    func configure() {

        self.layer.cornerRadius = 10
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor

        self.constrain(label, using: .edges, padding: 10)
        label.font = UIFont.preferredFont(forTextStyle: .title1)
    }
}
