//
//  UIImageView+SDExtensions.m
//  ios-shared
//
//  Created by Brandon Sneed on 4/22/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "UIImageView+SDExtensions.h"
#import "SDURLConnection.h"
#import "NSError+SDExtensions.h"
#import "SDMacros.h"

#import <objc/runtime.h>

NSString * const SDImageViewErrorDomain = @"SDImageViewErrorDomain";

void const *SDImageViewURLAssociatedObjectKey = @"SDImageViewURLAssociatedObjectKey";

@implementation UIImageView (SDExtensions)

- (NSURL *)URL
{
    NSURL *existingURL = objc_getAssociatedObject(self, SDImageViewURLAssociatedObjectKey);
    return existingURL;
}

- (void)setImageWithURL:(NSURL *)url
{
    // Removed nil guard because setting nil is legitimate and needs to happen so we clear out the image and the associated url
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder completionBlock:nil];
}

- (void)setImageWithURL:(NSURL *)url completionBlock:(UIImageViewURLCompletionBlock)completionBlock
{
    [self setImageWithURL:url placeholderImage:nil completionBlock:completionBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completionBlock:(UIImageViewURLCompletionBlock)completionBlock
{
    NSURL *existingURL = objc_getAssociatedObject(self, SDImageViewURLAssociatedObjectKey);
    if (existingURL && [[url absoluteString] isEqualToString:[existingURL absoluteString]])
    {
        if (completionBlock)
            completionBlock(nil, [NSError errorWithDomain:SDImageViewErrorDomain code:SDImageViewErrorAlreadyBeingFetched]);
        return;
    }
//    else
//    if (existingURL)
//        [self cancelCurrentImageLoad];
    
    
    objc_setAssociatedObject(self, SDImageViewURLAssociatedObjectKey, url, OBJC_ASSOCIATION_RETAIN);

    // if the url is set to nil, assume it's intentional and don't send back an error.
    if (!url)
    {
        self.image = nil;
        if (completionBlock)
            completionBlock(nil, nil);
        return;
    }
    
    self.image = placeholder;

    @weakify(self);

    [[SDImageCache sharedInstance] fetchImageAtURL:url completionBlock:^(UIImage *image, NSError *error) {
        @strongify(self);
        NSURL *originalURL = objc_getAssociatedObject(self, SDImageViewURLAssociatedObjectKey);

        // if the url's match on both sides, lets set it and/or wrap any error that comes back.
        if ([[url absoluteString] isEqualToString:[originalURL absoluteString]])
        {
            self.image = image;
            if (completionBlock)
                completionBlock(image, [NSError wrapErrorWithDomain:SDImageViewErrorDomain code:SDImageViewErrorConnectionError underlyingError:error]);
        }
        else
        {
            // the url's don't match anymore, skip setting it, but inform the client.
            if (completionBlock)
                completionBlock(nil, [NSError errorWithDomain:SDImageViewErrorDomain code:SDImageViewErrorHasBeenReused underlyingError:error]);
        }
    }];
}

- (void)cancelCurrentImageLoad
{
    NSURL *originalURL = objc_getAssociatedObject(self, SDImageViewURLAssociatedObjectKey);
    objc_setAssociatedObject(self, SDImageViewURLAssociatedObjectKey, nil, OBJC_ASSOCIATION_RETAIN);
    [[SDImageCache sharedInstance] cancelFetchForURL:originalURL];
}

+ (void)removeImageURLFromCache:(NSURL *)url
{
    [[SDImageCache sharedInstance] removeImageURLFromCache:url];
}

+ (void)setImageMemoryCacheSize:(NSUInteger)memoryCacheSize
{
    [[SDImageCache sharedInstance] setMemoryCacheSize:memoryCacheSize];
}

@end
