// VideoCell.swift
import UIKit

class VideoCell: UICollectionViewCell {

    static let identifier = "VideoCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let playIconImageView: UIImageView = {
        let iv = UIImageView()
        if let playImage = UIImage(named: "play_button") ?? UIImage(systemName: "play.circle.fill") {
            iv.image = playImage
        }
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) não foi implementado")
    }

    // MARK: - Setup UI & Constraints

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(playIconImageView)
        containerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            // Container principal preenchendo a célula
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Imagem de miniatura (ocupa a maior parte da célula)
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.72),

            // Ícone de Play centralizado sobre a imagem
            playIconImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            playIconImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            playIconImageView.widthAnchor.constraint(equalToConstant: 32),
            playIconImageView.heightAnchor.constraint(equalToConstant: 32),

            // Rótulo do título na parte inferior
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ])
    }

    // MARK: - Configuration Method

    func configure(with song: Song) {
        titleLabel.text = song.songName ?? "Vídeo"

        // Procura a imagem no pacote pela chave do getThumb() ou imagem padrão de fallback
        if let thumbName = song.getThumb(), let image = UIImage(named: thumbName) ?? UIImage(named: "\(thumbName).png") {
            imageView.image = image
        } else if let bgSplash = UIImage(named: "bg_splash.png") ?? UIImage(named: "bg_splash") {
            imageView.image = bgSplash
        } else {
            imageView.image = nil
            imageView.backgroundColor = .systemBlue
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }
}
