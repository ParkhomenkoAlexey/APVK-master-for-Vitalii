//
//  NewFeedViewController.swift
//  VK Course
//
//  Created by Алексей Пархоменко on 28/02/2019.
//  Copyright (c) 2019 Алексей Пархоменко. All rights reserved.
//

import UIKit

protocol NewFeedDisplayLogic: class {

    func displayNewsFeed(viewModel: NewFeed.GeneralFeedViewModel)
    func displayUser(viewModel: NewFeed.GetUser.ViewModel)
    func displayFooterLoader()
}

class NewFeedViewController: UIViewController {
    
  var interactor: NewFeedBusinessLogic?
  var router: (NSObjectProtocol & NewFeedRoutingLogic)?
    private var viewModel = NewFeed.GeneralFeedViewModel.init(cells: [], footerTitle: nil)
    
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
    let interactor            = NewFeedInteractor()
    let presenter             = NewFeedPresenter()
    let router                = NewFeedRouter()
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
    
    interactor?.getUser(request: NewFeed.GetUser.Request())
    interactor?.getNewsfeed(request: NewFeed.GetNewsfeed.Request())
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
    
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        interactor?.getNewsfeed(request: NewFeed.GetNewsfeed.Request())
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y > scrollView.contentSize.height / 1.1 {
            interactor?.getNextBatch(request: NewFeed.GetNextBranch.Request())
        }
    }
}

extension NewFeedViewController: NewFeedDisplayLogic {
    func displayUser(viewModel: NewFeed.GetUser.ViewModel) {
        print("displayUser ViewController")
        titleView.set(userViewModel: viewModel)
    }
    
    func displayNewsFeed(viewModel: NewFeed.GeneralFeedViewModel) {
        print("displayNewsFeed ViewController")
        self.viewModel = viewModel
        refreshControl.endRefreshing()
        footerView.setTitle(viewModel.footerTitle)
        table.reloadData()
    }
    
    func displayFooterLoader() {
        print("displayFooterLoader ViewController")
        footerView.showLoader()
    }
}

extension NewFeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedCodeCell.reuseId, for: indexPath) as! FeedCodeCell
        let cellViewModel = viewModel.cells[indexPath.row]
        cell.set(viewModel: cellViewModel)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = viewModel.cells[indexPath.row]
        return cellViewModel.sizes.totalHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = viewModel.cells[indexPath.row]
        return cellViewModel.sizes.totalHeight
    }
}

extension NewFeedViewController: FeedCellDelegate {
    
    func revealPost(for cell: FeedCodeCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let cellViewModel = viewModel.cells[indexPath.row]

        // при нажатии на кнопку мы достаем такое понятие как postId у нашей ячейки
        interactor?.revealPostIds(request: NewFeed.RevealPostIds.Request.init(postId: cellViewModel.postId)) // раскрывает пост по данному ID
    }
}
