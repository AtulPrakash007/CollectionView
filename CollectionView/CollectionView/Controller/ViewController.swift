//
//  ViewController.swift
//  CollectionView
//
//  Created by Mac on 10/31/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var gaanaModel = GaanaModel()
    var result = [GaanaCategory]()
    
    lazy private var activityIndicator : CustomActivityIndicator = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicator(image: image, view: self.view.frame.size)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork(){
            
            self.view.addSubview(activityIndicator)
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            if result.count > 0 {
                print("Already Available")
                activityIndicator.stopAnimating()
            }else{
                gaanaModel.getItems()
                gaanaModel.gaanaModelDelegate = self
            }
        }else{
            ShowAlert("Info", message: "The App needs a working internet connection to function properly")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Action
    @IBAction func taskOneAction(_ sender: Any) {
        self.performSegue(withIdentifier: kShowListView, sender: self)
    }
    
    @IBAction func taskTwoAction(_ sender: Any) {
        self.performSegue(withIdentifier: kShowRecordView, sender: self)
    }
   
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case kShowListView:
             let destinationVC = segue.destination as! ListViewController
             destinationVC.gaanaData = self.result
            
        case kShowRecordView:
            print("Go To Record View")
            
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    func ShowAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        // Cancel button
        let cancel = UIAlertAction(title: "Ok", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - GaanaModelDelegate
extension ViewController:GaanaModelDelegate{
    func itemsDownloaded(result: [GaanaCategory]) {
        self.result = result
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
        print(self.result)
    }
}
