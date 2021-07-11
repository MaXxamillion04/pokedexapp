//
//  PokeCell.swift
//  PokeDex
//
//  Created by MaXx Speller on 7/9/21.
//

import UIKit

class PokeCell: UITableViewCell {

    @IBOutlet weak var number: UILabel!
    
    @IBOutlet weak var pokemonName: UILabel!
    
    @IBOutlet weak var pokemonImage: UIImageView!
    
    @IBOutlet weak var typeImage: UIImageView!
    
    @IBOutlet weak var typeImage2: UIImageView!
    
    
    var imageURL: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        typeImage.image = UIImage(named: "blank")
        typeImage2.image = UIImage(named:"blank")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //placeholder for pointer, will hold data
    func configure(forPokemonPointer: PokeMonPointer, index: Int){
        number.text = formatNumber(for: index)
        pokemonName.text = forPokemonPointer.name ?? ""
        //no image info yet

    }
    //
    func configure(forPokemon: PokeMon){
        number.text = formatNumber(for: forPokemon.id ?? 0)
        pokemonName.text = forPokemon.name?.localizedCapitalized ?? "error"
        imageURL = forPokemon.sprites?.front_default
        configureTypeImage(type: forPokemon.types?[0].type.name ?? "Metal", forImage: typeImage2)
        if(forPokemon.types?.count ?? 0 > 1) {
            configureTypeImage(type: forPokemon.types?[1].type.name ?? "Metal", forImage: typeImage)
        }
        
    }
    func configureTypeImage(type:String, forImage tI: UIImageView){
        switch(type){
        case "fire": tI.image = UIImage(named:"fire")
        case "water": tI.image = UIImage(named:"water")
        case "grass": tI.image = UIImage(named:"grass")
        case "poison": tI.image = UIImage(named:"poison")
        case "rock": tI.image = UIImage(named:"rock")
        case "fighting": tI.image = UIImage(named:"fighting")
        case "phychic": tI.image = UIImage(named:"psychic")
        case "bug": tI.image = UIImage(named:"bug")
        case "normal": tI.image = UIImage(named:"normal")
        case "flying": tI.image = UIImage(named:"flying")
        case "ground": tI.image = UIImage(named:"ground")
        case "dragon": tI.image = UIImage(named:"dragon")
        case "steel": tI.image = UIImage(named:"steel")
        case "electric": tI.image = UIImage(named:"electric")
        case "ice":tI.image = UIImage(named:"ice")
        case "fairy":tI.image = UIImage(named: "fairy")
        case "psychic":tI.image = UIImage(named: "psychic")
        case "ghost":tI.image = UIImage(named: "ghost")
        default: print(type)
            tI.image = UIImage(named: "metal")
        }
        
    }
    func prepareImageForShow() {
        //var imagePointer: UIImage? = nil
        NetworkController.shared.fetchPokeImage(fromURL: imageURL) { [weak self](result) in
            guard let self = self else {return}
            switch (result) {
            case .failure(let error):
                print(error)
            case .success(let pokeImage):
                
                DispatchQueue.main.async {
                    self.pokemonImage.image = pokeImage
                }
            }
            
        }
    }
    override func prepareForReuse() {
        number.text = "000"
        pokemonName.text = "error"
        imageURL = "none"
        typeImage.image = nil
        typeImage2.image = UIImage(named:"blank")
        pokemonImage.image = nil
        
    }
    func formatNumber(for num: Int) -> String {
        var ret = String(num)
        while ret.count < 3{
            ret = "0"+ret
        }
        return ret
    }

}


