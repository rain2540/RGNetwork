//
//  ViewController.swift
//  RGNetwork
//
//  Created by RAIN on 2017/4/21.
//  Copyright © 2017年 Smartech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let urlString = "http://web.juhe.cn:8080/environment/water/river"

    let params = [
        "river" :   "松花江流域",
        "key"   :   "8eb77a504db4a2b3511ed3c4d0964015",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadContent(_ sender: UIButton) {
/*
        RGNetwork.get(
            with: urlString,
            parameters: params,
            showIndicator: true,
            success: { (json, requestString, jsonString, httpStatusCode) in
                print("jsonString: ", jsonString)
                //RGToast.shared.toast(message: "get content success.")
        },
            fail: { (error, requestString) in
                print("error: \n", error ?? "get nil failed.")
                print("request string: \n", requestString)
                //RGToast.shared.toast(message: "get content failed.")
        })
        */
    }

    @IBAction func loadContentInfo(_ sender: UIButton) {
        
        RGNetwork.request(with: urlString,
                          parameters: params,
                          showIndicator: true,
                          responseType: .json,
                          success: { (json, string, data, httpStatusCode, request, response) in
                            print("json:", json ?? "")
                            print("string:", string ?? "")
                            print("response package:", response)

                            switch response {
                            case let .json(responseJSON):
                                print("response:", responseJSON)
                                
                            default: break
                            }
        },
                          failure: { (error, httpStatusCode, request, response)  in
                            print("error: \n", error ?? "get nil failed.")
        })
    }
}
