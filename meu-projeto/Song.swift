import Foundation

public struct Song: Codable {
    public let id: String
    public let title: String
    public let fileName: String?
    
    // URL Base do CDN para streaming/download apenas dos vídeos PAGOS
    private let baseURL = "https://newabuzzassets.b-cdn.net/assets/tres_palavrinhas"
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case fileName
    }
    
    public init(id: String, title: String, fileName: String?) {
        self.id = id
        self.title = title
        self.fileName = fileName
    }
    
    // MARK: - Legacy / Compatibility Properties
    
    public var songName: String? {
        return title
    }
    
    public func getFileName() -> String? {
        return fileName
    }
    
    // MARK: - Free Content Check (Músicas Grátis no Bundle)
    public func isFree() -> Bool {
        guard let rawId = getFileName() else { return false }
        let cleanId = (rawId as NSString).deletingPathExtension
        
        let freeSongs: Set<String> = [
            "dvd1_o_sabao",          // DVD 1 (Grátis)
            "dvd2_pare",             // DVD 2 (Grátis)
            "dvd3_meu_melhor_amigo", // DVD 3 (Grátis)
            "dormir_o_sabao",        // Hora de Dormir (Grátis)
            "tlw_soap"               // Inglês (Grátis)
        ]
        
        // Trata caso a string já venha com 'video_'
        let normalizedId = cleanId.hasPrefix("video_") ? String(cleanId.dropFirst(6)) : cleanId
        return freeSongs.contains(normalizedId)
    }
    
    // MARK: - Main Video URL Resolver
    
    /// Retorna a URL final para reprodução:
    /// 1. Se for grátis -> Procura no Bundle com o prefixo 'video_' (ex: video_dvd1_o_sabao.mp4)
    /// 2. Se for pago e baixado -> Procura na pasta Documents (video_id.mp4)
    /// 3. Se for pago e não baixado -> Retorna a URL remota do CDN (.mp4)
    public func getVideoURL() -> URL? {
        guard let rawFileName = getFileName(), !rawFileName.isEmpty else {
            print("❌ [Song] fileName está nulo ou vazio para a música \(title)")
            return nil
        }
        
        let cleanId = (rawFileName as NSString).deletingPathExtension
        
        // Garante que o nome tenha o prefixo "video_"
        let videoFileName = cleanId.hasPrefix("video_") ? cleanId : "video_\(cleanId)"
        
        // 1. VÍDEO GRÁTIS: Carrega do Bundle (ex: video_dvd1_o_sabao.mp4)
        if isFree() {
            // Busca pelo nome com o prefixo 'video_'
            if let bundleURL = Bundle.main.url(forResource: videoFileName, withExtension: "mp4") {
                print("✅ [Bundle MP4]: Encontrado \(bundleURL.lastPathComponent)")
                return bundleURL
            }
            
            // Fallback: Busca caso o recurso no Bundle não utilize o prefixo
            if let rawBundleURL = Bundle.main.url(forResource: cleanId, withExtension: "mp4") {
                print("✅ [Bundle MP4 Direct]: Encontrado \(rawBundleURL.lastPathComponent)")
                return rawBundleURL
            }
            
            print("❌ [Bundle ERRO]: Arquivo '\(videoFileName).mp4' não encontrado no Bundle do App.")
        }
        
        // 2. VÍDEO PAGO BAIXADO LOCALMENTE
        if isDownloaded() {
            let localURL = getLocalVideoMP4URL()
            print("✅ [Local MP4]: Encontrado na Documents \(localURL.lastPathComponent)")
            return localURL
        }
        
        // 3. VÍDEO PAGO REMOTO (CDN)
        if let remoteURL = getDownloadURL() {
            print("🌐 [CDN Stream]: \(remoteURL.absoluteString)")
            return remoteURL
        }
        
        return nil
    }
    
    // MARK: - Download & Local Storage Methods
    
    public var downloadUrl: String? {
        return getDownloadURL()?.absoluteString
    }
    
    /// Retorna a URL remota da CDN para os vídeos pagos
    public func getDownloadURL() -> URL? {
        guard let rawId = getFileName() else { return nil }
        let cleanId = (rawId as NSString).deletingPathExtension
        let normalizedId = cleanId.hasPrefix("video_") ? String(cleanId.dropFirst(6)) : cleanId
        return URL(string: "\(baseURL)/\(normalizedId).mp4")
    }
    
    /// Retorna o caminho local na pasta Documents para vídeos baixados (video_id.mp4)
    public func getLocalVideoMP4URL() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let rawId = getFileName() ?? id
        let cleanId = (rawId as NSString).deletingPathExtension
        let videoFileName = cleanId.hasPrefix("video_") ? cleanId : "video_\(cleanId)"
        return documentsURL.appendingPathComponent("\(videoFileName).mp4")
    }
    
    /// Retorna o caminho do arquivo .zip local na pasta Documents
    public func getLocalZipURL() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let rawId = getFileName() ?? id
        let cleanId = (rawId as NSString).deletingPathExtension
        let normalizedId = cleanId.hasPrefix("video_") ? String(cleanId.dropFirst(6)) : cleanId
        return documentsURL.appendingPathComponent("\(normalizedId).zip")
    }
    
    /// Verifica se o vídeo pago já foi baixado e existe na pasta Documents
    public func isDownloaded() -> Bool {
        if isFree() { return true }
        
        let localURL = getLocalVideoMP4URL()
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: localURL.path) else {
            return false
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: localURL.path)
            if let fileSize = attributes[.size] as? UInt64, fileSize > 0 {
                return true
            } else {
                try fileManager.removeItem(at: localURL)
                return false
            }
        } catch {
            return false
        }
    }
    
    // MARK: - Thumbnails Mapping
    public func getThumb() -> String? {
        guard let rawId = getFileName() else {
            return "bg_splash"
        }
        
        let cleanId = (rawId as NSString).deletingPathExtension
        let id = cleanId.hasPrefix("video_") ? String(cleanId.dropFirst(6)) : cleanId
        
        let thumbnailMap: [String: String] = [
            // DVD 1
            "dvd1_3_palavrinhas": "video_dvd1_3_palavrinhas",
            "dvd1_a_deus_dai_louvor": "video_dvd1_a_deus_dai_louvor",
            "dvd1_alo": "video_dvd1_alo",
            "dvd1_ao_senhor_agradecemos": "video_dvd1_ao_senhor_agradecemos",
            "dvd1_deus_criou_os_peixes": "video_dvd1_deus_criou_os_peixes",
            "dvd1_estou_alegre": "video_dvd1_estou_alegre",
            "dvd1_meu_barco": "video_dvd1_meu_barco",
            "dvd1_missionariozinho": "video_dvd1_missionariozinho",
            "dvd1_o_sabao": "video_dvd1_o_sabao",
            "dvd1_quem_fez": "video_dvd1_quem_fez",

            // Hora de Dormir
            "dormir_3_palavrinhas": "video_dormir_3_palavrinhas",
            "dormir_a_deus_dai_louvor": "video_dormir_a_deus_dai_louvor",
            "dormir_alo": "video_dormir_alo",
            "dormir_ao_senhor_agradecemos": "video_dormir_ao_senhor_agradecemos",
            "dormir_deus_criou_os_peixes": "video_dormir_deus_criou_os_peixes",
            "dormir_estou_alegre": "video_dormir_estou_alegre",
            "dormir_meu_barco": "video_dormir_meu_barco",
            "dormir_missionariozinho": "video_dormir_missionariozinho",
            "dormir_o_sabao": "video_dormir_o_sabao",
            "dormir_quem_fez": "video_dormir_quem_fez",

            // DVD 2
            "dvd2_assim_vou_louvar": "video_dvd2_assim_vou_louvar",
            "dvd2_deus_e_bom_para_mim": "video_dvd2_deus_e_bom_para_mim",
            "dvd2_deus_lhe_tem_amor": "video_dvd2_deus_lhe_tem_amor",
            "dvd2_e_bom_e_muito_bom": "video_dvd2_e_bom_e_muito_bom",
            "dvd2_familia_original": "video_dvd2_familia_original",
            "dvd2_florzinha_e_soldadinho": "video_dvd2_florzinha_e_soldadinho",
            "dvd2_leia_a_biblia": "video_dvd2_leia_a_biblia",
            "dvd2_pare": "video_dvd2_pare",
            "dvd2_toc_toc_toc": "video_dvd2_toc_toc_toc",
            "dvd2_trenzinho": "video_dvd2_trenzinho",

            // DVD 3
            "dvd3_aleluia": "video_dvd3_aleluia",
            "dvd3_churua": "video_dvd3_churua",
            "dvd3_e_feliz_o_lar": "video_dvd3_e_feliz_o_lar",
            "dvd3_grande_e_largo": "video_dvd3_grande_e_largo",
            "dvd3_ha_eu_amo_a_cristo": "video_dvd3_ha_eu_amo_a_cristo",
            "dvd3_homenzinho_torto": "video_dvd3_homenzinho_torto",
            "dvd3_meu_bom_pastor": "video_dvd3_meu_bom_pastor",
            "dvd3_meu_coracao_era_sujo": "video_dvd3_meu_coracao_era_sujo",
            "dvd3_meu_melhor_amigo": "video_dvd3_meu_melhor_amigo",
            "dvd3_por_dentro_fora_alto_embaixo": "video_dvd3_por_dentro_fora_alto_embaixo",

            // The Little Words (TLW)
            "tlw_fatherabraham": "video_tlw_fatherabraham",
            "tlw_god_made_the_fishes": "video_tlw_god_made_the_fishes",
            "tlw_hello": "video_tlw_hello",
            "tlw_i_am_so_happy": "video_tlw_i_am_so_happy",
            "tlw_little_missionary": "video_tlw_little_missionary",
            "tlw_my_boat": "video_tlw_my_boat",
            "tlw_its_snack_time": "video_tlw_its_snack_time",
            "tlw_soap": "video_tlw_soap",
            "tlw_3_little_words": "video_tlw_3_little_words",
            "tlw_who_made_it": "video_tlw_who_made_it"
        ]
        
        return thumbnailMap[id] ?? "video_\(id)"
    }
}
