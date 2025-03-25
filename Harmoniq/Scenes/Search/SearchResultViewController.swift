//
//  SearchResultViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 25.03.25.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    var songs: [Song] = []
    var filteredSongs: [Song] = []
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = 58
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier )
        setUpUI()
    }
    
    func updateSearchResults(for text: String){
        if text.isEmpty {
            filteredSongs = songs
        } else {
            filteredSongs = songs.filter { $0.title.lowercased().contains(text.lowercased()) }
        }
        tableView.reloadData()
    }
    
    private func setUpUI(){
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as! SearchResultTableViewCell
        cell.song = filteredSongs[indexPath.row]
        
        return cell
    }
    
}
