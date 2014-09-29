//
//  ShopItemImporter.h
//  StretchMate
//
//  Created by James Eunson on 15/04/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSV.h"
#import "ShopItem.h"

typedef void (^ShopItemImporterCompletionHandler)(BOOL success);

@interface ShopItemImporter : NSObject <CHCSVParserDelegate>

- (void)startImportWithCompletion:(void (^)(BOOL success))completionHandler;

@property (nonatomic, copy) ShopItemImporterCompletionHandler completionHandler;

@end
