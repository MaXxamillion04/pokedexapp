//
//  NetworkController.swift
//  PokeDex
//
//  Created by MaXx Speller on 7/9/21.
//

import Foundation
import UIKit

final class NetworkController{
    typealias PokePageResult = Result<[PokeMonPointer],Error>
    typealias PokeMonResult = Result<PokeMon,Error>
    typealias PokeImageResult = Result<UIImage,Error>
    
    let imageCache = NSCache<NSString, AnyObject>()
    
    /*struct PokeMon: Decodable {
     var abilities: [Ability]?
     var id: Int?
     var moves: [Move]?
     var name: String?
     var sprites: Sprites?
     var types: [Type]?
     //var stats: [Stats]?
     }
    struct Type: Decodable {
        var slot: Int?
        var type: Type2
    }

    struct Type2: Decodable {
        var name: String?
        var url: String?
    }*/
    
    static let shared = NetworkController()
    
    var nextPage: String?
    private init() {
        nextPage = "https://pokeapi.co/api/v2/pokemon?limit=30&offset=0"
        
        
    }
    
    //returns next 30 pokemon from API
    
    func fetchNextPokeMonPage(completion: @escaping(PokePageResult) -> Void){
        guard let url = URL(string: nextPage ?? "") else {return}
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask( with: request){ (data, _, error) in
            guard let data = data, error == nil else {completion(.failure(error!));return}

            do { let payload = try JSONDecoder().decode(PokeAPICall.self, from: data)
                self.nextPage = payload.next
                
                completion(.success(payload.results ?? []))
                
            }
            catch let error as NSError {
                completion(.failure(error))
                return
            }
        }.resume()
        
        return
    }
    
    func fetchPokeMon(for poke: PokeMonPointer, completion: @escaping(PokeMonResult) -> Void){
        guard let url = URL(string: poke.url ?? "") else {return}
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask( with: request){ (data, _, error) in
            guard let data = data, error == nil else {completion(.failure(error!));return}

            do { let payload = try JSONDecoder().decode(PokeMon.self, from: data)
                completion(.success(payload))
            }
            catch let myError as NSError {
                completion(.failure(myError))
                return
            }
            
            
        }.resume()
        
        
        
        return
    }
    func fetchPokeImage(fromURL forURL: String?, completion: @escaping(PokeImageResult) -> Void){
        guard let forURLString = forURL else { return }
        if let cachedImage = imageCache.object(forKey: forURLString as NSString) as? UIImage {
            completion(.success(cachedImage))
            return
        }
        
        guard let url = URL(string: forURLString) else {return}
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask( with: request){ (data, _, error) in
            guard let data = data, error == nil else {completion(.failure(error!));return}

            do { let fetchedImage = UIImage(data: data)
                self.imageCache.setObject(fetchedImage!, forKey: forURLString as NSString)
                completion(.success(fetchedImage!))
            }
            catch let myError as NSError {
                completion(.failure(myError))
                return
            }
            
            
        }.resume()
        
        
        
        
    }
}
