//
//  MoveAnimationLocationCell.swift
//  SceneKit-Grid-Experiment
//
//  Created by Trevin Wisaksana on 14/10/18.
//  Copyright © 2018 Trevin Wisaksana. All rights reserved.
//

import UIKit
import SceneKit

public protocol MoveAnimationLocationCellDelegate: class {
    func moveAnimationLocationCell(_ moveAnimationLocationCell: MoveAnimationLocationCell, didUpdateAnimationLocation location: SCNVector3)
}

public class MoveAnimationLocationCell: UITableViewCell {
    
    // MARK: - Internal properties
    
    private static let titleHeight: CGFloat = 20.0
    private static let titleTopMargin: CGFloat = 15.0
    private static let titleLeftMargin: CGFloat = 15.0
    
    private static let currentLocationTitleTopMargin: CGFloat = 15.0
    private static let currentLocationTitleLeftMargin: CGFloat = 15.0
    
    private static let currentCoordinateContainerTopMargin: CGFloat = 8.0
    private static let currentCoordinateContainerLeftMargin: CGFloat = 15.0
    private static let currentCoordinateContainerRightMargin: CGFloat = -15.0
    
    private static let targetLocationTitleTopMargin: CGFloat = 15.0
    private static let targetLocationTitleLeftMargin: CGFloat = 15.0
    
    private static let targetCoordinateContainerTopMargin: CGFloat = 8.0
    private static let targetCoordinateContainerLeftMargin: CGFloat = 15.0
    private static let targetCoordinateContainerRightMargin: CGFloat = -15.0
    
    private lazy var locationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Target Location"
        return label
    }()
    
    private lazy var xCoordinateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "X:"
        return label
    }()
    
    private lazy var yCoordinateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Y:"
        return label
    }()
    
    private lazy var zCoordinateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Z:"
        return label
    }()
    
    private lazy var targetCoordinateTextFieldContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [targetXCoordinateTextField, targetYCoordinateTextField, targetZCoordinateTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var targetXCoordinateTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(didFinishEditingCoordinateTextField(_:)), for: .editingDidEnd)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var targetYCoordinateTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(didFinishEditingCoordinateTextField(_:)), for: .editingDidEnd)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var targetZCoordinateTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(didFinishEditingCoordinateTextField(_:)), for: .editingDidEnd)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    // MARK: - External Properties
    
    weak var delegate: MoveAnimationLocationCellDelegate?
    
    // MARK: - Setup
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(locationTitleLabel)
        addSubview(targetCoordinateTextFieldContainer)
        
        NSLayoutConstraint.activate([
            locationTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: MoveAnimationLocationCell.titleLeftMargin),
            locationTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: MoveAnimationLocationCell.titleTopMargin),
            locationTitleLabel.heightAnchor.constraint(equalToConstant: MoveAnimationLocationCell.titleHeight),
            
            targetCoordinateTextFieldContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            targetCoordinateTextFieldContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: MoveAnimationLocationCell.targetCoordinateContainerLeftMargin),
            targetCoordinateTextFieldContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: MoveAnimationLocationCell.targetCoordinateContainerRightMargin),
            targetCoordinateTextFieldContainer.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: MoveAnimationLocationCell.targetCoordinateContainerTopMargin),
        ])
    }
    
    // MARK: - Text Field Interactions
    
    @objc
    private func didFinishEditingCoordinateTextField(_ sender: UITextField) {
        guard let xCoordinate = Double(targetXCoordinateTextField.text ?? "0.0"),
              let yCoordinate = Double(targetYCoordinateTextField.text ?? "0.0"),
              let zCoordinate = Double(targetZCoordinateTextField.text ?? "0.0")
        else {
            return
        }
        
        let updatedLocation = SCNVector3(xCoordinate, yCoordinate, zCoordinate)
        delegate?.moveAnimationLocationCell(self, didUpdateAnimationLocation: updatedLocation)
    }
    
    // MARK: - Dependency injection
    
    /// The model contains data used to populate the view.
    public var model: MoveAnimationAttributesViewModel? {
        didSet {
            if let model = model {
                targetXCoordinateTextField.text = "\(model.targetLocation.x)"
                targetYCoordinateTextField.text = "\(model.targetLocation.y)"
                targetZCoordinateTextField.text = "\(model.targetLocation.z)"
            }
        }
    }
    
}
