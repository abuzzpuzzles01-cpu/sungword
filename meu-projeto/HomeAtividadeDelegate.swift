// HomeAtividadeDelegate.swift
import Foundation

protocol HomeAtividadeDelegate: AnyObject {
    /// Disparado ao selecionar um vídeo na lista para iniciar a reprodução na ExecutaVideoAtividade
    func loadVideo(content: Song, position: Int)
    
    /// Disparado para iniciar o download individual de uma faixa específica
    func startDownload(pos: Int, content: Song)
    
    /// Disparado para iniciar o download de uma lista de álbuns/coleções
    func downloadColection(products: [Album])
    
    /// Disparado para iniciar o download de todas as faixas de um álbum completo
    func downloadAlbum(product: Album)
    
    /// Disparado para iniciar o download de um item específico de música
    func downloadItem(content: Song)
}
