import Foundation

public class Song: NSObject, Codable, NSSecureCoding {
    
    // MARK: - Constants
    private static let BASE_CDN_URL = "https://newabuzzassets.b-cdn.net/assets/tres_palavrinhas"

    /// IDs dos vídeos de exemplo gratuitos
    private static let defaultFreeVideos: Set<String> = [
        "dvd1_o_sabao",          // DVD 1 (Grátis)
        "dvd2_pare",             // DVD 2 (Grátis)
        "dvd3_meu_melhor_amigo", // DVD 3 (Grátis)
        "dormir_o_sabao",        // Hora de Dormir (Grátis)
        "tlw_soap"               // Inglês (Grátis)
    ]

    // MARK: - Properties
    public var isActive: Bool
    public var banner: String?
    public var free: String?
    public var identifier: Int
    public var productIdentifier: String?
    public var songName: String?
    public var source: String?

    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case isActive = "Active"
        case banner = "Banner"
        case free = "Free"
        case identifier = "ContentId"
        case productIdentifier = "StoreId"
        case songName = "Name"
        case source = "Source"
    }

    // MARK: - Initializer
    public init(isActive: Bool = false, banner: String? = nil, free: String? = nil, identifier: Int = 0, productIdentifier: String? = nil, songName: String? = nil, source: String? = nil) {
        self.isActive = isActive
        self.banner = banner
        self.free = free
        self.identifier = identifier
        self.productIdentifier = productIdentifier
        self.songName = songName
        self.source = source
        super.init()
    }

    // MARK: - NSSecureCoding Implementation
    public static var supportsSecureCoding: Bool {
        return true
    }

    public func encode(with coder: NSCoder) {
        coder.encode(isActive, forKey: "Active")
        coder.encode(banner, forKey: "Banner")
        coder.encode(free, forKey: "Free")
        coder.encode(identifier, forKey: "ContentId")
        coder.encode(productIdentifier, forKey: "StoreId")
        coder.encode(songName, forKey: "Name")
        coder.encode(source, forKey: "Source")
    }

    public required init?(coder: NSCoder) {
        self.isActive = coder.decodeBool(forKey: "Active")
        self.banner = coder.decodeObject(of: NSString.self, forKey: "Banner") as String?
        self.free = coder.decodeObject(of: NSString.self, forKey: "Free") as String?
        self.identifier = coder.decodeInteger(forKey: "ContentId")
        self.productIdentifier = coder.decodeObject(of: NSString.self, forKey: "StoreId") as String?
        self.songName = coder.decodeObject(of: NSString.self, forKey: "Name") as String?
        self.source = coder.decodeObject(of: NSString.self, forKey: "Source") as String?
        super.init()
    }

    // MARK: - Business Logic Methods
    
    public func isFree() -> Bool {
        guard let freeValue = free else { return false }
        return freeValue != "N"
    }

    public func isUnlocked() -> Bool {
        if isFree() {
            return true
        }
        let fileId = getFileName()
        return Song.defaultFreeVideos.contains(fileId)
    }

    public func getFileName() -> String {
        guard let productIdentifier = productIdentifier,
              let lastDotIndex = productIdentifier.lastIndex(of: ".") else {
            return productIdentifier ?? ""
        }
        let indexAfterDot = productIdentifier.index(after: lastDotIndex)
        return String(productIdentifier[indexAfterDot...])
    }

    public func getFolderCategory() -> String {
        let fileId = getFileName()
        if fileId.hasPrefix("dvd1_") {
            return "dvd1"
        } else if fileId.hasPrefix("dvd2_") {
            return "dvd2"
        } else if fileId.hasPrefix("dvd3_") {
            return "dvd3"
        } else if fileId.hasPrefix("dormir_") {
            return "dormir"
        } else if fileId.hasPrefix("tlw_") {
            return "tlw"
        }
        return "outros"
    }

    // MARK: - Download & Directory Paths
    
    public func getDownloadURL() -> URL? {
        let folder = getFolderCategory()
        let fileId = getFileName()
        let urlString = "\(Song.BASE_CDN_URL)/\(folder)/\(fileId).zip"
        return URL(string: urlString)
    }

    public func getTresPalavrinhasDirectory() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let baseDir = documentsURL.appendingPathComponent("tres_palavrinhas", isDirectory: true)
        
        if !fileManager.fileExists(atPath: baseDir.path) {
            try? fileManager.createDirectory(at: baseDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return baseDir
    }
    
    public func getLocalZipURL() -> URL {
        return getTresPalavrinhasDirectory().appendingPathComponent("\(getFileName()).zip")
    }
    
    public func getLocalVideoFolderURL() -> URL {
        let folderName = getFolderCategory()
        let categoryDir = getTresPalavrinhasDirectory().appendingPathComponent(folderName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: categoryDir.path) {
            try? FileManager.default.createDirectory(at: categoryDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return categoryDir
    }

    public func getLocalVideoMP4URL() -> URL {
        let videoName = getThumb() ?? "video_\(getFileName())"
        return getLocalVideoFolderURL().appendingPathComponent("\(videoName).mp4")
    }

    public func isDownloaded() -> Bool {
        let mp4URL = getLocalVideoMP4URL()
        return FileManager.default.fileExists(atPath: mp4URL.path)
    }

    // MARK: - Thumbnails Mapping (Padrão video_nome)
    public func getThumb() -> String? {
        let id = getFileName()
        
        switch id {
        case "dvd1_3_palavrinhas": return "video_dvd1_3_palavrinhas"
        case "dvd1_a_deus_dai_louvor": return "video_dvd1_a_deus_dai_louvor"
        case "dvd1_alo": return "video_dvd1_alo"
        case "dvd1_ao_senhor_agradecemos": return "video_dvd1_ao_senhor_agradecemos"
        case "dvd1_deus_criou_os_peixes": return "video_dvd1_deus_criou_os_peixes"
        case "dvd1_estou_alegre": return "video_dvd1_estou_alegre"
        case "dvd1_meu_barco": return "video_dvd1_meu_barco"
        case "dvd1_missionariozinho": return "video_dvd1_missionariozinho"
        case "dvd1_o_sabao": return "video_dvd1_o_sabao"
        case "dvd1_quem_fez": return "video_dvd1_quem_fez"
            
        case "dormir_3_palavrinhas": return "video_dormir_3_palavrinhas"
        case "dormir_a_deus_dai_louvor": return "video_dormir_a_deus_dai_louvor"
        case "dormir_alo": return "video_dormir_alo"
        case "dormir_ao_senhor_agradecemos": return "video_dormir_ao_senhor_agradecemos"
        case "dormir_deus_criou_os_peixes": return "video_dormir_deus_criou_os_peixes"
        case "dormir_estou_alegre": return "video_dormir_estou_alegre"
        case "dormir_meu_barco": return "video_dormir_meu_barco"
        case "dormir_missionariozinho": return "video_dormir_missionariozinho"
        case "dormir_o_sabao": return "video_dormir_o_sabao"
        case "dormir_quem_fez": return "video_dormir_quem_fez"
            
        case "dvd2_assim_vou_louvar": return "video_dvd2_assim_vou_louvar"
        case "dvd2_deus_e_bom_para_mim": return "video_dvd2_deus_e_bom_para_mim"
        case "dvd2_deus_lhe_tem_amor": return "video_dvd2_deus_lhe_tem_amor"
        case "dvd2_e_bom_e_muito_bom": return "video_dvd2_e_bom_e_muito_bom"
        case "dvd2_familia_original": return "video_dvd2_familia_original"
        case "dvd2_florzinha_e_soldadinho": return "video_dvd2_florzinha_e_soldadinho"
        case "dvd2_leia_a_biblia": return "video_dvd2_leia_a_biblia"
        case "dvd2_pare": return "video_dvd2_pare"
        case "dvd2_toc_toc_toc": return "video_dvd2_toc_toc_toc"
        case "dvd2_trenzinho": return "video_dvd2_trenzinho"
            
        case "dvd3_aleluia": return "video_dvd3_aleluia"
        case "dvd3_churua": return "video_dvd3_churua"
        case "dvd3_e_feliz_o_lar": return "video_dvd3_e_feliz_o_lar"
        case "dvd3_grande_e_largo": return "video_dvd3_grande_e_largo"
        case "dvd3_ha_eu_amo_a_cristo": return "video_dvd3_ha_eu_amo_a_cristo"
        case "dvd3_homenzinho_torto": return "video_dvd3_homenzinho_torto"
        case "dvd3_meu_bom_pastor": return "video_dvd3_meu_bom_pastor"
        case "dvd3_meu_coracao_era_sujo": return "video_dvd3_meu_coracao_era_sujo"
        case "dvd3_meu_melhor_amigo": return "video_dvd3_meu_melhor_amigo"
        case "dvd3_por_dentro_fora_alto_embaixo": return "video_dvd3_por_dentro_fora_alto_embaixo"
            
        case "tlw_fatherabraham": return "video_tlw_fatherabraham"
        case "tlw_god_made_the_fishes": return "video_tlw_god_made_the_fishes"
        case "tlw_hello": return "video_tlw_hello"
        case "tlw_i_am_so_happy": return "video_tlw_i_am_so_happy"
        case "tlw_little_missionary": return "video_tlw_little_missionary"
        case "tlw_my_boat": return "video_tlw_my_boat"
        case "tlw_its_snack_time": return "video_tlw_its_snack_time"
        case "tlw_soap": return "video_tlw_soap"
        case "tlw_3_little_words": return "video_tlw_3_little_words"
        case "tlw_who_made_it": return "video_tlw_who_made_it"
            
        default: return "video_\(id)"
        }
    }
}
