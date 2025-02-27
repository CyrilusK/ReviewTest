//
//  TotalCountReviewsCell.swift
//  Test
//
//  Created by Cyril Kardash on 27.02.2025.
//

import UIKit

struct TotalCountReviewsCellConfig {
    
    static let reuseId = String(describing: TotalCountReviewsCellConfig.self)
    let totalText: NSAttributedString
    fileprivate let layout = TotalCountReviewsCellLayout()
}

// MARK: - TableCellConfig

extension TotalCountReviewsCellConfig: TableCellConfig {
    
    func update(cell: UITableViewCell) {
        guard let cell = cell as? TotalCountReviewsCell else { return }
        cell.totalLabel.attributedText = totalText
        cell.config = self
    }
    
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
}

// MARK: - Cell

final class TotalCountReviewsCell: UITableViewCell {
    
    fileprivate var config: TotalCountReviewsCellConfig?
    let totalLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        totalLabel.frame = layout.totalLabelFrame
    }
}
    
// MARK: - Private

private extension TotalCountReviewsCell {
    
    func setupCell() {
        contentView.addSubview(totalLabel)
    }
}

private final class TotalCountReviewsCellLayout {

    // MARK: - Фрейм
    private(set) var totalLabelFrame = CGRect.zero

    // MARK: - Отступ
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    // MARK: - Расчёт фреймов и высоты ячейки
    func height(config: TotalCountReviewsCellConfig, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right
        let maxX = (maxWidth - config.totalText.boundingRect(width: width).size.width) / 2
        
        totalLabelFrame = CGRect(
            origin: CGPoint(x: maxX , y: insets.top),
            size: config.totalText.boundingRect(width: width).size
        )

        return totalLabelFrame.maxY + insets.bottom
    }
}

