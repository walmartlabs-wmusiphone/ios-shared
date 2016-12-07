//
//  SDImageCacheTests.swift
//  walmart
//
//  Created by Steven Riggins on 3/10/16.
//  Copyright © 2016 Walmart. All rights reserved.
//

import XCTest
import ELFoundation

@testable import IOSShared

class SDImageCacheTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear any caches before these tests run
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLProtocol.registerClass(ImageCacheDataProvider.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        NSURLProtocol.unregisterClass(ImageCacheDataProvider.self)
    }
    
    // This test uses implementation details to test
    func testActiveConnections() {
        let imageCache = SDImageCache()
        let urlString = "https://www.testurl.com/test"
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        let connection = SDURLConnection(request: request, delegate: nil)
        let connections = imageCache.activeConnectionsForTesting()
        
        imageCache.cacheConnection(connection, forURL: url!)
        XCTAssert(connections.objectForKey(urlString) != nil, "connection not found in active connections")
        
        imageCache.removeConnectionForURLFromCache(url!)
        XCTAssert(connections.objectForKey(urlString) == nil, "connection found in active connections")

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
        imageCache.fetchImageAtURL(url!, completionBlock: { image, error in
            imageFetched = true
        })
        
        // Now wait for one second to see if both the image is fetched and the connection is no longer in the active connections dictionary
        do {
        
        try self.waitForConditionsWithTimeout(1.0, conditionsCheck: {
                connectionNotFound = connections.objectForKey(urlString) == nil
                return connectionNotFound && imageFetched
            })
        } catch {
            XCTAssert(imageFetched, "The image was never fetched, so the test itself is broken. See ImageCacheDataProvider")
            XCTAssert(connectionNotFound == true, "The connection was not removed from active connections")
        }
        
        
    }

}

// This custom provider loads files with the pathname from URLs with scheme "imagecache" from the test bundle
class ImageCacheDataProvider: NSURLProtocol {
    
    // This class only handles schemes of "imagecache"
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        return request.URL?.scheme == "imagecache"
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(aRequest: NSURLRequest,
        toRequest bRequest: NSURLRequest) -> Bool {
            return super.requestIsCacheEquivalent(aRequest, toRequest:bRequest)
    }
    
    // Load the image from disk and call the client to step it through the loading of the image
    override func startLoading() {
        let bundle = NSBundle(forClass: self.dynamicType)
        if let resourceName = self.request.URL?.path {
            let resourcePath = bundle.pathForResource(resourceName, ofType: "")!
            if let imageData = NSData(contentsOfFile: resourcePath) {
                let mimeType = "image/png"
                let response = NSURLResponse(URL: self.request.URL!, MIMEType: mimeType, expectedContentLength: imageData.length, textEncodingName: "utf-16")
                
                self.client!.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
                self.client!.URLProtocol(self, didLoadData: imageData)
                self.client!.URLProtocolDidFinishLoading(self)
            }
        }

    }
    
    override func stopLoading() {
        // nothing to do here
    }

}
