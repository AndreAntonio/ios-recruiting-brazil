//
//  GenderTableViewController.swift
//  MoviesApp
//
//  Created by Andre Faruolo on 21/11/18.
//  Copyright © 2018 Andre Faruolo. All rights reserved.
//

import UIKit

class GenderTableViewController: UITableViewController {
    
    var genres: [Genre] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "Genres"

        var genresIds = [Int]()
        
        if let movies = MovieDAO.readAllFavoriteMovies() as? [Movie]{
            for movie in movies{
                for genreID  in movie.genre_ids{
                    if !(genresIds.contains(genreID)){
                        genresIds.append(genreID)
                    }
                }
            }
        }
        
        MovieDAO.getGenres { (response, error) in
            if error != nil{
                print(error)
            }else{
                if let retrievedGenres = response as? Genres{
                    for genre in retrievedGenres.genres{
                        print(genre)
                        for genreId in genresIds{
                            if genreId == genre.id{
                                self.genres.append(genre)
                            }
                        }
                    }
                }
            }
        }
        
    }

    
    //Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genres.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "genderTableViewCell", for: indexPath) as! GenderTableViewCell
        
        cell.setupView(title: self.genres[indexPath.row].name)
        
        if FilterManager.shared.genders.contains(where: { (genre) -> Bool in
            
            if genre.id == self.genres[indexPath.row].id{
                return true
            }
            return false
        }){
            cell.selectedButtonOutlet.isHidden = false
        }else{
            cell.selectedButtonOutlet.isHidden = true
        }

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! GenderTableViewCell
        
        if FilterManager.shared.genders.contains(where: { (genre) -> Bool in
            
            if genre.id == genres[indexPath.row].id{
                return true
            }
            return false
        }){
           print("Ja existe, apagando...")
            FilterManager.shared.genders.removeAll { (genre) -> Bool in
                if genre.id == self.genres[indexPath.row].id{
                    return true
                }
                return false
            }
            print(FilterManager.shared.genders)
            cell.selectedButtonOutlet.isHidden = true
        }else{
            FilterManager.shared.genders.append(self.genres[indexPath.row])
            print(FilterManager.shared.genders)
            cell.selectedButtonOutlet.isHidden = false
        }
    }

}
