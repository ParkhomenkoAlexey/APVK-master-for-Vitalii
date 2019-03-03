//
//  PerfectFeedViewController.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 02/03/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

protocol PerfectFeedDisplayLogic: class {
  func displayData(viewModel: PerfectFeed.Model.ViewModel.ViewModelData)
}

class PerfectFeedViewController: UIViewController {

    var interactor: PerfectFeedBusinessLogic?
    var router: (NSObjectProtocol & PerfectFeedRoutingLogic)?
    private var feedViewModel = FeedViewModel.init(cells: [], footerTitle: nil)

    private lazy var titleView = TitleView()
    private lazy var footerView = FooterView()
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var table: UITableView!
    
    // MARK: Setup
  
  private func setup() {
    let viewController        = self
    let interactor            = PerfectFeedInteractor()
    let presenter             = PerfectFeedPresenter()
    let router                = PerfectFeedRouter()
    viewController.interactor = interactor
    viewController.router     = router
    interactor.presenter      = presenter
    presenter.viewController  = viewController
    router.viewController     = viewController
  }
  
  // MARK: Routing
  
    
  // MARK: View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    table.register(FeedCodeCell.self, forCellReuseIdentifier: FeedCodeCell.reuseId)
    
    setup()
    setupTable()
    setupTopBars()
    
    // если честно не понял как правильно реализовать этот момент что я в один момент вызываю два метода из interactor
    interactor?.makeRequest(request: PerfectFeed.Model.Request.RequestType.getNewsfeed)
    interactor?.makeRequest(request: PerfectFeed.Model.Request.RequestType.getUser)
  }
  
    // MARK: Functions
    
    private func setupTable() {
        let topInset: CGFloat = 8
        if #available(iOS 11, *) {
            table.contentInset.top = topInset
        } else {
            table.contentInset.top = 64 + topInset
        }
        table.separatorStyle = .none
        table.backgroundColor = .clear
        
        table.register(FeedCodeCell.self, forCellReuseIdentifier: FeedCodeCell.reuseId)
        table.addSubview(refreshControl)
        table.tableFooterView = footerView
    }

    private func setupTopBars() {
        self.navigationController?.hidesBarsOnSwipe = true
        let topBar = UIView(frame: UIApplication.shared.statusBarFrame)
        topBar.backgroundColor = .white
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOpacity = 0.1
        topBar.layer.shadowOffset = CGSize.zero
        topBar.layer.shadowRadius = 8
        
        self.view.addSubview(topBar)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.titleView = titleView
        
    }
    
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        interactor?.makeRequest(request: PerfectFeed.Model.Request.RequestType.getNewsfeed)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y > scrollView.contentSize.height / 1.1 {
            interactor?.makeRequest(request: .getNextBatch)
        }
    }
}

extension PerfectFeedViewController: PerfectFeedDisplayLogic {
    
    func displayData(viewModel: PerfectFeed.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayNewsFeed(let feedViewModel):
            print("displayNewsFeed ViewController")
            self.feedViewModel = feedViewModel
            refreshControl.endRefreshing()
            footerView.setTitle(feedViewModel.footerTitle)
            table.reloadData()
        case .displayUser(let userViewModel):
            print("displayUser ViewController")
            titleView.set(userViewModel: userViewModel)
        case .displayFooterLoader:
            print("displayFooterLoader ViewController")
            footerView.showLoader()
        }
    }
}

extension PerfectFeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedCodeCell.reuseId, for: indexPath) as! FeedCodeCell
        let cellViewModel = feedViewModel.cells[indexPath.row]
        cell.set(viewModel: cellViewModel)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = feedViewModel.cells[indexPath.row]
        return cellViewModel.sizes.totalHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = feedViewModel.cells[indexPath.row]
        return cellViewModel.sizes.totalHeight
    }
}

extension PerfectFeedViewController: FeedCellDelegate {
    
    func revealPost(for cell: FeedCodeCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let cellViewModel = feedViewModel.cells[indexPath.row]
        
        // при нажатии на кнопку мы достаем такое понятие как postId у нашей ячейки
        // раскрывает пост по данному ID
        interactor?.makeRequest(request: PerfectFeed.Model.Request.RequestType.revealPostIds(postId: cellViewModel.postId))
    }
}
