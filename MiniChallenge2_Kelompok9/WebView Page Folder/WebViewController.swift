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
    //MARK:- Member variables
    static let shared = WebViewController()

    var testUserData: InstagramTestUser?
    
    private let instagramAppID = "237800584310072"
    private let redirectURIURLEncoded = "https%3A%2F%2Fwww.google.com%2F"
    private let redirectURI = "https://www.google.com/"
    private let boundary = "boundary=\(NSUUID().uuidString)"
    private let app_secret = "b2b6850434d1740f8fb8acb0cde87ee0"
    
    var mainVC: mainPageViewController?

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
    
    struct InstagramUser: Codable {
        var id: String
        var username: String
    }
    
    struct InstagramMedia: Codable {
        struct InstagramCaption: Codable {
            let id: String
            let caption: String?
            let mediaType: String
            enum CodingKeys: String, CodingKey {
                case id
                case caption
                case mediaType = "media_type"
            }
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                caption = try container.decodeIfPresent(String.self, forKey: .caption)
                mediaType = try container.decode(String.self, forKey: .mediaType)
            }
        }
        let data: [InstagramCaption]
    }
    
    struct InstagramPicture: Codable {
        let mediaURL: String
        let timestamp: String
        enum CodingKeys: String, CodingKey {
            case mediaURL = "media_url"
            case timestamp
        }
    }
    
    struct TextResult: Codable {
        struct ResultText: Codable {
            let parsedText: String
            enum CodingKeys: String, CodingKey {
                case parsedText = "ParsedText"
            }
        }
        enum CodingKeys: String, CodingKey {
            case parsedResults = "ParsedResults"
        }
        let parsedResults: [ResultText]
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
    
    func getInstagramUsername(testUserData: InstagramTestUser, completion: @escaping (InstagramUser) -> Void) {
        let urlString = "\(BaseURL.graphApi.rawValue)\(testUserData.user_id)?fields=id,username&access_token=\(testUserData.access_token)"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
            do { let jsonData = try JSONDecoder().decode(InstagramUser.self, from: data!)
                completion(jsonData)
            }
            catch let error as NSError {
                print(error)
            }
        })
        dataTask.resume()
    }
    
    func getInstagramPostCaption(testUserData: InstagramTestUser, completion: @escaping (InstagramMedia) -> Void) {
        let urlString = "\(BaseURL.graphApi.rawValue)me/media?fields=id,caption,media_type&access_token=\(testUserData.access_token)"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
            do { let jsonData = try JSONDecoder().decode(InstagramMedia.self, from: data!)
                completion(jsonData)
            }
            catch let error as NSError {
                print(error)
            }
        })
        dataTask.resume()
    }
    
    func getInstagramMedia(mediaID: String, testUserData: InstagramTestUser, completion: @escaping (InstagramPicture) -> Void) {
        let urlString = "\(BaseURL.graphApi.rawValue)\(mediaID)?fields=id,media_type,media_url,username,timestamp&access_token=\(testUserData.access_token)"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
            do { let jsonData = try JSONDecoder().decode(InstagramPicture.self, from: data!)
                completion(jsonData)
            }
            catch let error as NSError {
                print(error)
            }
        })
        dataTask.resume()
    }
    
    func getTextFromPhoto(image: UIImage, completion: @escaping (TextResult) -> Void) {
        let imageData = image.jpegData(compressionQuality: 1)

        if(imageData==nil)  { return; }
        let parameters = [
            [
                "name": "language",
                "value": "eng"
            ],
            [
                "name": "isOverlayRequired",
                "value": "false"
            ]
        ]
        
        var request = URLRequest(url: URL(string: "https://api.ocr.space/parse/image")!)
        
        request.httpMethod = "POST"
        request.addValue("b139c8589c88957", forHTTPHeaderField: "apikey")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBodyWithParameters(parameters, filePathKey: "url", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
            print(String(data: data!, encoding: .utf8)!)
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                do { let jsonData = try JSONDecoder().decode(TextResult.self, from: data!)
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
    
    private func createBodyWithParameters(_ parameters: [[String : String]], filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();

        for param in parameters {
            let paramName = param["name"]!
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n")
            if let paramValue = param["value"] {
                body.appendString("\(paramValue)\r\n")
            }
        }

        let filename = "uploaded-image.jpg"

        let mimetype = "image/jpg"

        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString("\r\n")

        body.appendString("--\(boundary)--\r\n")

        return body
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webMain" {
            let navPage = segue.destination as! UINavigationController
            let mainPage = navPage.topViewController as! mainPageViewController
            mainPage.user = self.testUserData!
        }
    }
    
    func dismissViewController() {

        DispatchQueue.main.async {
//            weak var pvc = self.presentingViewController
//            if let pvc = self.presentingViewController as? mainPageViewController {
//                 pvc.user = self.testUserData!
//            }
//            self.dismiss(animated: true) {
//                self.mainVC?.user = self.testUserData!
//            }
            self.performSegue(withIdentifier: "webMain", sender: self)
//            let storyBoard : UIStoryboard = UIStoryboard(name: "mainPage", bundle:nil)
//            self.mainVC = storyBoard.instantiateViewController(withIdentifier: "mainLogin") as? mainPageViewController
//            self.present(self.mainVC!, animated:true, completion: nil)
        }
    }
}

extension NSMutableData {

    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
