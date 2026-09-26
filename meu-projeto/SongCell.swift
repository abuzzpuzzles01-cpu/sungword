import UIKit

public class SongCell: UICollectionViewCell {
    
    public static let identifier = "SongCell"
    
    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let badgeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(badgeImageView)

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5625), // Proporção 16:9

            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),

            badgeImageView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 6),
            badgeImageView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -6),
            badgeImageView.widthAnchor.constraint(equalToConstant: 24),
            badgeImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    public func configure(with song: Song) {
        titleLabel.text = song.title
        
        // Busca a imagem no Bundle no padrão video_album_nome.png ou video_album_nome
        let thumbImageName = song.getThumbFileName()
        let cleanThumbName = (thumbImageName as NSString).deletingPathExtension
        
        if let image = UIImage(named: thumbImageName) ?? UIImage(named: cleanThumbName) {
            thumbnailImageView.image = image
        } else {
            thumbnailImageView.image = UIImage(named: "placeholder_thumb")
        }

        // Configuração do Badge (Grátis / Baixado / Bloqueado)
        if song.isFree() {
            badgeImageView.image = UIImage(systemName: "checkmark.circle.fill")
            badgeImageView.tintColor = .systemGreen
        } else if song.isDownloaded() {
            badgeImageView.image = UIImage(systemName: "arrow.down.circle.fill")
            badgeImageView.tintColor = .systemBlue
        } else {
            badgeImageView.image = UIImage(systemName: "lock.fill")
            badgeImageView.tintColor = .systemOrange
        }
    }
}
