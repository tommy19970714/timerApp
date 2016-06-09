//
//  ViewController.swift
//  todo2
//
//  Created by 冨平準喜 on 2015/08/14.
//  Copyright © 2015年 冨平準喜. All rights reserved.
//
import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myButtonWrite: UIButton!
    @IBOutlet weak var myTableView: UITableView!

    
    // Tableで使用する配列を設定する.
    var myItems: [NSString] = []
    var myTimes: [NSString] = []
    
    var cnt : Float = 0
    var myLabel : UILabel!
    var timer : NSTimer!
    var myButton : UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        //myTextField
        
        //myButtonWrite
        
        //myButtonRead
        
        //myTableView
        
        myTableView.delegate = self
        myTableView.dataSource = self

        readData()
        
        // ラベルを作る.
        myLabel = UILabel(frame: CGRectMake(0,0,200,50))
        myLabel.backgroundColor = UIColor.orangeColor()
        myLabel.layer.masksToBounds = true
        myLabel.layer.cornerRadius = 20.0
        myLabel.text = "Time:\(cnt/60)分\(cnt%60)"
        myLabel.textColor = UIColor.whiteColor()
        myLabel.shadowColor = UIColor.grayColor()
        myLabel.textAlignment = NSTextAlignment.Center
        myLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 50)
        //self.view.backgroundColor = UIColor.cyanColor()
        self.view.addSubview(myLabel)
        
        // タイマー停止ボタンを作る.
        myButton = UIButton(frame: CGRectMake(0, 0, 200, 50))
        myButton.layer.masksToBounds = true
        myButton.layer.cornerRadius = 20.0
        myButton.backgroundColor = UIColor.blueColor()
        myButton.setTitle("Start Timer", forState: UIControlState.Normal)
        myButton.layer.position = CGPointMake(self.view.center.x, 130)
        myButton.addTarget(self, action: "onMyButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(myButton)
        
        // タイマーを作る.
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "onUpdate:", userInfo: nil, repeats: false)
        cnt = -0.1
    }
    
    //returning to view
    override func viewWillAppear(animated: Bool) {
        myTableView.reloadData();
    }
    
    /*
    ボタンイベント
    */
    @IBAction func writeButton_Click(sender: UIButton) {
        writeData()
        readData()
    }
    
    @IBAction func resetButton(sender: AnyObject) {
        // timerを破棄する
        timer.invalidate()
        cnt = 0
        
        // ボタンのタイトル変更.
        myButton.setTitle("Start Timer", forState: UIControlState.Normal)
        
        // 桁数を指定して文字列を作る.
        let str = "Time:\(Int(cnt/60))分".stringByAppendingFormat("%.1f",cnt%60)+"秒"
        myLabel.text = str
        
    }
    
    
    /*
    ボタンが押された時に呼ばれるメソッド
    */
    func onMyButtonClick(sender : UIButton){
        
        // timerが動いてるなら
        if timer.valid == true {
            
            // timerを破棄する
            timer.invalidate()
            
            // ボタンのタイトル変更.
            sender.setTitle("Start Timer", forState: UIControlState.Normal)
        }
        else{
            
            // timerを生成する.
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "onUpdate:", userInfo: nil, repeats: true)
            
            // ボタンのタイトル変更.
            sender.setTitle("Stop Timer", forState: UIControlState.Normal)
        }
    }
    func kirisute(d: Float) -> Float{
        return Float(Int(d * 100.0)) / 100.0
    }
    
    // NSTimerIntervalで指定された秒数毎に呼び出されるメソッド.
    func onUpdate(timer : NSTimer){
        
        cnt += 0.1
        
        // 桁数を指定して文字列を作る.
        let str = "Time:\(Int(cnt/60))分".stringByAppendingFormat("%.1f",cnt%60)+"秒"
        myLabel.text = str
    }
    
    
    /*
    CoreDataへのデータ書き込み
    */
    func writeData(){
        // CoreDataへの書き込み処理.
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        
        let myEntity: NSEntityDescription! = NSEntityDescription.entityForName("TaskData", inManagedObjectContext: myContext)
        
        let newData = TaskData(entity: myEntity, insertIntoManagedObjectContext: myContext)
        newData.task = "\(Int(cnt/60))分".stringByAppendingFormat("%.1f",cnt%60)+"秒"
        newData.disc = ""
        
        try! myContext.save()
    }
    
    /*
    CoreDataからのデータ読み込み.
    */
    func readData(){
        // CoreDataの読み込み処理.
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        
        let myRequest: NSFetchRequest = NSFetchRequest(entityName: "TaskData")
        myRequest.returnsObjectsAsFaults = false
        
        var myResults: NSArray!
        //var myResults: NSArray! = myContext.executeFetchRequest(myRequest, error: nil)
        
        do {
            myResults = try myContext.executeFetchRequest(myRequest)
            // success ...
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        myItems = []
        myTimes = []
        
        for myData in myResults {
            myItems.append(myData.valueForKey("task") as! String)
            myTimes.append(myData.valueForKey("disc") as! String)
            
            print(myData.valueForKey("task") as! String)
            print(myData.valueForKey("disc") as! String)
        }
        
        myTableView.reloadData()
    }
    
    func deleteData(deleteString: NSString)
    {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "TaskData")
        if let fetchResults = try!managedObjectContext.executeFetchRequest(fetchRequest) as? [TaskData] {
            for (var i=0; i<fetchResults.count; i++) {
                if fetchResults[i].task ==  deleteString{
                    managedObjectContext.deleteObject(fetchResults[i])
                    try!managedObjectContext.save()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //UITableViewDataSource
    func tableView(tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    //Editableの状態にする.
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "test")
        cell.textLabel?.text = myItems[indexPath.row] as String
        cell.detailTextLabel?.text = myTimes[indexPath.row] as String
        
        return cell
    }
    
    //UITableViewDelete
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            
            deleteData(myItems[indexPath.row])
            
            myItems.removeAtIndex(indexPath.row)
            myTableView.reloadData();
            
        }
        
    }
}

