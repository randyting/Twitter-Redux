//
//  MenuViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/8/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    struct Constants {
        static let menuWidth = CGFloat(250)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "This is my title"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Camera, target: nil, action: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
