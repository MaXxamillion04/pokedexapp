//
//  PokemonModels.swift
//  PokeDex
//
//  Created by MaXx Speller on 7/9/21.
//

import Foundation


struct PokeAPICall: Decodable {
    var next: String?
    var results: [PokeMonPointer]?
}

struct PokeMonPointer: Decodable {
    var name: String?
    var url: String?
}

struct PokeMon: Decodable {
    var abilities: [Ability]?
    var id: Int?
    var moves: [Move]?
    var name: String?
    var sprites: Sprites?
    var types: [Type]?
    //var stats: [Stats]?
}
struct Ability: Decodable {
    var ability: Ability2?
}
struct Ability2: Decodable {
    var name: String?
}
struct Move: Decodable {
    var name: String?
//    var url: String?
}
struct Sprites: Decodable {
    var front_default: String?
    var versions: Versions
}
struct Versions: Decodable {
    var generationi: Icons?
    var generationvii: Icons?
}
struct Icons: Decodable {
    //to do with fancier icons, as a slideview or collectionview or something
}
struct Type: Decodable {
    var slot: Int?
    var type: Type2
}

struct Type2: Decodable {
    var name: String?
    var url: String?
}
