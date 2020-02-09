//
//  ViewController.swift
//  MyGuildWars2Account
//
//  Created by Zach Eriksen on 2/8/20.
//  Copyright © 2020 oneleif. All rights reserved.
//

import UIKit
import Combine
import SwiftUIKit
import GW2

class ViewController: UIViewController {
    private var bag = [AnyCancellable]()
    
    private var account: Account? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.draw()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Navigate.shared.configure(controller: navigationController)
            .set(title: "Fetching GW2 Account...")
        
        draw()
        fetch()
    }
    
    private func fetch() {
        API.instance.account()
            .sink(receiveCompletion: { (event) in
                if case .failure(let error) = event {
                    print(error)
                }
        }) { [weak self] (account) in
            self?.account = account
        }
        .store(in: &bag)
    }
    
    private func draw() {
        guard let account = account else {
            view.clear().embed { LoadingView().start() }
            return
        }
        
        view.clear().embed { AccountView(account: account) }
    }
}

class AccountView: UIView {
    private let account: Account
    
    init(account: Account) {
        self.account = account
        
        super.init(frame: .zero)
        
        embed {
            SafeAreaView {
                Table(defaultCellHeight: 44) {
                    [
                        cell(withTitle: "Age (Days)", andValue: account.age / 60 / 24),
                        cell(withTitle: "World", andValue: account.world),
//                        cell(withTitle: "Guilds", andValue: account.guilds.joined(separator: ", ")),
//                        cell(withTitle: "Guild Leader", andValue: ),
                        cell(withTitle: "Access", andValue: account.access.joined(separator: ", ")),
                        cell(withTitle: "Created", andValue: account.created),
                        cell(withTitle: "Commander", andValue: account.commander),
                        cell(withTitle: "Fractal Level", andValue: account.fractal_level),
                        cell(withTitle: "Daily AP", andValue: account.daily_ap),
                        cell(withTitle: "Monthly AP", andValue: account.monthly_ap),
                        cell(withTitle: "WVW Rank", andValue: account.wvw_rank),
                        
                    ]
                }
            }
        }
        .navigateSet(title: account.name)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func cell(withTitle title: String, andValue value: CustomStringConvertible) -> UIView {
        HStack {
            [
                Label(title),
                Spacer(),
                Label(value.description)
            ]
        }
    }
}
