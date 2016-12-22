//
//  SDImageCacheTests.swift
//  walmart
//
//  Created by Steven Riggins on 3/10/16.
//  Copyright © 2016 Walmart. All rights reserved.
//

import XCTest
import ELFoundation

class SDImageCacheTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear any caches before these tests run
        URLCache.shared.removeAllCachedResponses()
        URLProtocol.registerClass(ImageCacheDataProvider.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        URLProtocol.unregisterClass(ImageCacheDataProvider.self)
    }
    
    // This test uses implementation details to test
    func testActiveConnections() {
        let imageCache = SDImageCache()
        let urlString = "https://www.testurl.com/test"
        let url = NSURL(string: urlString)
        let request = NSURLRequest(url: url! as URL)
        let connection = SDURLConnection(request: request as URLRequest, delegate: nil)
        let connections = imageCache.activeConnectionsForTesting()
        
        imageCache.cacheConnection(connection, for: url! as URL!)
        XCTAssert(connections?.object(forKey: urlString) != nil, "connection not found in active connections")
        
        imageCache.removeConnectionForURL(fromCache: url! as URL!)
        XCTAssert(connections?.object(forKey: urlString) == nil, "connection found in active connections")

    }

    // This test uses implementation details to test
    // This test uses a custom NSURLProtocol to load imagecache:// image and return it to the SDURLConnection
    // utilized in SDImageCache
    // This test was developed to make sure that a memory leak fix actually fixed the memory leak
    func testFileURLActiveConnections() {
        let imageCache = SDImageCache()
        let urlString = "imagecache://localhost/ios-shared-test-image.png"
        let url = NSURL(string: urlString)
        let connections = imageCache.activeConnectionsForTesting()
        var imageFetched = false
        var connectionNotFound = false
        
        // We want to know if the image was fetched and if the connection was no longer retained as an active connection
        // Start the fetching, which is asynchronous
        // The image will be fetched from disk
        imageCache.fetchImage(at: url! as URL!, completionBlock: { image, error in
            imageFetched = true
        })
        
        // Now wait for one second to see if both the image is fetched and the connection is no longer in the active connections dictionary
        do {
        

        try self.waitForConditionsWithTimeout(1.0, conditionsCheck: {
            connectionNotFound = connections?.object(forKey: urlString) == nil
                return connectionNotFound && imageFetched
            })
        } catch {
            XCTAssert(imageFetched, "The image was never fetched, so the test itself is broken. See ImageCacheDataProvider")
            XCTAssert(connectionNotFound == true, "The connection was not removed from active connections")
        }
    }
}

// This custom provider loads files with the pathname from URLs with scheme "imagecache" from the test bundle
class ImageCacheDataProvider: URLProtocol {
    
    // This class only handles schemes of "imagecache"
    open override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.scheme == "imagecache"
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    open override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
            return super.requestIsCacheEquivalent(a as URLRequest, to:b as URLRequest)
    }
    
    // Load the image from disk and call the client to step it through the loading of the image
    override func startLoading() {
        let bundle = Bundle(for: type(of: self))
        if let resourceName = self.request.url?.path {
            let resourcePath = bundle.path(forResource: resourceName, ofType: "")!
            if let imageData = NSData(contentsOfFile: resourcePath) {
                let mimeType = "image/png"
                let response = URLResponse(url: self.request.url!, mimeType: mimeType, expectedContentLength: imageData.length, textEncodingName: "utf-16")
                
                self.client!.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.client!.urlProtocol(self, didLoad: imageData as Data)
                self.client!.urlProtocolDidFinishLoading(self)
            }
        }

    }
    
    override func stopLoading() {
        // nothing to do here
    }

}
