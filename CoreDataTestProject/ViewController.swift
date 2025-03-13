//
//  ViewController.swift
//  CoreDataTestProject
//
//  Created by wangshixue on 2025/2/12.
//

import UIKit

class ViewController: UIViewController {
    let tableView = UITableView()
    var dataArray: [User] = []
    var selectUserId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let addBtn = UIButton()
        addBtn.setTitle("增加", for: .normal)
        addBtn.backgroundColor = .orange
        view.addSubview(addBtn)
        addBtn.frame = CGRectMake(50, 64, 50, 50)
        addBtn.addTarget(self, action: #selector(clickAdd), for: .touchUpInside)
        
        let deleteBtn = UIButton()
        deleteBtn.setTitle("删除", for: .normal)
        deleteBtn.backgroundColor = .red
        view.addSubview(deleteBtn)
        deleteBtn.frame = CGRectMake(150, 64, 50, 50)
        deleteBtn.addTarget(self, action: #selector(clickDel), for: .touchUpInside)
        
        let updateBtn = UIButton()
        updateBtn.setTitle("修改", for: .normal)
        updateBtn.backgroundColor = .gray
        view.addSubview(updateBtn)
        updateBtn.frame = CGRectMake(250, 64, 50, 50)
        updateBtn.addTarget(self, action: #selector(updateRow), for: .touchUpInside)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = CGRectMake(0, 130, 375, 600)
        reloadData()
    }
    
    func fetch_list() -> [User]? {
        let sortByUser_id = NSSortDescriptor(key: "update_time", ascending: false)
        return CoreDataManager_.shared.fetch(offset: 0, limit: 20, sorts: [sortByUser_id])
    }
    
    func reloadData() {
        dataArray = CoreDataManager_.shared.fetch()
        if let list = fetch_list() {
            dataArray = list
        }
        tableView.reloadData()
    }
    
    @objc func clickAdd() {
        let currentTimeStampInt = Int(Date().timeIntervalSince1970)
        let userId = Int.random(in: 10000...99999)
        let randomString = generateRandomString(length: 5)
        CoreDataManager_.shared.add(User.self) { item in
            item.user_id = Int64(userId)
            item.name = randomString
            item.last_msg = ""
            item.update_time = Int64(currentTimeStampInt)
        }
        
        reloadData()
    }
    
    @objc func clickDel() {
        // 多条件
        //        let predicate = NSPredicate(format: "user_id == %lld AND name == %@", selectUserId, ""”)
        //        let predicate = NSPredicate(format: "(sender_id == %lld AND receive_id == %lld) OR (sender_id == %lld AND receive_id == %lld) AND login_user_id == %lld", sender_id, receive_id, receive_id, sender_id, login_user_id)
        let predicate = NSPredicate(format: "user_id=%lld", selectUserId)
        CoreDataManager_.shared.delete(User.self, predicate: predicate)
        selectUserId = 0
        reloadData()
    }
    
    @objc func updateRow() {
        let predicate = NSPredicate(format: "user_id=%lld", selectUserId)
        let randomString = generateRandomString(length: 5)
        _ = CoreDataManager_.shared.update(User.self, predicate: predicate) { item in
            item.last_msg = randomString
            let currentTimeStampInt = Int(Date().timeIntervalSince1970)
            item.update_time = Int64(currentTimeStampInt)
        }
        selectUserId = 0
        reloadData()
    }
    
    func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 0..<length {
            let randomIndex = Int(arc4random_uniform(UInt32(letters.count)))
            let index = letters.index(letters.startIndex, offsetBy: randomIndex)
            randomString.append(letters[index])
        }
        
        return randomString
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let user = dataArray[indexPath.row]
        cell.textLabel?.text = "\(String(describing: user.name)) \(user.user_id) \(String(describing: user.last_msg))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = dataArray[indexPath.row]
        self.selectUserId = Int(user.user_id)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 创建删除按钮
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { (action, view, completionHandler) in
            // 从数据源中删除项
            let user = self.dataArray[indexPath.row]
            CoreDataManager_.shared.delete(User.self, predicate: NSPredicate(format: "user_id=%lld", user.user_id))
            self.dataArray.remove(at: indexPath.row)
            // 更新表格视图
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        // 设置删除按钮的图标
        deleteAction.image = UIImage(systemName: "trash.fill") // 使用 SF Symbols 图标
        deleteAction.backgroundColor = .red // 设置背景颜色
        
        let moreAction = UIContextualAction(style: .normal, title: "更多") { (action, view, completionHandler) in
            // 处理更多操作
            print("更多操作被触发")
            completionHandler(true)
        }
        moreAction.image = UIImage(systemName: "ellipsis") // 使用 SF Symbols 图标
        moreAction.backgroundColor = .blue // 设置背景颜色
        
        // 返回配置
        return UISwipeActionsConfiguration(actions: [deleteAction, moreAction])
    }
}

