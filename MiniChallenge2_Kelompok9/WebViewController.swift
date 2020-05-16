//
//  WebViewController.swift
//  InstaApp Storyboard
//
//  Created by Tushar Gusain on 02/12/19.
//  Copyright © 2019 Hot Cocoa Software. All rights reserved.
//

import Foundation
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
//    var instagramApi: InstagramApi?

    var testUserData: InstagramTestUser?
    
    private let instagramAppID = "237800584310072"
    private let redirectURIURLEncoded = "https%3A%2F%2Fwww.google.com%2F"
    private let redirectURI = "https://www.google.com/"
    private let boundary = "boundary=\(NSUUID().uuidString)"
    private let app_secret = "438e96746b6e77e0175965b12210d3e5"
    
//    var mainVC: ViewController?

    @IBOutlet weak var popWeb: WKWebView! {
        didSet {
            popWeb.navigationDelegate = self

        }
    }
    
    //MARK:- Enums
    private enum BaseURL: String {
        case displayApi = "https://api.instagram.com/"
        case graphApi = "https://graph.instagram.com/"
    }
    private enum Method: String {
        case authorize = "oauth/authorize"
        case access_token = "oauth/access_token"
    }
    
    //MARK:- Instagram Users
    struct InstagramTestUser: Codable {
        var access_token: String
        var user_id: Int
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authorizeApp { (url) in
            DispatchQueue.main.async {
                self.popWeb.load(URLRequest(url: url!))
            }
        }
    }
    
    //MARK:- Public Methods

    func authorizeApp(completion: @escaping (_ url: URL?) -> Void ) {
        let urlString = "\(BaseURL.displayApi.rawValue)\(Method.authorize.rawValue)?client_id=\(instagramAppID)&redirect_uri=\(redirectURIURLEncoded)&scope=user_profile,user_media&response_type=code"
        
        let request = URLRequest(url: URL(string: urlString)!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response {
                print(response)
                completion(response.url)
            }
        })
        task.resume()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        self.getTestUserIDAndToken(request: request) { [weak self] (instagramTestUser) in
            self?.testUserData = instagramTestUser
            self?.dismissViewController()
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func getTestUserIDAndToken(request: URLRequest, completion: @escaping (InstagramTestUser) -> Void){
        
        guard let authToken = getTokenFromCallbackURL(request: request) else {
            return
        }
        
        let headers = [
            "content-type": "multipart/form-data; boundary=\(boundary)"
        ]
        let parameters = [
            [
                "name": "client_id",
                "value": instagramAppID
            ],
            [
                "name": "client_secret",
                "value": app_secret
            ],
            [
                "name": "grant_type",
                "value": "authorization_code"
            ],
            [
                "name": "redirect_uri",
                "value": redirectURI
            ],
            [
                "name": "code",
                "value": authToken
            ]
        ]
        
        var request = URLRequest(url: URL(string: BaseURL.displayApi.rawValue + Method.access_token.rawValue)!)
        
        let postData = getFormBody(parameters, boundary)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if (error != nil) {
                print(error!)
            } else {
                do { let jsonData = try JSONDecoder().decode(InstagramTestUser.self, from: data!)
                    print(jsonData)
                    completion(jsonData)
                }
                catch let error as NSError {
                    print(error)
                }
                
            }
        })
        dataTask.resume()
    }
    
    private func getTokenFromCallbackURL(request: URLRequest) -> String? {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.starts(with: "\(redirectURI)?code=") {
            
            print("Response uri:",requestURLString)
            if let range = requestURLString.range(of: "\(redirectURI)?code=") {
                return String(requestURLString[range.upperBound...].dropLast(2))
            }
        }
        return nil
    }
    
    //MARK:- Private Methods
    private func getFormBody(_ parameters: [[String : String]], _ boundary: String) -> Data {
       var body = ""
       let error: NSError? = nil
       for param in parameters {
           let paramName = param["name"]!
           body += "--\(boundary)\r\n"
           body += "Content-Disposition:form-data; name=\"\(paramName)\""
           if let filename = param["fileName"] {
               let contentType = param["content-type"]!
               var fileContent: String = ""
               do { fileContent = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)}
               catch {
                   print(error)
               }
               if (error != nil) {
                   print(error!)
               }
               body += "; filename=\"\(filename)\"\r\n"
               body += "Content-Type: \(contentType)\r\n\r\n"
               body += fileContent
           } else if let paramValue = param["value"] {
               body += "\r\n\r\n\(paramValue)"
           }
       }
       return body.data(using: .utf8)!
    }
    
    func dismissViewController() {

        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.testUserData = self.testUserData!
            }
        }
    }
}
