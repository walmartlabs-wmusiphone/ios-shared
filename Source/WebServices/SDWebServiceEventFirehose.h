//
//  SDWebServiceEventFirehose.h
//  walmart
//
//  Created by Angelo Di Paolo on 2/19/16.
//  Copyright © 2016 Walmart. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Defines an interface to send a firehose of service request/response events to
@protocol SDWebServiceEventFirehose <NSObject>

- (void)updateUIBegin:(NSURLResponse *)request;
- (void)updateUIEnd:(NSURLResponse *)request;
- (void)deserializeBegin:(NSURLResponse *)request;
- (void)deserializeEnd:(NSURLResponse *)request;

@end

@protocol SDWebServiceEventFirehoseProvider <NSObject>

@property (nonatomic, readonly) id <SDWebServiceEventFirehose> firehose;

@end
