import Foundation

public struct Album: Codable {
    
    // MARK: - Constants
    private static let dvd1 = "br.com.emotiondigital.trespalavrinhas.dvd1"
    private static let dvd2 = "br.com.emotiondigital.trespalavrinhas.dvd2"
    private static let horaDormir = "br.com.emotiondigital.trespalavrinhas.hora_dormir"
    
    // MARK: - Properties
    public var identifier: Int
    public var productIdentifier: String
    public var songs: [Song]?
    
    // MARK: - CodingKeys (Mapeamento GSON -> Swift)
    enum CodingKeys: String, CodingKey {
        case identifier = "ProductId"
        case productIdentifier = "StoreId"
        case songs = "Contents"
    }
    
    // MARK: - Computed Properties
    public var albumName: String? {
        switch productIdentifier {
        case Album.dvd1:
            return "DVD 1"
        case Album.dvd2:
            return "DVD 2"
        case Album.horaDormir:
            return "Hora de Dormir"
        default:
            return nil
        }
    }
    
    public var order: Int {
        switch productIdentifier {
        case Album.dvd1:
            return 0
        case Album.dvd2:
            return 1
        case Album.horaDormir:
            return 2
        default:
            return -1
        }
    }
}

