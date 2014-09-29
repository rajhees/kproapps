//
//  TutorialViewController.h
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * descriptionLabel;

@property (nonatomic, strong) UIImageView * pageImageView;

@property (nonatomic, strong) NSDictionary * contentDictionary;

- (id)initWithDictionary:(NSDictionary*)dictionary;

@end
