//
//  CoreDataManager_.swift
//  Axolotl
//
//  Created by WangShiXue on 2024/12/4.
//

import Foundation
import CoreData

protocol AvailablePersistent {
   static var entity_name: String { get }
}

class CoreDataManager_ {
    /// 单例
    static let shared = CoreDataManager_()
    /// 持久化容器
    private var container: NSPersistentContainer!
    
    /// 配置
    func init_database() {
        container = .init(name: "CoreDataTestProject")
        container.loadPersistentStores { description, error in
            if error != nil {
                print("数据库加载失败")
            } else {
                print("数据库加载成功")
            }
        }
    }
    
    /// 增
    /// - Parameters:
    ///   - entity: 实体类型
    ///   - transform: 修改实体对象回调
    /// - Returns: 新实体对象
    @discardableResult
    func add<T: NSManagedObject>(_ entity: T.Type, transform: (inout T) -> Void) -> T? where T : AvailablePersistent {
        let context = container.viewContext
        let entity_name = entity.entity_name
        if let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: entity_name, in: context) {
            // 创建新item
            var item: T = .init(entity: entity, insertInto: context)
            // 用于外部赋值数据
            transform(&item)
            
            do {
                if context.hasChanges {
                    try context.save()
                }
                return item
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /// 删除
    /// - Parameters:
    ///   - entity: 实体类型
    ///   - predicate: 谓语（条件）
    func delete<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate? = nil) where T : AvailablePersistent {
        let context = container.viewContext
        let request = T.fetchRequest()
        
        // 设置谓语
        if predicate != nil {
            request.predicate = predicate
        }
        
        do {
            let result = try container.viewContext.fetch(request)
            
            if !result.isEmpty {
                for item in result {
                    context.delete(item as! NSManagedObject)
                }
            }
            
            if context.hasChanges {
                try context.save()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// 查询
    /// - Parameters:
    ///   - predicate: 谓语（查询条件）
    ///   - sorts: 排序
    /// - Returns: 查询结果
    func fetch<T: NSManagedObject>(predicate: NSPredicate? = nil, sorts: [NSSortDescriptor] = []) -> [T] where T : AvailablePersistent {
        let request = T.fetchRequest()
        // 设置谓语
        if predicate != nil {
            request.predicate = predicate
        }
        
        // 设置排序方式
        if !sorts.isEmpty {
            request.sortDescriptors = sorts
        }
        
        do {
            let result = try container.viewContext.fetch(request)
            return result.map { $0 as! T }
        } catch let error {
            print(error.localizedDescription)
        }
        return []
    }
    
    /// 分页查询
    /// - Parameters:
    ///   - offset: 偏移
    ///   - limit: 最大查询数量
    ///   - predicate: 谓语（查询条件）
    ///   - sorts: 排序
    /// - Returns: 查询结果
    func fetch<T: NSManagedObject>(offset: Int, limit: Int, predicate: NSPredicate? = nil, sorts: [NSSortDescriptor] = []) -> [T] where T : AvailablePersistent {
        let request = T.fetchRequest()
        // 分页参数
        request.fetchOffset = offset
        request.fetchLimit = limit
        
        // 设置谓语
        if predicate != nil {
            request.predicate = predicate
        }
        
        // 设置排序方式
        if !sorts.isEmpty {
            request.sortDescriptors = sorts
        }
        
        do {
            let result = try container.viewContext.fetch(request)
            return result.map { $0 as! T }
        } catch let error {
            print(error.localizedDescription)
        }
        return []
    }
    
    /// 改
    /// - Parameters:
    ///   - predicate: 谓语（查询条件）
    /// - Returns: 查询结果    
    func update<T: NSManagedObject & AvailablePersistent>(
        _ entity: T.Type,
        predicate: NSPredicate? = nil,
        transform: (inout T) -> Void
    ) -> Bool {
        guard let container = container else { return false }

        let context = container.viewContext
        let request = T.fetchRequest()
        request.predicate = predicate

        do {
            // 查找满足条件的结果
            let results = try context.fetch(request)
            guard let targetObject = results.first as? T else {
                print("没有找到要更新的数据")
                return false
            }

            // 传递可变的对象
            var item = targetObject
            transform(&item)

            // 保存上下文中的更改
            if context.hasChanges {
                try context.save()
                print("数据更新成功")
                return true
            }
        } catch {
            print("数据更新失败: \(error.localizedDescription)")
        }

        return false
    }
}
