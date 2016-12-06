//
//  ScreenCoverTests.swift
//  walmart
//
//  Created by David Sica on 5/11/16.
//  Copyright © 2016 Walmart. All rights reserved.
//

import Foundation
import XCTest

@testable import Walmart

class ScreenCoverTests: WalmartUnitTest {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddCoverView() {
        walmartAppDelegate.sharedDelegate().switchToCartTab()
        walmartAppDelegate.sharedDelegate().addCoverView()

        if let subviews = walmartAppDelegate.sharedDelegate().window.subviews as NSArray? where subviews.count > 0,
            let topView = subviews[subviews.count-1] as? UIView where topView.tag == ScreenCover.screenCoverViewTag {

            NSLog("testAddCoverView passed")
        }
        else {
            XCTFail("testAddCoverView: Coverview is missing")
        }
    }

    func testRemoveCoverView() {
        walmartAppDelegate.sharedDelegate().switchToCartTab()
        walmartAppDelegate.sharedDelegate().addCoverView()

        if let subviews = walmartAppDelegate.sharedDelegate().window.subviews as NSArray? where subviews.count > 0,
            let topView = subviews[subviews.count-1] as? UIView where topView.tag == ScreenCover.screenCoverViewTag {
            NSLog("testRemoveCoverView: have cover in place")
        }
        else {
            XCTFail("testRemoveCoverView: Coverview is missing")
        }

        walmartAppDelegate.sharedDelegate().removeCoverView()

        if let subviews = walmartAppDelegate.sharedDelegate().window.subviews as NSArray? where subviews.count > 0 {
            
            for view: UIView in subviews as! [UIView] {
                if view.tag == ScreenCover.screenCoverViewTag {
                    XCTFail("testRemoveCoverView: Coverview should be removed")
                    break;
                }
            }
        }
        else {
            XCTFail("testRemoveCoverView: No subviews found")
        }
    }
    
    func testExpectedWhitelists() {
        // ObjC
        XCTAssertTrue((StoreFilterController() as? ScreenCoverProtocol) != nil, "StoreFilterController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMWeeklyAdWebViewController() as? ScreenCoverProtocol) != nil, "WMWeeklyAdWebViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMItemPageStoreAvailabilityDetailViewController() as? ScreenCoverProtocol) != nil, "WMItemPageStoreAvailabilityDetailViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMHomescreenViewController() as? ScreenCoverProtocol) != nil, "WMHomescreenViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((StoresViewController() as? ScreenCoverProtocol) != nil, "StoresViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((ShelfViewController() as? ScreenCoverProtocol) != nil, "ShelfViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((StoreViewController() as? ScreenCoverProtocol) != nil, "StoreViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMTextSearchViewController() as? ScreenCoverProtocol) != nil, "WMTextSearchViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMItemPageImageDetailViewController() as? ScreenCoverProtocol) != nil, "WMItemPageImageDetailViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((TitledHTMLViewController() as? ScreenCoverProtocol) != nil, "TitledHTMLViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMRatingsAndReviewsListViewController() as? ScreenCoverProtocol) != nil, "WMRatingsAndReviewsListViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMRatingsAndReviewsDetailViewController() as? ScreenCoverProtocol) != nil, "WMRatingsAndReviewsDetailViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMItemPageViewController() as? ScreenCoverProtocol) != nil, "WMItemPageViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((ShopViewController() as? ScreenCoverProtocol) != nil, "ShopViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMItemPageMarketplaceOptionsDetailViewController() as? ScreenCoverProtocol) != nil, "WMItemPageMarketplaceOptionsDetailViewController should conform to ScreenCoverProtocol")
        XCTAssertTrue((WMGenericItemPageViewController() as? ScreenCoverProtocol) != nil, "WMGenericItemPageViewController should conform to ScreenCoverProtocol")

        // Override WMRegistryWebViewController (from WMWebViewController)
        let registryVC = WMRegistryWebViewController() as? ScreenCoverProtocol
        XCTAssertTrue(registryVC != nil, "WMRegistryWebViewController should conform to ScreenCoverProtocol")
        XCTAssertFalse(registryVC!.shouldWhitelist!(), "WMRegistryWebViewController should return NO from shouldWhitelist")

        // Swift
        XCTAssertTrue((SearchViewController().conformsToProtocol(ScreenCoverProtocol)), "SearchViewController should conform to ScreenCoverProtocol")
    }

}
