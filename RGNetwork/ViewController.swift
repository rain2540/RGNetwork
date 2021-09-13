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
        /*RGNetwork.request(with: urlString,
                          parameters: params,
                          showIndicator: true,
                          responseType: .json,
                          success: { (json, string, data, httpStatusCode, request, response) in
                            print("\n/* ***** ***** ***** ***** */\n")
                            print("JSON:", json ?? "", separator: "\n")
                            print("\n/* ***** ***** ***** ***** */\n")
                            print("string:", string ?? "", separator: "\n")
                            print("\n/* ***** ***** ***** ***** */\n")
        },
                          failure: { (error, httpStatusCode, request, response)  in
                            print("error: \n", error ?? "get nil failed.")
        })
        */
        let request = RGDataRequest(urlString: urlString, parameters: params)
        request.task(
            showIndicator: true,
            responseType: .json,
            success: { (json, string, data, httpStatusCode, request, responsePackage) in
                print("\n/* ***** ***** ***** ***** */\n")
                print("JSON:", json ?? "", separator: "\n")
                print("\n/* ***** ***** ***** ***** */\n")
                print("string:", string ?? "", separator: "\n")
                print("\n/* ***** ***** ***** ***** */\n")
            },
            failure: { (error, resString, resData, httpStatusCode, request, response)  in
                print("error: \n", error ?? "get nil failed.")
            }
        )
    }

    @IBAction func loadContentInfo(_ sender: UIButton) {
        let config = RGDataRequestConfig(urlString: urlString, parameters: params)
        RGNetwork.request(
            config: config,
            showIndicator: true,
            responseType: .json,
            success: { (json, string, data, httpStatusCode, request, responsePackage) in
                switch responsePackage {
                    case let .json(responseJSON):
                        print("\n/* ***** ***** ***** ***** */\n")
                        print("response:", responseJSON, separator: "\n")
                        print("\n/* ***** ***** ***** ***** */\n")
                        print("metrics:", responseJSON.metrics ?? "none", separator: "\n")
                        print("\n/* ***** ***** ***** ***** */\n")
                    default: break
                }
            },
            failure: { (error, resString, resData, httpStatusCode, request, response)  in
                print("error: \n", error ?? "get nil failed.")
            }
        )
    }
}
