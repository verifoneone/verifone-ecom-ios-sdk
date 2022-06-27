import UIKit

class PaymentTypeCell: UITableViewCell {

    struct Constants {
        static let contentInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        static let avatarSize = CGSize(width: 36.0, height: 36.0)
    }

    // MARK: - Properties

    var presentable = PaymentTypePresentable(name: "", cardBrand: UIImage(named: "Card", in: .module, compatibleWith: nil)!, type: .creditCard)

    // MARK: - Views

    let cardBrandImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8.0
        return view
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Lato-Bold", size: 17.0)
        label.backgroundColor = .clear
        return label
    }()

    lazy var cardStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cardBrandImageView, cardStackView])
        stackView.alignment = .center
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        cardBrandImageView.contentMode = ContentMode.scaleAspectFit
        backgroundColor = .white
        isAccessibilityElement = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8235294118, blue: 0.8274509804, alpha: 1).withAlphaComponent(0.11)
        selectedBackgroundView = backgroundView

        contentView.addSubview(stackView)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func setupConstraints() {

        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.contentInsets.top).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.contentInsets.left).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.contentInsets.right).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.contentInsets.bottom).isActive = true

        let cardBrandWidthConstriant = cardBrandImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize.width)
        let cardBrandHeightConstraint = cardBrandImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize.height)

        [cardBrandWidthConstriant, cardBrandHeightConstraint].forEach {
            $0.priority = UILayoutPriority(UILayoutPriority.required.rawValue - 1)
            $0.isActive = true
        }
    }

    // MARK: - Highlight

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - View Configuration

    func configure(with presentable: PaymentTypePresentable) {
        self.presentable = presentable
        self.accessoryType = .disclosureIndicator
        nameLabel.text = presentable.name
        cardBrandImageView.image = presentable.cardBrand
        cardBrandImageView.contentMode = ContentMode.scaleAspectFit
    }

}
