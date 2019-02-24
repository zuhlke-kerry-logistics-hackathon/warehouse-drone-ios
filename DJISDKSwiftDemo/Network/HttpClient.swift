//
//  HttpClient.swift
//  DJI-Warehouse
//
//  Created by Brian Chung on 4/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import UIKit

final class HttpClient {
    static let shared = HttpClient()

    private init() {}

    func request<T: Codable>(
        method: HttpMethod,
        url: URL,
        type: T.Type,
        parameter: Data? = nil,
        contentType: String = "application/json",
        completion: ((_ response: T) -> Void)?) {

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(contentType, forHTTPHeaderField: "Accept")

        if let parameter = parameter {            
            urlRequest.httpBody = parameter
        }

        let urlSession = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard error == nil else {
                Logger.log(message: "Url request fail:\(error?.localizedDescription ?? "")", event: .error)
                return
            }

            guard let data = data else {
                Logger.log(message: "Missing response data", event: .error)
                return
            }

            let response = HttpResponse(data: data)
            guard let decodedModel = response.decode(type) else {
                Logger.log(message: "Unable to decode json to model", event: .error)
                return
            }
            completion?(decodedModel)
        }
        urlSession.resume()
    }

    func uploadImage<T: Codable>(
        method: HttpMethod = .post,
        url: URL,
        type: T.Type,
        paramName: String,
        fileName: String,
        image: UIImage,
        contentType: String = "multipart/form-data",
        completion: ((_ response: T) -> Void)?) {
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("\(contentType); boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var uploadData = Data()
        uploadData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
//        uploadData.append(image.pngData()!)
        uploadData.append(image.jpegData(compressionQuality: 0.7)!)
        uploadData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)        
        session.uploadTask(
            with: urlRequest,
            from: uploadData) { (data, urlResponse, error) in
                guard error == nil else {
                    Logger.log(message: "Fail to upload image", event: .error)
                    return
                }
                guard let data = data else {
                    Logger.log(message: "Missing response data", event: .error)
                    return
                }
                let response = HttpResponse(data: data)
                guard let decodedModel = response.decode(type) else {
                    Logger.log(message: "Unable to decode json to model", event: .error)
                    return
                }
                completion?(decodedModel)
        }.resume()
    }
}
