//
//  FavoriteMoviesTableViewController.swift
//  MoviesApp
//
//  Created by Andre Faruolo on 13/11/18.
//  Copyright © 2018 Andre Faruolo. All rights reserved.
//

import UIKit

class FavoriteMoviesTableViewController: UITableViewController {
    
    var movies: [Movie] = []
    var filteredMovies = [Movie]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchImageView = UIImageView()
    var searchLabel = UILabel()
    var hasAddedSearchImage: Bool = false
    var searchText = ""
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        
        movies = MovieDAO.readAllFavoriteMovies()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movies = MovieDAO.readAllFavoriteMovies()
        self.tableView.reloadData()
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering(){
            return self.filteredMovies.count
        }else{
            return self.movies.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "favoriteMovieTableViewCell", for: indexPath) as! FavoriteMovieTableViewCell
    
        if isFiltering(){
            
            cell.setupCell(title: filteredMovies[indexPath.row].title, detail: filteredMovies[indexPath.row].overview, release: filteredMovies[indexPath.row].release_date, posterPath: filteredMovies[indexPath.row].poster_path)
            
        } else {
            
            cell.setupCell(title: movies[indexPath.row].title, detail: movies[indexPath.row].overview, release: movies[indexPath.row].release_date, posterPath: movies[indexPath.row].poster_path)
            
        }
    
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(self.movies[indexPath.row].title)
        
        if let viewController = UIStoryboard(name: "Movie", bundle: nil).instantiateViewController(withIdentifier: "selectedMovieViewController") as? SelectedMovieTableViewController {
    
            if isFiltering(){
                viewController.movie = self.filteredMovies[indexPath.row]
            }else{
                viewController.movie = self.movies[indexPath.row]
            }
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if isFiltering(){
                print(filteredMovies[indexPath.row].title)
                MovieDAO.deleteFavoriteMovie(favoriteMovie: filteredMovies[indexPath.row])
                self.filteredMovies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }else{
                print(movies[indexPath.row].title)
                MovieDAO.deleteFavoriteMovie(favoriteMovie: movies[indexPath.row])
                self.movies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
    }

}

extension FavoriteMoviesTableViewController: UISearchResultsUpdating, UISearchControllerDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredMovies = movies.filter({( movie : Movie) -> Bool in
            self.searchText = searchText
            return movie.title.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        
        if (self.filteredMovies.isEmpty == true && !searchBarIsEmpty()) && hasAddedSearchImage == false {
            print("Sua busca não retornou resultados")
            
            let searchText = "Sua busca por \"" + self.searchText + "\" não retornou resultados"
            self.searchLabel.text = searchText
            self.searchLabel.textAlignment = .center
            self.searchLabel.frame.size = CGSize(width: 300, height: 150)
            self.searchLabel.numberOfLines = 3
            self.searchLabel.center = self.tableView.center
            
            let searchImage = UIImage(named: "search_icon.png")
            self.searchImageView = UIImageView(image: searchImage)
            self.searchImageView.frame.size = CGSize(width: 100, height: 100)
            self.searchImageView.center.x = self.tableView.center.x
            self.searchImageView.center.y = self.tableView.center.y - 100
            self.tableView.addSubview(searchImageView)
            self.tableView.addSubview(searchLabel)
            hasAddedSearchImage = true
            
        }
        
        if (self.filteredMovies.isEmpty == false && !searchBarIsEmpty()) && hasAddedSearchImage == true {
            self.searchImageView.removeFromSuperview()
            self.hasAddedSearchImage = false
            self.searchLabel.removeFromSuperview()
        }
        
        
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        print("Dismiss")
        
        if self.hasAddedSearchImage == true {
            self.searchImageView.removeFromSuperview()
            self.searchLabel.removeFromSuperview()
        }
        
    }
    
}
