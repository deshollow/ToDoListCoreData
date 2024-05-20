//
//  TableViewController.swift
//  ToDoListCoreData
//
//  Created by deshollow on 20.05.2024.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var tasks: [Task] = []
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Please add new Task", preferredStyle: .alert)
        
        //сохранение Алерт
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let tf = alertController.textFields?.first
            if let newTaskTitle = tf?.text { //если пользователь вбил, это и есть новый таск
                self.saveTask(withTitle: newTaskTitle)
                
                self.tableView.reloadData() //перегружаем таблицу
            }
        }
        //кэнсэл Алерт
        alertController.addTextField { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in } //не используем хэндлер
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    //сохранение в CoreData
    private func saveTask(withTitle title: String) {
        let context = getContext() //добрались до контекста CoreData
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            return
        }
        let taskObject = Task(entity: entity, insertInto: context) //создали task-объект
        //помещаем заголовок в этот таск
        taskObject.title = title
        
        //сохраняем изменения в базу даннных
        do {
            try context.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //общий метод для получения context
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    //проверяем объекты хранящиеся в сущности Task
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        //создал запрос чтобы получить объекты хранящиеся по entity Task
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        //корректируем вывод
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //получаем объекты
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
// затереть данные для теста, во viewDidLoad
//        let context = getContext()
//        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
//        if let objects = try? context.fetch(fetchRequest) {
//            for object in objects {
//                context.delete(object)
//            }
//        }
//        do {
//            try context.save()
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        return cell
    }
}
