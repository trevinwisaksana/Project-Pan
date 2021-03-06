//
//  UtilitiesView.swift
//  SceneKit-Grid-Experiment
//
//  Created by Trevin Wisaksana on 03/09/2018.
//  Copyright © 2018 Trevin Wisaksana. All rights reserved.
//

import UIKit

public protocol UtilitiesInspectorViewDelegate: class {
    func utilitiesView(_ utilitiesView: UtilitiesInspectorView, didSelectItemAtIndexPath indexPath: IndexPath)
}

public class UtilitiesInspectorView: UIView {
    
    // MARK: - Internal properties
    
    private static let numberOfItemsInSection: Int = 3
    private static let cellHeight: CGFloat = 60.0
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private weak var delegate: UtilitiesInspectorViewDelegate?
    
    // MARK: - Setup
    
    public init(delegate: UtilitiesInspectorViewDelegate) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        tableView.register(cell: UtilitiesInspectorShareCell.self)
        tableView.register(cell: UtilitiesInspectorExportCell.self)
        tableView.register(cell: UtilitiesInspectorSceneSettingsCell.self)
        
        addSubview(tableView)
        tableView.fillInSuperview()
    }
    
    // MARK: - Public
    
    public func reloadData() {
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate

extension UtilitiesInspectorView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.utilitiesView(self, didSelectItemAtIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITableViewDataSource

extension UtilitiesInspectorView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UtilitiesInspectorView.numberOfItemsInSection
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return setupCell(with: indexPath)
    }
    
    private func setupCell(with indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: UtilitiesInspectorShareCell = tableView.dequeueReusableCell()
            return cell
        case 1:
            let cell: UtilitiesInspectorExportCell = tableView.dequeueReusableCell()
            return cell
        case 2:
            let cell: UtilitiesInspectorSceneSettingsCell = tableView.dequeueReusableCell()
            return cell
        default:
            fatalError("Index out of range.")
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UtilitiesInspectorView.cellHeight
    }
}
