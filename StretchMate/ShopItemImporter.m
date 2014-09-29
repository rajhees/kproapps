//
//  ShopItemImporter.m
//  StretchMate
//
//  Created by James Eunson on 15/04/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopItemImporter.h"
#import "AppDelegate.h"

#define kShopItemCSV @"price_list.csv"

@interface ShopItemImporter()

@property (nonatomic, strong) NSManagedObjectContext * context;

@property (nonatomic, strong) ShopItem * currentShopItem;

@property (nonatomic, assign) NSInteger currentFieldIndex;
@property (nonatomic, assign) NSInteger currentLineNumber;
@property (nonatomic, assign) NSInteger currentShopItemIndex;

@property (nonatomic, strong) NSMutableArray * currentSheetFields;

@end

@implementation ShopItemImporter

- (void)startImportWithCompletion:(void (^)(BOOL success))completionHandler {
    
    self.completionHandler = completionHandler;
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.context = [delegate managedObjectContext];
    
    NSArray * filenameComponents = [kShopItemCSV componentsSeparatedByString:@"."];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:filenameComponents[0] ofType:filenameComponents[1]];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath:filePath]) {
        NSLog(@"File does not exist in file system");
        return;
    }
    
    NSError * error = nil;
    CHCSVParser * parser = [[CHCSVParser alloc] initWithContentsOfCSVFile:filePath encoding:NSASCIIStringEncoding error:&error];
    parser.parserDelegate = self;
    [parser parse];
}

- (void) parser:(CHCSVParser *)parser didStartDocument:(NSString *)csvFile {
    NSLog(@"ShopItemImporter: didStartDocument");
    
    self.currentShopItemIndex = 1;
    self.currentSheetFields = [[NSMutableArray alloc] init];
}

- (void) parser:(CHCSVParser *)parser didStartLine:(NSUInteger)lineNumber {
    NSLog(@"ShopItemImporter: didStartLine");
    
    _currentShopItem = nil;
    
    self.currentLineNumber = lineNumber;
    self.currentFieldIndex = 0;

    if(lineNumber != 1) {
        self.currentShopItem = (ShopItem*)[NSEntityDescription insertNewObjectForEntityForName:@"ShopItem" inManagedObjectContext:self.context];
        self.currentShopItem.identifier = @(self.currentShopItemIndex);
    }
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
    NSLog(@"ShopItemImporter: didEndLine");
    
    // First line should never be saved, as it is fields listing
    if(lineNumber == 1) return;

    self.currentShopItemIndex++;
}

- (void) parser:(CHCSVParser *)parser didReadField:(NSString *)field {
    
    if(self.currentLineNumber == 1) {
        [self.currentSheetFields addObject:field];
        
    } else {
        
        NSString * fieldName = [[self.currentSheetFields[self.currentFieldIndex] lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"ShopItemImporter: didReadField (%@): %@", fieldName, field);

        if([fieldName isEqualToString:@"name"]) {
            self.currentShopItem.name = field;
            
        } else if([fieldName isEqualToString:@"price"]) {

            double priceDouble = [field doubleValue];
            int priceInteger = (int)(priceDouble * ((double)100));
            self.currentShopItem.price = @(priceInteger);
            
        } else if([fieldName isEqualToString:@"description"]) {
            self.currentShopItem.desc = field;
        }
    }
    
    self.currentFieldIndex++;
}

- (void) parser:(CHCSVParser *)parser didEndDocument:(NSString *)csvFile {
    NSLog(@"ShopItemImporter: didEndDocument");
    
    NSError * error = nil;
    if(![self.context save:&error]) {
        NSLog(@"Error saving exercise");
    }
    
    self.completionHandler(YES);
}

- (void) parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"ShopItemImporter: didFailWithError");
}


@end
