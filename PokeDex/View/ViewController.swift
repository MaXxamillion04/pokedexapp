//
//  ViewController.swift
//  PokeDex
//
//  Created by MaXx Speller on 7/9/21.
//
import Foundation
import UIKit
import SwiftSVG

class PokeDexView
: UIViewController {

    @IBOutlet weak var pokeTable: UITableView!
    let pokeQueue = DispatchQueue(label: "Dispatch for Pokemon")
    var availablePokemon = 0
    var pagesLoaded = 0
    var missingType2 = Type2(name:"missing")
    var missingType : Type?
    let missingNo = PokeMon(id:777, name: "missingNo")

    var pointers = [PokeMonPointer]()
    {
        didSet {//fetch next 30
            fetchPokeMon()
        }
    }
    var pokemon = [PokeMon]()
    override func viewDidLoad() {
        super.viewDidLoad()
        missingType = Type(type:missingType2)
        setupTable()
        // Do any additional setup after loading the view.
        fetchNextPokePage()
        self.pokeTable.reloadData()
    }
    func setupTable(){
        pokeTable.delegate = self
        pokeTable.dataSource = self
    }
    func fetchNextPokePage(){
        if( pagesLoaded < 150){
        pagesLoaded+=30
        NetworkController.shared.fetchNextPokeMonPage() { [weak self](result) in
            guard let self = self else {return}
            switch (result) {
            case .failure(let error):
                print(error)
                self.pagesLoaded-=30
            case .success(let pokePointers):
                self.pointers.append(contentsOf: pokePointers)
                DispatchQueue.main.async {
                    self.pokeTable.reloadData()
                }
            }
            
        }
        }else if(pagesLoaded != 151){
            pagesLoaded+=1
            NetworkController.shared.nextPage = "https://pokeapi.co/api/v2/pokemon?limit=1&offset=150"
            NetworkController.shared.fetchNextPokeMonPage() { [weak self](result) in
                guard let self = self else {return}
                switch (result) {
                case .failure(let error):
                    print(error)
                case .success(let pokePointers):
                    self.pointers.append(contentsOf: pokePointers)
                    DispatchQueue.main.async {
                        self.pokeTable.reloadData()
                    }
                }
                
            }
        }else{
            print("pages \(pagesLoaded)")
            print("pokelist \(pokemon.count)")
            //done loading pages
        }
    }
    func fetchPokeMon() {
        
        pokeQueue.async(flags: .barrier) {
            let pokeGroup = DispatchGroup()
        
            for pointer in self.pointers{
                if !self.pokemon.contains(where: {$0.name == pointer.name}){
                //doesnt contain
                pokeGroup.enter()
                NetworkController.shared.fetchPokeMon(for: pointer) { [weak self](result) in
                    guard let self = self else {return}
                    
                    
                    switch (result) {
                    case .failure(let error):
                        print(error)
                        self.pokemon.append(self.missingNo)
                    case .success(let newPokeMon):
                        self.pokemon.append(newPokeMon)
                        DispatchQueue.main.async {
                            self.pokeTable.reloadData()
                        }
                    }
                    pokeGroup.leave()
                }
                
            }
        }
        pokeGroup.notify(queue: .main){
            self.availablePokemon = self.pokemon.count
            self.pokemon.sort(by:{$0.id ?? 0 < $1.id ?? 0})
            self.pokeTable.reloadData()
        }
        }
        
    }
    
    


}

extension PokeDexView : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(pointers.count < 151){
            return pointers.count+1
            
        }else{
            return 151// only showing first 151 pokemon info
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if( indexPath.row < availablePokemon ) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "pokecell", for: indexPath) as? PokeCell else{ print("nope no pokecell today");return UITableViewCell()}
            
            if( pokemon.count > indexPath.row){
                cell.configure(forPokemon: pokemon[indexPath.row])
            }else{
                cell.configure(forPokemonPointer: pointers[indexPath.row], index: indexPath.row+1)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingcell", for: indexPath)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // create second view here
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row > pagesLoaded - 15 && pagesLoaded < 151){
            fetchNextPokePage()
        }
        guard let cell = cell as? PokeCell else {print("unable to cast pokecell at \(indexPath.row)");return}
        cell.prepareImageForShow()
        
    }

}
