//
//  MyPractitionerCell.m
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "MyPractitionerCell.h"
#import "UIImageView+AFNetworking.h"

#define kInsetMargin 62.0f

@implementation MyPractitionerCell

- (id)init {
    self = [super init];
    if (self) {
        
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        self.detailTextLabel.textColor = [UIColor grayColor];
        
        self.practiceAddressLabel = [[UILabel alloc] init];
        _practiceAddressLabel.font = [UIFont systemFontOfSize:13.0f];
        _practiceAddressLabel.textColor = [UIColor grayColor];
        _practiceAddressLabel.backgroundColor = [UIColor clearColor];
        _practiceAddressLabel.numberOfLines = 0;
        _practiceAddressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_practiceAddressLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(8.0f, 10.0f, 44.0f, 44.0f);
    
    CGFloat labelWidth = self.frame.size.width - ((self.frame.size.width / 4) - 16.0f);
    CGFloat labelOffset = (self.frame.size.width / 4) + 8.0f;
    
    CGSize sizeForTextLabel = [self.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(labelWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.textLabel.frame = CGRectMake(labelOffset, 8.0f, labelWidth, sizeForTextLabel.height);
    
    CGSize sizeForDetailTextLabel = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(labelWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.detailTextLabel.frame = CGRectMake(labelOffset, self.textLabel.frame.origin.y + self.textLabel.frame.size.height, labelWidth, sizeForDetailTextLabel.height);
    
    CGSize sizeForPracticeAddressLabel = [self.practiceAddressLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(labelWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.practiceAddressLabel.frame = CGRectMake(labelOffset, self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height, labelWidth, sizeForPracticeAddressLabel.height);
}

+ (CGFloat)heightWithPractitionerDict:(NSDictionary*)practitionerDict {
    
    if(!practitionerDict) {
        return 66.0f;
    }
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 8.0f;
    CGSize sizeForTextLabel = [practitionerDict[@"name"] sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - (screenWidth / 4), CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    heightAccumulator += sizeForTextLabel.height;
    
    CGSize sizeForDetailTextLabel = [practitionerDict[@"practice"][@"name"] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - (screenWidth / 4), CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    heightAccumulator += sizeForDetailTextLabel.height;
    
    CGSize sizeForPracticeAddressLabel = [practitionerDict[@"practice"][@"address"] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - (screenWidth / 4), CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    heightAccumulator += sizeForPracticeAddressLabel.height + 8.0f;
    
    return heightAccumulator;
}

- (void)setPractitionerDict:(NSDictionary *)practitionerDict {
    _practitionerDict = practitionerDict;
    
    if(_practitionerDict && [[_practitionerDict allKeys] containsObject:@"name"]) {
        self.textLabel.text = practitionerDict[@"name"];
    }
    
    if([[_practitionerDict allKeys] containsObject:@"practice"]) {
        
        NSDictionary * practice = _practitionerDict[@"practice"];
        
        if([[_practitionerDict[@"practice"] allKeys] containsObject:@"name"]) {
            self.detailTextLabel.text = practitionerDict[@"practice"][@"name"];
        }
        
        if([[_practitionerDict[@"practice"] allKeys] containsObject:@"address"]) {
            self.practiceAddressLabel.text = practitionerDict[@"practice"][@"address"];
        }
        
        if(practice && [[practice allKeys] containsObject:@"image"]) {
            
            NSURL * practiceImageURL = [NSURL URLWithString:practice[@"image"]];
            NSURLRequest * request = [NSURLRequest requestWithURL:practiceImageURL];
            
            __block UITableViewCell * blockCell = self;
            [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                blockCell.imageView.image = image;
                [blockCell setNeedsLayout];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                NSLog(@"Unable to retrieve practice image at url: %@", practiceImageURL);
            }];
        }
    }
    
    [self setNeedsLayout];
}

@end
