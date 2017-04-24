//
//  ViewController.swift
//  RGNetwork
//
//  Created by RAIN on 2017/4/21.
//  Copyright © 2017年 Smartech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toast(_ sender: UIButton) {
        let params = ["river"   :   "松花江流域",
                      "key"     :   "8eb77a504db4a2b3511ed3c4d0964015"]

        RGNetwork.get(
            with: "http://web.juhe.cn:8080/environment/water/river",
            parameters: params,
            showProgress: true,
            success: { (json, requestString, jsonString, httpStatusCode) in
                print(jsonString)
        },
            fail: { (error, requestString) in
                print("error: \n", error ?? "get nil failed.")
                print("request string: \n", requestString)
        })
    }

}

