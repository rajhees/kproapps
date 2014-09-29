//
//  ProgramListingHeaderView.m
//  Exersite
//
//  Created by James Eunson on 21/08/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramListingHeaderView.h"
#import "Program.h"
#import "PractitionerExercise.h"
#import "Exercise.h"
#import "AFHTTPRequestOperation.h"


@interface ProgramListingHeaderView ()

@property (nonatomic, strong) UIImageView * headerImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIView * paddingView;

- (NSString*)_selectedProgramTitle;

@end

@implementation ProgramListingHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.headerImageView = [[UIImageView alloc] init];
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headerImageView.layer.masksToBounds = YES;
        [self addSubview:_headerImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        self.paddingView = [[UIView alloc] init];
        _paddingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
        [self addSubview:_paddingView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _headerImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    if(self.selectedProgram) {
        
        NSString * selectedProgramTitle = [self _selectedProgramTitle];
        CGSize labelSize = [selectedProgramTitle sizeWithFont:[UIFont boldSystemFontOfSize:24.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 10, CGFLOAT_MAX)];
        
        CGFloat yOffset = (_headerImageView.frame.size.height - (labelSize.height + 20));
        _titleLabel.frame = CGRectMake(10, yOffset, self.frame.size.width - 10, labelSize.height + 20);
        _paddingView.frame = CGRectMake(0, yOffset, 10, labelSize.height + 20);
    }
}

#pragma mark - Property Override Methods
- (void)setSelectedProgram:(id)selectedProgram {
    _selectedProgram = selectedProgram;
    
    self.titleLabel.text = [self _selectedProgramTitle];
    
    // Load image
    if([_selectedProgram isKindOfClass:[NSDictionary class]]) {
        
        NSArray * exercises = _selectedProgram[@"exercises"];
        id firstExercise = [exercises firstObject];
        
        if([firstExercise isKindOfClass:[PractitionerExercise class]]) {
            
            PractitionerExercise * practitionerExercise = (PractitionerExercise*)firstExercise;
            
            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:practitionerExercise.image]];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                UIImage * visibleImage = [UIImage imageWithData:responseObject];
                self.headerImageView.image = visibleImage;
                [self setNeedsLayout];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"Unable to load header image for listing view header");
            }];
            
        } else if([firstExercise isKindOfClass:[Exercise class]]) {
            self.headerImageView.image = [[((Exercise*)firstExercise) getImages] firstObject];
        }
        
    } else if([_selectedProgram isKindOfClass:[Program class]]) {
        
        Program * program = (Program*)self.selectedProgram;
        if([[program.title lowercaseString] rangeOfString:[@"Drink Water" lowercaseString]].location != NSNotFound) {
            
            UIImage * drinkWaterImage = [UIImage imageNamed:@"programs-drink-water.jpg"];
            self.headerImageView.image = drinkWaterImage;
            
        } else {
            self.headerImageView.image = [program getOverviewImageWithSize:CGSizeMake(self.frame.size.width, 150) type:OverviewImageTypeNormal];
        }
    }
    
    [self setNeedsLayout];
}

#pragma mark - Private Methods
- (NSString*)_selectedProgramTitle {
    
    NSString * selectedProgramTitle = nil;
    
    if([self.selectedProgram isKindOfClass:[Program class]]) {
        Program * program = (Program*)self.selectedProgram;
        selectedProgramTitle = program.title;
    } else if([self.selectedProgram isKindOfClass:[NSDictionary class]]) {
        selectedProgramTitle = self.selectedProgram[@"title"];
    }
    
    return selectedProgramTitle;
}

@end
