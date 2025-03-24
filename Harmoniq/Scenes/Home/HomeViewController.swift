//
//  HomeViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 12.02.25.
//
import UIKit

class HomeViewController: UIViewController {
    // MARK: Properties
    let homeViewModel = HomeViewModel.shared
    
    private let homeTable : UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(homeTable)
        setupUI()
        homeViewModel.onSet = {
            self.homeTable.reloadData()
        }
        homeViewModel.fetchAlbums()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Listen Now"
        navigationController?.navigationBar.tintColor = .label
        homeTable.delegate = self
        homeTable.dataSource = self
        homeTable.separatorStyle = .none
        homeTable.register(HomeTableViewCell.self, forCellReuseIdentifier: "homeTableCell")
        homeTable.register(SimpleHomeTableViewCell.self, forCellReuseIdentifier: "simpleHomeTableCell")
        NSLayoutConstraint.activate([
            homeTable.topAnchor.constraint(equalTo: view.topAnchor),
            homeTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            homeTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            homeTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - Extensions
extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "homeTableCell",
            for: indexPath
        ) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.configure(with: "Top Picks For You", topPicks: homeViewModel.albums)
            return cell
        case 1:
            let cell = homeTable.dequeueReusableCell(withIdentifier: "simpleHomeTableCell", for: indexPath) as! SimpleHomeTableViewCell
            cell.delegate = self
            cell.configure(with: "Recents", albums: homeViewModel.albums)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    func didSelectItem(topPick: AlbumElement, indexPath: Int) {
        let detailVC = AlbumDetailViewController()
        detailVC.configure(with: homeViewModel.albums[indexPath])
        detailVC.album = homeViewModel.albums[indexPath]
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
extension HomeViewController: SimpleTableViewCellDelegate{
    func didSelectItem(index: Int) {
        let detailVC = AlbumDetailViewController()
        detailVC.configure(with: homeViewModel.albums[index])
        detailVC.album = homeViewModel.albums[index]
        navigationController?.pushViewController(detailVC, animated: true)
        guard let tabBarController = self.tabBarController else {
            NSLog("tabBarController is nil - layout update aborted")
            return
        }
        guard let glassyTabBar = tabBarController as? GlassyTabBarViewController else {
            NSLog("Failed to cast to GlassyTabBarViewController - layout update aborted")
            return
        }
        glassyTabBar.tabBar.setNeedsLayout()
        glassyTabBar.tabBar.layoutIfNeeded()
    }
}
