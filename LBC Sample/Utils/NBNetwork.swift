//
//  NBNetwork2.swift
//  NBNetwork2
//
//  Created by Nicolas Buquet on 18/09/2020.
//  Copyright © 2020 Nicolas Buquet. All rights reserved.
//

import Foundation


public class NBNetwork2: NSObject {
    public static let Reachability = try? NBReachability(hostname: "google.com")

//    public var didStartActivityAction: (() -> Void)?
//    public var didStopActivityAction: (() -> Void)?
    
    private var requests = [Int: Request]()
    private var dispatchGroup = [String: DispatchGroup]()
    public var session : URLSession!
    public var sessionDelegate: URLSessionDelegate?
    
    public override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 4
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    public required init(session: URLSession) {
        super.init()
        self.session = session
    }
    
    private func prepare(_ request: Request) {
        self.requests[request.identifier] = request
        if #available(iOS 11.0, *) {
            request.task.progress.addObserver(self,
                                              forKeyPath: "fractionCompleted",
                                              options: .new,
                                              context: UnsafeMutableRawPointer(Unmanaged.passUnretained(request).toOpaque()))
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if #available(iOS 11.0, *) {
     // from: https://stackoverflow.com/questions/33294620/how-to-cast-self-to-unsafemutablepointervoid-type-in-swift
            let req = Unmanaged<Request>.fromOpaque(context!).takeUnretainedValue()
      //  print("Change on \(keyPath): \(req.task.countOfBytesSent)")
        }
    }
    
    public func start(_ request: Request, progressAction: Request.ProgressAction? = nil, completeAction: @escaping Request.CompletionAction) {
        request.progressAction = progressAction
        request.completeAction = completeAction
        
        self.enterGroup(request: request)
        request.task.resume()
        
//        self.didStartActivityAction?()
    }
    
    private func clean(_ request: Request) {
        self.requests.removeValue(forKey: request.identifier)
    }

    //================================================================================
    // GET
    //================================================================================
    
    public func get(urlString: String, queryParameters: [String: String]? = nil, toFile: URL? = nil) -> Request? {
        guard let url = URL(string: urlString) else { return nil }
        return self.get(urlRequest: URLRequest(url: url), queryParameters: queryParameters, toFile: toFile)
    }

    public func get(urlRequest: URLRequest, queryParameters: [String: String]? = nil, toFile: URL? = nil) -> Request {
        let mutatedRequest = URLRequest(urlRequest, httpMethod: "GET", queryParameters: queryParameters)
        let req = toFile != nil ? Request(task: self.session.downloadTask(with: mutatedRequest)) : Request(task: self.session.dataTask(with: mutatedRequest))
        req.localStorageUrl = toFile
        self.prepare(req)
        
        return req
    }
    
    //================================================================================
    // DELETE
    //================================================================================
    
    public func delete(urlString: String, queryParameters: [String: String]? = nil) -> Request? {
        guard let url = URL(string: urlString) else { return nil }
        return self.delete(urlRequest: URLRequest(url: url), queryParameters: queryParameters)
    }

    public func delete(urlRequest: URLRequest, queryParameters: [String: String]? = nil) -> Request {
        let mutatedRequest = URLRequest(urlRequest, httpMethod: "DELETE", queryParameters: queryParameters)
        
        let req = Request(task: self.session.dataTask(with: mutatedRequest))
        self.prepare(req)
        
        return req
    }
    
    //================================================================================
    // POST QUERY STRING (NO BODY)
    //================================================================================
    
    public func post(urlString: String, queryParameters: [String: String]? = nil) -> Request? {
        guard let url = URL(string: urlString) else { return nil }
        return self.post(urlRequest: URLRequest(url: url), queryParameters: queryParameters)
    }
    
    public func post(urlRequest: URLRequest, queryParameters: [String: String]? = nil) -> Request {
        var mutatedRequest = URLRequest(urlRequest, httpMethod: "POST", queryParameters: queryParameters)
        
//        if let queryParameters = queryParameters,
//        queryParameters.count > 0 {
//            var queryString = ""
//            var separator = "?"
//            for (key, value) in queryParameters {
//                queryString += String(format: "%@%@=%@", separator, key, value)
//                separator = "&"
//            }
//            if let urlString = urlRequest.url?.absoluteString,
//                let percentQuery = queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            mutableRequest.url = URL(string: urlString + percentQuery)
//            }
//        }
        
        mutatedRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "content-type")
        
        let req = Request(task: self.session.dataTask(with: mutatedRequest))
        self.prepare(req)
        
        return req
    }
    
    //================================================================================
    // POST DATA
    //================================================================================
    
    public func post(urlString: String, queryParameters: [String: String]? = nil, dataBody: Data?, contentType: String? = nil) -> Request? {
        guard let url = URL(string: urlString) else { return nil }
        return self.post(urlRequest: URLRequest(url: url), queryParameters: queryParameters, dataBody: dataBody, contentType: contentType)
    }

    public func post(urlRequest: URLRequest, queryParameters: [String: String]? = nil, dataBody: Data?, contentType: String? = nil) -> Request {
        var mutatedRequest = URLRequest(urlRequest, httpMethod: "POST", queryParameters: queryParameters)
        
        mutatedRequest.httpBody = dataBody
        
        if let contentType = contentType {
            mutatedRequest.setValue(contentType, forHTTPHeaderField: "content-type")
        }
        
        let req = Request(task: self.session.dataTask(with: mutatedRequest))
        self.prepare(req)
        
        return req
    }
    
    //================================================================================
    // POST FILE
    //================================================================================
    
    public func post(urlString: String, queryParameters: [String: String]? = nil, fileUrl: URL) -> Request? {
        guard let url = URL(string: urlString) else { return nil }
        return self.post(urlRequest: URLRequest(url: url), queryParameters: queryParameters, fileUrl: fileUrl)
    }

    public func post(urlRequest: URLRequest, queryParameters: [String: String]? = nil, fileUrl: URL) -> Request {
        // Does not fill totalBytesExpected in progress delegate calls because body data is from a stream.
        // Use upload(file) to track progress precisely or construct data body fully.
        var mutatedRequest = URLRequest(urlRequest, httpMethod: "POST", queryParameters: queryParameters)
        
        mutatedRequest.httpBodyStream = InputStream(url: fileUrl)
        
        let req = Request(task: self.session.dataTask(with: mutatedRequest))
        self.prepare(req)
        
        return req
    }
    
    //================================================================================
    // UPLOAD DATA
    //================================================================================
    
    public func upload(urlString: String, queryParameters: [String: String]? = nil, data: Data) -> Request? {
        guard let url = URL(string: urlString) else { return nil }
        return self.upload(urlRequest: URLRequest(url: url), queryParameters: queryParameters, data: data)
    }

    public func upload(urlRequest: URLRequest, queryParameters: [String: String]? = nil, data: Data) -> Request {
        // Make request a POST request else, on iOS 13, an error -1103 will be raised: [-1103] Error Domain=NSURLErrorDomain Code=-1103 "resource exceeds maximum size"
        let mutatedRequest = URLRequest(urlRequest, httpMethod: "POST", queryParameters: queryParameters)
        
        
        let req = Request(task: self.session.uploadTask(with: mutatedRequest, from: data))
        self.prepare(req)
        
        return req
    }
    
    
    //================================================================================
    // UPLOAD FILE (BINARY, not MULTIPART)
    //================================================================================
    
    public func upload(urlString: String, queryParameters: [String: String]? = nil, fileUrl: URL) -> Request? {
        guard let url = URL(string: urlString) else { return nil }
        return self.upload(urlRequest: URLRequest(url: url), queryParameters: queryParameters, fileUrl: fileUrl)
    }

    public func upload(urlRequest: URLRequest, queryParameters: [String: String]? = nil, fileUrl: URL) -> Request {
        // Make request a POST request else, on iOS 13, an error -1103 will be raised: [-1103] Error Domain=NSURLErrorDomain Code=-1103 "resource exceeds maximum size"
        let mutatedRequest = URLRequest(urlRequest, httpMethod: "POST", queryParameters: queryParameters)
        
        let req = Request(task: self.session.uploadTask(with: mutatedRequest, fromFile: fileUrl))
        self.prepare(req)
        
        return req
    }

    //================================================================================
    // POST MULTIPART/FORM-DATA
    //================================================================================
    
    private func _httpBodyData(boundary: String, parameters: [String: String]?, filePaths: [String]?, fieldName: String?) -> Data {
        var httpBody = Data()
        
        if let parameters = parameters, parameters.count > 0 {
            for (key, value) in parameters {
                if let boundaryPart = String(format: "--%@\r\n", boundary).data(using: .utf8),
                    let keyPart = String(format: "Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key).data(using: .utf8),
                    let valuePart = String(format: "%@\r\n", value).data(using: .utf8) {
                    httpBody.append(boundaryPart)
                    httpBody.append(keyPart)
                    httpBody.append(valuePart)
                }
            }
        }
        
        if let filePaths = filePaths, filePaths.count > 0 {
            for path in filePaths {
                let filename = (path as NSString).lastPathComponent
                let mimeType = MimeType.from(filepath: path)
                
                if let boundaryPart = String(format: "--%@\r\n", boundary).data(using: .utf8),
                    let fieldName = fieldName,
                    let filenamePart = String(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename).data(using: .utf8),
                    let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    httpBody.append(boundaryPart)
                    httpBody.append(filenamePart)
                    if mimeType != MimeType.Unknown,
                        let mimeTypePart = String(format: "Content-Type: %@\r\n\r\n", mimeType).data(using: .utf8) {
                        httpBody.append(mimeTypePart)
                    }
                    httpBody.append(data)
                    httpBody.append("\r\n".data(using: .utf8)!)
                }
            }
        }
        
        httpBody.append(String(format: "--%@--\r\n", boundary).data(using: .utf8)!)
        
        return Data(httpBody)
    }


    public func postAsMultipart(urlString: String, queryParameters: [String: String]? = nil, parameters: [String: String]?, filePaths: [String]? = nil, fieldName: String? = nil) -> Request? {
        guard let url = URL(string: urlString) else { return nil }
        return self.postAsMultipart(urlRequest: URLRequest(url: url), queryParameters: queryParameters, parameters: parameters, filePaths: filePaths, fieldName: fieldName)
    }
    
    public func postAsMultipart(urlRequest: URLRequest, queryParameters: [String: String]? = nil, parameters: [String: String]?, filePaths: [String]? = nil, fieldName: String? = nil) -> Request {
        let boundary = String(format: "Boundary-%@", String.unique)
        
        var mutatedRequest = URLRequest(urlRequest, httpMethod: "POST", queryParameters: queryParameters)
        
        mutatedRequest.setValue(String(format: "multipart/form-data; boundary=%@", boundary), forHTTPHeaderField: "content-Type")
        
        let bodyData = self._httpBodyData(boundary: boundary, parameters: parameters, filePaths: filePaths, fieldName: fieldName)
        
        return self.upload(urlRequest: mutatedRequest, data: bodyData)
    }

    //================================================================================
    // Request class
    //================================================================================
    
    public class Request: NSObject {

        public typealias CompletionAction = (_ request: Request, _ response: HTTPURLResponse?, _ error: Error?) -> Void
        public typealias ProgressAction = (_ request: Request, _ bytesDone: Int64, _ totalBytesExpected: Int64) -> Void

        public let task: URLSessionTask
        public var groupId: String?
        public var dataReceived: Data?
        public var localStorageUrl: URL?
        
        fileprivate var progressAction: ProgressAction?
        fileprivate var completeAction: CompletionAction?
        fileprivate var identifier: Int { self.task.taskIdentifier }
        
        init(task: URLSessionTask, groupId: String? = nil) {
            self.task = task
            self.groupId = groupId
            super.init()
        }
        
        //================================================================================
        // STORE RETURNED DATA
        //================================================================================
        
        fileprivate func dataReceived(data: Data) {
            if self.dataReceived == nil {
                self.dataReceived = Data()
            }
            self.dataReceived!.append(data)
        }
        
        //================================================================================
        // TASK STATE
        //================================================================================
        
        public var stringReceived: String? {
            guard let dataReceived = self.dataReceived else { return nil }
            return String(data: dataReceived, encoding: .utf8)
        }
        
        public var jsonReceived: Any? {
            guard let dataReceived = self.dataReceived else { return nil }
            return dataReceived.json
        }
        
        public var response: HTTPURLResponse? {
            return self.task.response as? HTTPURLResponse
        }
    }
}

//================================================================================
// URLSessionTask Delegate
//================================================================================

extension NBNetwork2: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let req = self.requests[task.taskIdentifier] else { return }
        
        req.progressAction?(req, totalBytesSent, totalBytesExpectedToSend)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let req = self.requests[task.taskIdentifier] else { return }
        
        req.completeAction?(req, req.response, error)
//        self.didStopActivityAction?()
        self.leaveGroup(request: req)
        
        self.clean(req)
    }
}

//================================================================================
// URLSessionData Delegate
//================================================================================

extension NBNetwork2: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let req = self.requests[dataTask.taskIdentifier] else { return }

        req.dataReceived(data: data)
    }
}

//================================================================================
// URLSessionDownload Delegate
//================================================================================

extension NBNetwork2: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let req = self.requests[downloadTask.taskIdentifier] else { return }
        
       // req.localStorageUrl = location
        if let localStorageUrl = req.localStorageUrl {
            do {
                try? FileManager.default.removeItem(at: localStorageUrl)
                try FileManager.default.moveItem(at: location, to: localStorageUrl)
            }
            catch {
                
            }
        }

        req.completeAction?(req, req.response, nil)
//        self.didStopActivityAction?()
        self.leaveGroup(request: req)
        
        self.clean(req)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let req = self.requests[downloadTask.taskIdentifier] else { return }
        
        req.progressAction?(req, totalBytesWritten, totalBytesExpectedToWrite)
    }
}

//================================================================================
// URL Session Delegate methods
//================================================================================

extension NBNetwork2: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.sessionDelegate?.urlSession?(session, didBecomeInvalidWithError: error)
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        self.sessionDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if self.sessionDelegate?.urlSession(_:didReceive:completionHandler:) != nil {
            self.sessionDelegate!.urlSession?(session, didReceive: challenge, completionHandler: completionHandler)
        }
        else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

//================================================================================
// Dispatch group methods
//================================================================================

public extension NBNetwork2 {
    typealias GroupCompletionAction = (_ network: NBNetwork2, _ groupId: String) -> Void
    
    func declareGroup(groupId: String) {
        guard self.dispatchGroup[groupId] == nil else { return }
        let newGroup = DispatchGroup()
        // Don't set notify block here else it will be immediately called because the group is empty.
//        newGroup.notify(queue: .main) { completion() }
        self.dispatchGroup[groupId] = newGroup
    }
    
    func setGroupCompletion(groupId: String, completion:  @escaping GroupCompletionAction) {
        guard let group = self.dispatchGroup[groupId] else { return }
        group.notify(queue: .main) { completion(self, groupId) }
    }
    
    func removeGroup(groupId: String) {
        self.dispatchGroup.removeValue(forKey: groupId)
    }

    private func enterGroup(request: Request) {
        if let groupId = request.groupId,
           let requestGroup = self.dispatchGroup[groupId] {
            requestGroup.enter()
        }
    }
    
    private func leaveGroup(request: Request) {
        if let groupId = request.groupId,
           let requestGroup = self.dispatchGroup[groupId] {
            requestGroup.leave()
        }
    }
}

extension URLRequest {
//    convenience init(url: URL, queryParameters: [String: String]?) {
//        let req = init(url: url)
//        req.addQueryParameters(queryParameters)
//        return req
//    }
    
    fileprivate init(_ urlRequest: URLRequest, httpMethod: String?, queryParameters: [String: String]?) {
        self = urlRequest
        
        if let queryParameters = queryParameters,
           queryParameters.count > 0 {
            
            var queryString = ""
            var separator = "" // "?"
            for (key, value) in queryParameters {
                queryString += String(format: "%@%@=%@", separator, key, value)
                separator = "&"
            }
            if let queryParametersString = queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let urlString = self.url?.absoluteString {
                let join = urlString.contains("?") ? "&" : "?"
                self.url = URL(string: urlString + join + queryParametersString)
            }
        }
        
        if let httpMethod = httpMethod {
            self.httpMethod = httpMethod
        }
    }
}

public extension HTTPURLResponse {
    var statusCodeIsOk: Bool { return self.statusCode >= 200 && self.statusCode < 300 }
}
