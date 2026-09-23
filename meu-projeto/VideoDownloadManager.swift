import Foundation
import Compression

class VideoDownloadManager {
    
    static let shared = VideoDownloadManager()
    private init() {}
    
    /// Baixa o vídeo compactado e realiza a extração para /Documents/tres_palavrinhas/{categoria}/video_nome.mp4
    func downloadAndDecompressVideo(song: Song, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let downloadURL = song.getDownloadURL() else {
            completion(.failure(NSError(domain: "DownloadError", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL de download inválida."])))
            return
        }
        
        let destinationZipURL = song.getLocalZipURL()
        let destinationMP4URL = song.getLocalVideoMP4URL()
        
        let task = URLSession.shared.downloadTask(with: downloadURL) { localTempURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let localTempURL = localTempURL else {
                completion(.failure(NSError(domain: "DownloadError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Arquivo temporário não encontrado."])))
                return
            }
            
            do {
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: destinationZipURL.path) {
                    try fileManager.removeItem(at: destinationZipURL)
                }
                
                try fileManager.moveItem(at: localTempURL, to: destinationZipURL)
                let zipData = try Data(contentsOf: destinationZipURL)
                
                if let decompressedData = zipData.decompressZlib() {
                    try decompressedData.write(to: destinationMP4URL)
                } else {
                    try zipData.write(to: destinationMP4URL)
                }
                
                try? fileManager.removeItem(at: destinationZipURL)
                
                DispatchQueue.main.async {
                    completion(.success(destinationMP4URL))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

extension Data {
    /// Descompacta dados codificados no formato ZLIB (Algorithm.zlib)
    func decompressZlib() -> Data? {
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.count * 10)
        defer { destinationBuffer.deallocate() }
        
        let decompressedSize = self.withUnsafeBytes { (encodedSourceBuffer: UnsafeRawBufferPointer) -> Int in
            guard let address = encodedSourceBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
            return compression_decode_buffer(
                destinationBuffer,
                self.count * 10,
                address,
                self.count,
                nil,
                COMPRESSION_ZLIB
            )
        }
        
        if decompressedSize == 0 {
            return nil
        }
        
        return Data(bytes: destinationBuffer, count: decompressedSize)
    }
}
