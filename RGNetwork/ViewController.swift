//
//  ViewController.swift
//  RGNetwork
//
//  Created by RAIN on 2017/4/21.
//  Copyright © 2017年 Smartech. All rights reserved.
//

import UIKit
import Alamofire

private let CellIdentifier = "DefaultCell"

final class ViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!

  private let urlString = "http://web.juhe.cn:8080/environment/water/river"

  private let params = [
    "river" :   "松花江流域",
    "key"   :   "8eb77a504db4a2b3511ed3c4d0964015",
  ]

  private lazy var requestInfos = RequstInfo.list


  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }


  // MARK: - Event

  private func loadByNetwork() {
    let config = RGDataRequestConfig(urlString: urlString, parameters: params)
    RGNetwork.request(
      config: config,
      showIndicator: true,
      responseType: .json,
      success: { (json, string, data, httpStatusCode, request, responsePackage) in
        switch responsePackage {
        case let .data(responseJSON):
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
      })
  }

  private func loadByNetworkDecodable() {
    let config = RGDataRequestConfig(urlString: urlString, parameters: params)
    RGNetwork.requestDecodable(of: Test.self, config: config, showIndicator: true) { obj, string, data, httpStatusCode, request, response in
      guard let test = obj else { return }
      print("Test: ", test)
    } failure: { error, string, data, httpStatusCode, request, response in
      print("error: \n", error ?? "get nil failed.")
    }
  }

  private func loadByDataRequest() {
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
      })
  }

  private func loadBySessionCallback() {
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    do {
      let body = try JSONSerialization.data(withJSONObject: params)
      request.httpBody = body
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else { return }
        do {
          let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
          print(json)
        } catch {
          print(error)
        }
      }
      task.resume()

    } catch {
      print(error)
    }
  }

  @available(iOS 15.0, *)
  private func loadBySessionAsync() {
    Task {
      guard let request = await createRequest() else { return }
      let (data, response) = try await URLSession.shared.data(for: request)
      let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
      print(json)
      print(response)
    }
  }

  @available(iOS 13.0.0, *)
  private func createRequest() async -> URLRequest? {
    guard let url = URL(string: urlString) else { return nil }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    do {
      let body = try JSONSerialization.data(withJSONObject: params)
      request.httpBody = body
      return request
    } catch {
      print(error)
      return nil
    }
  }

  @available(iOS 13.0, *)
  private func loadByAlamofireAsync() {
    Task {
      let dataRequest = AF.request(
        urlString,
        method: .get,
        parameters: params,
        encoding: URLEncoding.default
      )
      let dataTask = dataRequest.serializingData()
      guard let data = await dataTask.response.value else { return }
      let string = String(data: data, encoding: .utf8) ?? "get string failed."
      print(string)
    }
  }

}


// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return requestInfos.count
  }

  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: CellIdentifier,
      for: indexPath
    )
    let requestInfo = requestInfos[indexPath.row]
    cell.textLabel?.text = requestInfo.rawValue
    return cell
  }

}


// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

  func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    tableView.deselectRow(at: indexPath, animated: true)
    let requestInfo = requestInfos[indexPath.row]
    switch requestInfo {
    case .rgNetwork:
      loadByNetwork()

    case .rgNetworkDecodable:
      loadByNetworkDecodable()

    case .rgDataRequest:
      loadByDataRequest()

    case .urlSessionCallback:
      loadBySessionCallback()

    case .urlSessionAsync:
      if #available(iOS 15.0, *) {
        loadBySessionAsync()
      } else {
        print("此方法在该系统版本无法使用")
      }

    case .alamofireAsync:
      if #available(iOS 13.0, *) {
        loadByAlamofireAsync()
      } else {
        print("此方法在该系统版本无法使用")
      }
    }
  }

  func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath
  ) -> CGFloat {
    return 44.0
  }

}


struct Test: Codable {

  var resultcode: String
  var reason: String
  var result: [String]
  var error_code: Int
  /*
   enum CodingKeys: String, CodingKey {
   case resultcode = "resultcode"
   case reason = "reason"
   case result = "result"
   case errorCode = "error_code"
   }
   */
}
