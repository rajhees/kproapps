//
//  PrescriptionExerciseCell.m
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PrescriptionExerciseCell.h"
#import "Exercise.h"
#import "PractitionerExercise.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+TimeAgo.h"

static NSDateFormatter * dateFormatter = nil;

@implementation PrescriptionExerciseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.completedTimeLabel = [[UILabel alloc] init];
        _completedTimeLabel.textColor = kTintColour;
        _completedTimeLabel.font = [UIFont systemFontOfSize:13.0f];
        _completedTimeLabel.backgroundColor = [UIColor clearColor];
        _completedTimeLabel.hidden = NO;
        [self.contentView addSubview:_completedTimeLabel];
        
        self.checkboxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26.0f, 26.0f)];

        _checkboxView.layer.borderColor = [kTintColour CGColor];
        _checkboxView.layer.borderWidth = 1.0f;
        _checkboxView.layer.cornerRadius = 4.0f;

        self.tickImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"prescription-tick-ios7"]];
        _tickImageView.frame = CGRectMake(6.0f, -6.0f, _tickImageView.frame.size.width, _tickImageView.frame.size.height);
        [_checkboxView addSubview:_tickImageView];

        self.accessoryView = _checkboxView;
        
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, 55, 55);
    
    CGFloat labelWidth = 70.0f + 8.0f + 26.0f + 8.0f;
    CGSize sizeForTextLabel = [self.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - labelWidth,  CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    self.textLabel.frame = CGRectMake(70, 8.0f, sizeForTextLabel.width, sizeForTextLabel.height);
    
    CGSize sizeForDetailTextLabel = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - labelWidth,  CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.detailTextLabel.frame = CGRectMake(70, self.textLabel.frame.origin.y + self.textLabel.frame.size.height, sizeForDetailTextLabel.width, sizeForDetailTextLabel.height);
    
    if(!self.completedTimeLabel.hidden) {
        CGSize sizeForCompletionLabel = [self.completedTimeLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - labelWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        self.completedTimeLabel.frame = CGRectMake(70, self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height, sizeForCompletionLabel.width, sizeForCompletionLabel.height);
    }
}

+ (CGFloat)heightForCellWithTimeslotDict:(NSDictionary*)timeslotDict {
    
    if(!timeslotDict) {
        return 66.0f;
    }
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 8.0f;
    
    NSDictionary * timeDict = timeslotDict[@"time"];
    id selectedExercise = timeslotDict[@"exercise"];
    
    Exercise * databaseExercise = (Exercise*)selectedExercise;
    
    CGFloat labelWidth = 70.0f + 8.0f + 26.0f + 8.0f;
    CGSize sizeForTextLabel = [databaseExercise.nameBasic sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - labelWidth,  CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    heightAccumulator += sizeForTextLabel.height;
    
    if([selectedExercise isKindOfClass:[PractitionerExercise class]]) {
        
        CGSize sizeForDetailTextLabel = [databaseExercise.typesString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - labelWidth,  CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        heightAccumulator += sizeForDetailTextLabel.height;
        
    } else {

        CGSize sizeForDetailTextLabel = [[NSString stringWithFormat:@"%@ · %@", databaseExercise.typesString, [databaseExercise durationString]] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - labelWidth,  CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        heightAccumulator += sizeForDetailTextLabel.height;
    }
    
    NSString * completionText = nil;
    
    if([timeDict[@"completed"] boolValue] && timeDict[@"completion_time"]) {
        
        completionText = [NSString stringWithFormat:@"Completed %@", [[dateFormatter dateFromString:timeDict[@"completion_time"]] timeAgo]];
        
        CGSize sizeForCompletionLabel = [completionText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - labelWidth,  CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        heightAccumulator += sizeForCompletionLabel.height + 8.0f;
        
    } else {
        
        heightAccumulator += 8.0f;
    }
    
    return heightAccumulator;
}

- (void)setTimeslotDict:(NSDictionary *)timeslotDict {
    _timeslotDict = timeslotDict;
    
    NSDictionary * timeDict = timeslotDict[@"time"];
    id selectedExercise = timeslotDict[@"exercise"];
    
    Exercise * databaseExercise = (Exercise*)selectedExercise;
    
    self.textLabel.text = databaseExercise.nameBasic;
    
    if([selectedExercise isKindOfClass:[Exercise class]]) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@ · %@", databaseExercise.typesString, [databaseExercise durationString]];
    } else {
        self.detailTextLabel.text = ((PractitionerExercise*)selectedExercise).typesString;
    }
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if([selectedExercise isKindOfClass:[Exercise class]]) {
        
        self.imageView.image = [((Exercise*)selectedExercise) getThumbnailImage];
        
    } else {
        
        PractitionerExercise * practitionerExercise = (PractitionerExercise*)selectedExercise;
        if(practitionerExercise.thumb) {
            
            __block PrescriptionExerciseCell * blockCell = self;
            [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:practitionerExercise.thumb]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                blockCell.imageView.image = image;
                [blockCell setNeedsLayout];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                NSLog(@"Failed to load thumb image for exercise: %@", [error localizedDescription]);
            }];
        }
    }
    
    if([timeDict[@"completed"] boolValue] && timeDict[@"completion_time"]) {
        
        self.textLabel.textColor = [UIColor grayColor];
        self.imageView.alpha = 0.5f;
        
        self.tickImageView.hidden = NO;
        self.completedTimeLabel.hidden = NO;
        
        NSString * timeAgoString = [[dateFormatter dateFromString:timeDict[@"completion_time"]] timeAgo];
        timeAgoString = [NSString stringWithFormat:@"%@%@", [[timeAgoString substringWithRange:NSMakeRange(0, 1)] lowercaseString], [timeAgoString substringFromIndex:1]];
        self.completedTimeLabel.text = [NSString stringWithFormat:@"Completed %@", timeAgoString];
        
    } else {

        self.imageView.alpha = 1.0f;
        self.textLabel.textColor = [UIColor blackColor];
        
        self.tickImageView.hidden = YES;
        self.completedTimeLabel.hidden = YES;
    }
    
    [self setNeedsLayout];
}

@end
