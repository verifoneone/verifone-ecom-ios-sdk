//
//  ConfigurationParamsVC.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 09.05.2022.
//

import UIKit

protocol ConfigItem {}

struct TextField: ConfigItem {}

enum ConfigItemEnum {
    case textfield(TextField)
}

final class ConfigurationParamsVC: UIViewController, UITableViewDataSource {
    
    var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        return t
    }()
    
    var cells: [ConfigItemEnum] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        tableView.frame = CGRect(x: 0, y: 0, width: view!.frame.width, height: view!.frame.height)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "textfield")
        setup()
    }
    
    func setup() {
        cells.append(ConfigItemEnum.textfield(TextField()))
    }
}

extension ConfigurationParamsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = cells[indexPath.row]
        
        switch cellModel {
        case .textfield:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "textfield",
                for: indexPath) as! TextFieldTableViewCell
            cell.textfield.placeholder = "Public Key"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = cells[indexPath.row]
        
        switch cellModel {
        case .textfield:
            return 50.0
        }
    }
}

class TextFieldTableViewCell: UITableViewCell {
    
    var textfield: UITextField! = {
        let t = UITextField()
        t.borderStyle = .none
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(textfield)
        
        textfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true
        textfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10.0).isActive = true
        textfield.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -3.0).isActive = true
        textfield.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0).isActive = true
    }
}


// MARK: To do large textarea cell
