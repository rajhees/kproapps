//
//  ExersiteSessionAuthenticator.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserDidLoginNotification @"userDidLogin"

typedef void (^ExersiteSessionAuthenticatorResultBlock)(BOOL success);

@interface ExersiteSessionAuthenticator : NSObject

+ (void)authenticateWithUserDetails:(NSDictionary*)userDetails completion:(ExersiteSessionAuthenticatorResultBlock)completion;

@end
