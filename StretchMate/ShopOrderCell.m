//
//  ShopOrderCell.m
//  Exersite
//
//  Created by James Eunson on 20/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopOrderCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ShopOrderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.detailTextLabel.textColor = [UIColor grayColor];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setOrder:(NSDictionary *)order {
    _order = order;
    
    NSInteger itemCount = [_order[@"items"] count];
    double totalDecimal = ([_order[@"total"] doubleValue] / 100);
    
    self.textLabel.text = [NSString stringWithFormat:@"%d %@, A$%.2f", itemCount, (itemCount == 1 ? @"item" : @"items"), totalDecimal];
    
    NSMutableArray * itemNames = [[NSMutableArray alloc] init];
    for(NSDictionary * item in _order[@"items"]) {
        NSString * constructedItemString = [NSString stringWithFormat:@"%d x %@", [item[kShopCartItemQuantityKey] integerValue], item[kShopCartItemProductKey][@"name"]];
        [itemNames addObject:constructedItemString];
    }
    NSString * itemNameString = [itemNames componentsJoinedByString:@", "];
    
    self.detailTextLabel.text = itemNameString;
    
    NSString * firstItemThumbUrlString = [_order[@"items"] firstObject][kShopCartItemProductKey][@"thumb"];
    
    // Load image of first item in order
    __block UITableViewCell * blockCell = self;
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:firstItemThumbUrlString]];
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        blockCell.imageView.image = image;
        [blockCell setNeedsLayout];
    } failure:nil];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(8, 8, 55.0f, 55.0f);
    self.textLabel.frame = CGRectMake(71.0f, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(71.0f, self.detailTextLabel.frame.origin.y, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
}
@end
