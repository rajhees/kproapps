//
//  ShopStoredAddressCell.m
//  Exersite
//
//  Created by James Eunson on 12/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopStoredAddressCell.h"
#import "ShopDeliveryScrollView.h"

@interface ShopStoredAddressCell ()
+ (NSString*)addressStringForStoredAddress:(NSDictionary*)storedAddress;
@end

@implementation ShopStoredAddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectedAddress = NO;
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.textLabel.textColor = RGBCOLOR(57, 58, 70);
        
        self.addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:13.0f];
        _addressLabel.textColor = RGBCOLOR(99, 100, 109);
        _addressLabel.backgroundColor = [UIColor clearColor];
        _addressLabel.numberOfLines = 0;
        _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_addressLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTextLabel = [self.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
    self.textLabel.frame = CGRectMake(8.0f, 8.0f, self.frame.size.width, sizeForTextLabel.height);
    
    CGSize sizeForAddressString = [self.addressLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake((self.frame.size.width - 16.0f), CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.addressLabel.frame = CGRectMake(8.0f, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 8.0f, self.frame.size.width - 16.0f, sizeForAddressString.height);
}

- (void)setStoredAddress:(NSDictionary *)storedAddress {
    _storedAddress = storedAddress;
    
    NSString * addressString = [[self class] addressStringForStoredAddress:storedAddress];
    
    NSMutableAttributedString * attributedAddressString = [[NSMutableAttributedString alloc] initWithString:addressString];
    
    NSRange rangeOfDeliveryAddressTitle = [addressString rangeOfString:@"Delivery Address"];
    NSRange rangeOfBillingAddressTitle = [addressString rangeOfString:@"Billing Address"];
    NSRange addressStringRange = NSMakeRange(0, [addressString length]);
    
    [attributedAddressString beginEditing];
    [attributedAddressString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(99, 100, 109) range:addressStringRange];
    
    [attributedAddressString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0f] range:rangeOfDeliveryAddressTitle];
    [attributedAddressString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(57, 58, 70) range:rangeOfDeliveryAddressTitle];
    
    [attributedAddressString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0f] range:rangeOfBillingAddressTitle];
    [attributedAddressString addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(57, 58, 70) range:rangeOfBillingAddressTitle];
    
    [attributedAddressString endEditing];
    
    _addressLabel.attributedText = attributedAddressString;
    [self setNeedsLayout];
}

- (void)setAddressNumber:(NSInteger)addressNumber {
    _addressNumber = addressNumber;
    
    self.textLabel.text = [NSString stringWithFormat:@"Address #%d", _addressNumber];
    [self setNeedsLayout];
}

- (void)setSelectedAddress:(BOOL)selectedAddress {
    _selectedAddress = selectedAddress;
    
    // Activate non-selectable variant on the usual cell
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.text = nil;
    [self setNeedsLayout];
}

+ (NSString*)addressStringForStoredAddress:(NSDictionary*)storedAddress {
    
    // This corresponds to _address_block.html.erb template in web application
    NSMutableString * string = [[NSMutableString alloc] init];
    
    // Delivery Address
    [string appendString:@"Delivery Address\n"];
    
    [string appendFormat:@"%@ %@ %@\n", storedAddress[@"delivery_title_name"], storedAddress[@"delivery_first_name"], storedAddress[@"delivery_last_name"]];
    [string appendFormat:@"%@\n", storedAddress[@"delivery_address"]];
    
    if([[storedAddress allKeys] containsObject:@"delivery_address_2"] && [storedAddress[@"delivery_address_2"] length] != 0) {
        [string appendFormat:@"%@\n", storedAddress[@"delivery_address_2"]];
    }
    
    [string appendFormat:@"%@\n", storedAddress[@"delivery_suburb"]];
    [string appendFormat:@"%@ %@\n", [storedAddress[@"delivery_state_name"] uppercaseString], storedAddress[@"delivery_country_name"]];
    [string appendFormat:@"%@\n", storedAddress[@"delivery_post_code"]];
    [string appendFormat:@"%@\n", storedAddress[@"delivery_telephone"]];
    [string appendFormat:@"%@\n\n", storedAddress[@"delivery_email"]];
    
    // Billing Address
    [string appendString:@"Billing Address\n"];
    
    [string appendFormat:@"%@ %@ %@\n", storedAddress[@"billing_title_name"], storedAddress[@"billing_first_name"], storedAddress[@"billing_last_name"]];
    [string appendFormat:@"%@\n", storedAddress[@"billing_address"]];
    
    if([[storedAddress allKeys] containsObject:@"billing_address_2"] && [storedAddress[@"billing_address_2"] length] != 0) {
        [string appendFormat:@"%@\n", storedAddress[@"billing_address_2"]];
    }
    
    [string appendFormat:@"%@\n", storedAddress[@"billing_suburb"]];
    [string appendFormat:@"%@ %@\n", [storedAddress[@"billing_state_name"] uppercaseString], storedAddress[@"billing_country_name"]];
    [string appendFormat:@"%@\n", storedAddress[@"billing_post_code"]];
    [string appendFormat:@"%@\n", storedAddress[@"billing_telephone"]];
    [string appendFormat:@"%@\n\n\n", storedAddress[@"billing_email"]];
    
    return string;
}

+ (CGFloat)heightForCellWithStoredAddress:(NSDictionary*)storedAddress displayingOnPaymentPage:(BOOL)displayingOnPaymentPage {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }

    CGSize sizeForTextLabel = CGSizeZero;
    if(!displayingOnPaymentPage) {
        sizeForTextLabel = [@"Address #1" sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake((screenWidth - 16.0f), CGFLOAT_MAX)];
    }
    
    NSString * addressString = [[self class] addressStringForStoredAddress:storedAddress];
    CGSize sizeForAddressString = [addressString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake((screenWidth - 16.0f), CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    return sizeForAddressString.height + sizeForTextLabel.height;
}

@end
