//
//  ProgramCell.m
//  Exersite
//
//  Created by James Eunson on 4/07/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramCell.h"
#import "UIImageView+AFNetworking.h"
#import "PractitionerExercise.h"
#import "Exercise.h"
#import "NSDate+TimeAgo.h"
#import "NSDate+TKCategory.h"

// One date formatter for reading from the program json format,
// one date formatter for writing out days, to determine unique number of days

static NSDateFormatter * dateFormatter = nil;
static NSDateFormatter * dayDateFormatter = nil;

@interface ProgramCell ()

@property (nonatomic, strong, readonly) Program * programForCell;

@property (nonatomic, strong) UILabel * subtitleLabel;

@end

@implementation ProgramCell
@synthesize programForCell = _programForCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        
        _subtitleLabel.text = @"Subtitle";
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        
        [self addSubview:_subtitleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(self.program) {
        self.imageView.frame = CGRectMake(0, 0, 55, 55);
    } else {
        self.imageView.frame = CGRectMake(0, 0, 55, 70);
    }
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.masksToBounds = YES;
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    self.textLabel.frame = CGRectMake(63, 6.0f, self.frame.size.width - 66 - 8.0f, self.textLabel.frame.size.height);
    
    self.detailTextLabel.frame = CGRectMake(63, self.textLabel.frame.origin.y + self.textLabel.frame.size.height, self.frame.size.width - 66 - 8.0f, self.detailTextLabel.frame.size.height);
    
    _subtitleLabel.frame = CGRectMake(63, self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
}

- (void)setProgramDict:(NSDictionary *)programDict {
    
    _programDict = programDict;
    
    if(programDict) {
        self.textLabel.text = programDict[@"title"];
//        self.detailTextLabel.text = [NSString stringWithFormat: @"Prescribed at %@", programDict[@"prescribedTime"]];
        
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
        }
        
        if(!dayDateFormatter) {
            dayDateFormatter = [[NSDateFormatter alloc] init];
            dayDateFormatter.dateFormat = @"yyyy-MM-dd";
            dayDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
        }
        
        NSInteger totalTimes = -1;
        NSMutableArray * uniqueDays = [[NSMutableArray alloc] init];
        
        if([[_programDict allKeys] containsObject:@"timeslots"]) {
            
            totalTimes = 0;
            for(NSDictionary * timeslot in _programDict[@"timeslots"]) {
                if([[timeslot allKeys] containsObject:@"times"] && [timeslot[@"times"] isKindOfClass:[NSArray class]]) {
                    totalTimes += [timeslot[@"times"] count];
                    
                    // Retrieve and aggregate unique days, so we can give a day count
                    for(NSDictionary * concreteTime in timeslot[@"times"]) {
                        
                        if(![[concreteTime allKeys] containsObject:@"time"]) {
                            continue;
                        }
                        
                        NSString * timeForConcreteTime = concreteTime[@"time"];
                        NSString * dayString = [dayDateFormatter stringFromDate:[dateFormatter dateFromString:timeForConcreteTime]];
                        if([uniqueDays indexOfObject:dayString] == NSNotFound) {
                            [uniqueDays addObject:dayString];
                        }
                    }
                }
            }
        }
        
        NSInteger exercisesCount = 0;
        if([[_programDict allKeys] containsObject:@"exercises"]) {
            exercisesCount = [_programDict[@"exercises"] count];
        } else {
            NSNumber * programIdentifier = @([_programDict[@"id"] intValue]);
            exercisesCount = [[[[Program programForIdentifier:programIdentifier] exercises] allObjects] count];
        }
        
        self.detailTextLabel.text = [NSString stringWithFormat:@"%d exercises, %d repetitions in %d days", exercisesCount, totalTimes, [uniqueDays count]];
        
        if([[_programDict allKeys] containsObject:@"prescribedTime"]) {
            NSDate * prescribedDate = [dateFormatter dateFromString:_programDict[@"prescribedTime"]];
            if(prescribedDate) {
                
                // Retrieve timeago string and de-capitalise first character
                NSString * timeAgoString = [prescribedDate timeAgo];
                timeAgoString = [NSString stringWithFormat:@"%@%@", [[timeAgoString substringWithRange:NSMakeRange(0, 1)] lowercaseString], [timeAgoString substringFromIndex:1]];
                
                self.subtitleLabel.text = [NSString stringWithFormat:@"Last updated %@", timeAgoString];
            }
        }
        
        if([[programDict allKeys] containsObject:@"exercises"]) {
            
            id firstExercise = [programDict[@"exercises"] firstObject];
//            NSLog(@"programDict, firstExercise: %@", NSStringFromClass([firstExercise class]));
            
            if([firstExercise isKindOfClass:[Exercise class]]) {
                
                self.imageView.image = [[((Exercise*)firstExercise) getImages] firstObject];
                [self setNeedsLayout];
                
            } else if([firstExercise isKindOfClass: [PractitionerExercise class]]) {
                
                PractitionerExercise * exercise = (PractitionerExercise*)firstExercise;
                
                __block ProgramCell * blockSelf = self;
                NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:exercise.thumb]];
                
                [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    blockSelf.imageView.image = image;
                    [blockSelf setNeedsLayout];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                    NSLog(@"Failed to load image for ProgramCell");
                }];
            }
            
        } else {
            self.imageView.image = [self.programForCell getOverviewImageWithSize:CGSizeMake(55, 55) type:OverviewImageTypeThumbnail];
        }
        
    }
}

- (void)setProgram:(Program *)program {
    _program = program;
    
    if(program) {
        
        NSSet * programExercises = program.exercises; // Retrieve once for multiple uses
        
        self.textLabel.text = program.title;
        self.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", [programExercises count], ([programExercises count] > 1 ? @"exercises" : @"exercise")];
        
        if([[program.title lowercaseString] rangeOfString:[@"Drink Water" lowercaseString]].location != NSNotFound) {
            self.imageView.image = [UIImage imageNamed:@"programs-drink-water.jpg"];
        } else {
            Exercise * anyExercise = [programExercises anyObject];
            self.imageView.image = [anyExercise getThumbnailImage];
        }
        
        self.subtitleLabel.hidden = YES;
        self.detailTextLabel.textColor = [UIColor grayColor];
    }
}

- (Program*)programForCell {
    
    if(_programForCell) {
        return _programForCell;
    }
    
    NSNumber * programIdentifier = @([_programDict[@"id"] intValue]);
    _programForCell = [Program programForIdentifier:programIdentifier];
    return _programForCell;
}

@end
