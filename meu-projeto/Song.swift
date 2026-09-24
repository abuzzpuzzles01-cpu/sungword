import Foundation

public struct Song {
    public let id: String
    public let title: String
    public let fileName: String?
    
    // URL Base para download/streaming dos vídeos
    private let baseURL = "https://newabuzzassets.b-cdn.net/assets/tres_palavrinhas"
    
    public init(id: String, title: String, fileName: String?) {
        self.id = id
        self.title = title
        self.fileName = fileName
    }
    
    public func getFileName() -> String? {
        return fileName
    }
    
    // MARK: - Video URL (Vídeos Pagos / CDN Remote)
    public func getVideoURL() -> URL? {
        guard let rawId = getFileName() else { return nil }
        let cleanId = (rawId as NSString).deletingPathExtension
        
        // Retorna a URL completa no formato: https://newabuzzassets.b-cdn.net/assets/tres_palavrinhas/nome_do_video.mp4
        let urlString = "\(baseURL)/\(cleanId).mp4"
        return URL(string: urlString)
    }
    
    // MARK: - Free Content Check (Músicas Grátis)
    public func isFree() -> Bool {
        guard let rawId = getFileName() else { return false }
        let id = (rawId as NSString).deletingPathExtension
        
        let freeSongs: Set<String> = [
            "dvd1_o_sabao",          // DVD 1 (Grátis)
            "dvd2_pare",             // DVD 2 (Grátis)
            "dvd3_meu_melhor_amigo", // DVD 3 (Grátis)
            "dormir_o_sabao",        // Hora de Dormir (Grátis)
            "tlw_soap"               // Inglês (Grátis)
        ]
        
        return freeSongs.contains(id)
    }
    
    // MARK: - Thumbnails Mapping (Padrão video_nome)
    public func getThumb() -> String? {
        guard let rawId = getFileName() else {
            return "bg_splash"
        }
        
        let id = (rawId as NSString).deletingPathExtension
        
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
