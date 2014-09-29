//
//  NSObject+Blocks.h
//  MyMonash
//
//  Created by James Eunson on 16/09/11.
//  Copyright 2011 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (PerformBlockAfterDelay) 
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
@end
