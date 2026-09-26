import Foundation

public struct Song: Codable {
    public let id: String              // Ex: "dvd1_3_palavrinhas"
    public let title: String
    public let fileName: String?        // Ex: "video_dvd1_3_palavrinhas.mp4"
    public let urlVideo: String?        // URL completa do vídeo
    public let isFreeContent: Bool?
    
    // URL Base atualizada do CDN
    private let baseURL = "https://newabuzzassets.b-cdn.net/assets/tres_palavrinhas"
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case fileName
        case urlVideo = "url_video"
        case isFreeContent = "is_free"
    }
    
    public init(id: String, title: String, fileName: String? = nil, urlVideo: String? = nil, isFreeContent: Bool? = nil) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.urlVideo = urlVideo
        self.isFreeContent = isFreeContent
    }
    
    // MARK: - Regra 1: Retorna no formato album_nome (Sem Extensão)
    public func getBaseKey() -> String {
        let rawName = fileName ?? id
        var clean = (rawName as NSString).deletingPathExtension
        
        if clean.hasPrefix("video_") {
            clean = String(clean.dropFirst(6))
        }
        return clean
    }

    // MARK: - Regra 2: Retorna no formato video_album_nome.mp4
    public func getVideoFileName() -> String {
        let baseKey = getBaseKey()
        return "video_\(baseKey).mp4"
    }

    // MARK: - Regra 3: Retorna no formato video_album_nome.png
    public func getThumbFileName() -> String {
        let baseKey = getBaseKey()
        return "video_\(baseKey).png"
    }

    // MARK: - Checagem Free / Paid
    public func isFree() -> Bool {
        if let explicitFree = isFreeContent {
            return explicitFree
        }
        
        let freeKeys: Set<String> = [
            "dvd1_o_sabao",
            "dvd2_pare",
            "dvd3_meu_melhor_amigo",
            "dormir_o_sabao",
            "tlw_soap"
        ]
        return freeKeys.contains(getBaseKey())
    }

    // MARK: - Resolução de URLs e Caminhos Locais
    public func getVideoURL() -> URL? {
        if isFree() {
            // Busca o arquivo "video_album_nome.mp4" diretamente no Bundle
            let videoName = getVideoFileName()
            let nameWithoutExtension = (videoName as NSString).deletingPathExtension
            
            return Bundle.main.url(forResource: nameWithoutExtension, withExtension: "mp4")
        } else if isDownloaded() {
            return getLocalVideoMP4URL()
        }
        return nil
    }

    /// URL Remota para download dos vídeos pagos
    public func getDownloadURL() -> URL? {
        guard !isFree() else { return nil }
        
        if let explicitURL = urlVideo, let url = URL(string: explicitURL) {
            return url
        }
        
        return URL(string: "\(baseURL)/\(getVideoFileName())")
    }

    public func getLocalVideoMP4URL() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent(getVideoFileName())
    }

    public func isDownloaded() -> Bool {
        if isFree() { return true }
        let localURL = getLocalVideoMP4URL()
        return FileManager.default.fileExists(atPath: localURL.path)
    }
}
