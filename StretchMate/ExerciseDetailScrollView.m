//
//  ExerciseDetailScrollView.m
//  StretchMate
//
//  Created by James Eunson on 24/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseDetailScrollView.h"
#import "ExerciseDetailTagView.h"
#import "ExerciseInstrutionCell.h"
#import "ExerciseGalleryView.h"
#import "OrangeSectionHeaderView.h"
#import "ExerciseEquipmentCell.h"
#import "ExerciseEquipmentFlowLayout.h"
#import "ExerciseInstructionTableView.h"
#import "ExerciseCell.h"
#import "PractitionerExercise.h"
#import "UIImageView+AFNetworking.h"

#define kMediaSelectorContainerHeight 37.0f
#define kMediaViewHeight 151.0f
#define kMediaViewPadding 18.0f
#define kMediaTabViewHeight 43.0f
#define kMediaTabBottomPadding 15.0f
#define kEquipmentContainerHeightCompact 102.0f
#define kEquipmentContainerHeightExpanded 136.0f
#define kLevelImageWidth 61.0f
#define kActionButtonContainerHeight 60.0f

#define kExerciseEquipmentCellReuseIdentifier @"ExerciseEquipmentCell"
#define kRelatedExerciseCellReuseIdentifier @"RelatedExerciseCell"

@interface ExerciseDetailScrollView()

//+ (CGFloat)heightForRelatedExercisesTableViewWithExercise:(Exercise*)exercise;
//+ (CGFloat)heightForInstructionsTableViewWithExercise:(id)exercise;
//
//- (void)didTapStar:(id)sender;
//- (UIView*)createActionButtonContainerViewWithParentContainerView:(UIView*)containerView andParentContainerHeight:(CGFloat)heightWithExercise offsetFromParentHeight:(CGFloat)parentOffset;
//- (UIButton*)createActionButtonWithText:(NSString*)text;
//- (void)startExercise:(id)sender;
//- (void)toggleExerciseInMyExercises:(id)sender;
//- (void)didTapLevelButton:(id)sender;
@end

@implementation ExerciseDetailScrollView

- (id)initWithFrame:(CGRect)frame andExercise:(id)exercise {
    self = [super initWithFrame:frame];
    if(self) {
        
//        self.visibleMediaView = ExerciseMediaViewImages;        
//        
//        CGFloat heightWithExercise = [[self class] heightForScrollViewWithExercise:exercise];
//        
//        self.contentSize = CGSizeMake(0, heightWithExercise + ((kActionButtonContainerHeight + 10) * 2) + 25);
//        
//        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
//        } else {
//            self.backgroundColor = RGBCOLOR(238, 238, 238);
//        }
//        
//        self.selectedExercise = exercise;
//        
//        CGRect containerRect = CGRectMake(9, 10, frame.size.width-18, heightWithExercise);
//        UIView * containerView = [[UIView alloc] initWithFrame:containerRect];
//        
//        containerView.layer.borderColor = [RGBCOLOR(201, 201, 201) CGColor];
//        containerView.layer.borderWidth = 1.0f;
//        containerView.backgroundColor = [UIColor whiteColor];
//        
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, frame.size.width-18, heightWithExercise) byRoundingCorners: UIRectCornerAllCorners cornerRadii:CGSizeMake(8.0, 8.0)];
//        
//        CAShapeLayer *bottomMaskLayer = [CAShapeLayer layer];
//        bottomMaskLayer.frame = containerView.bounds;
//        bottomMaskLayer.path = maskPath.CGPath;
//        containerView.layer.mask = bottomMaskLayer;
//        
//        CGSize titleTextSize = [((Exercise*)self.selectedExercise).nameBasic sizeWithFont:[UIFont boldSystemFontOfSize:24.0f] constrainedToSize:CGSizeMake(275.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//        CGSize subtitleTextSize = [((Exercise*)self.selectedExercise).nameTechnical sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(275.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//        
//        UIView * topCapView = [[UIView alloc] initWithFrame:CGRectMake(0, -1, 302, 160)];
//        
//        UIImageView * topCapBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-detail-top-cap"]];
//        topCapBackgroundView.frame = CGRectMake(0, 0, topCapBackgroundView.frame.size.width, topCapBackgroundView.frame.size.height);
//        [topCapView addSubview:topCapBackgroundView];
//        
//        topCapView.frame = CGRectMake(0, -1, 302, 160 + (titleTextSize.height - 29.0f));
//        UIImage * topCapExtensionBackroundImage = [[UIImage imageNamed:@"exercise-top-cap-extension"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
//        UIImageView * topCapExtensionImageView = [[UIImageView alloc] initWithImage:topCapExtensionBackroundImage];
//        topCapExtensionImageView.frame = CGRectMake(0, topCapBackgroundView.frame.size.height, 302, (titleTextSize.height - 29.0f) + subtitleTextSize.height);
//        [topCapView addSubview:topCapExtensionImageView];
//        
//        StarBackgroundColor starBackgroundColor = StarBackgroundColorDarkBlue;
//        if([self.selectedExercise isKindOfClass:[Exercise class]] && [((Exercise*)self.selectedExercise) isExerciseSaved]) {
//            starBackgroundColor = StarBackgroundColorOrange;
//        }
//        self.starView = [[ExerciseStarView alloc] initWithFrame:CGRectMake(0, 0, 36, 36) size:StarViewSizeLarge color:starBackgroundColor];
//        
//        UIButton * starButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        starButton.frame = CGRectMake(topCapView.frame.size.width-36, 0, 36, 36);
//        starButton.backgroundColor = [UIColor clearColor];
//        [starButton addTarget:self action:@selector(didTapStar:) forControlEvents:UIControlEventTouchUpInside];
//        [starButton addSubview:self.starView];
//        
//        [topCapView addSubview:starButton];
//        [containerView addSubview:topCapView];
//        
//        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 275, titleTextSize.height)];
//        _titleLabel.textColor = [UIColor whiteColor];
//        _titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
//        _titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.75f];
//        _titleLabel.shadowOffset = CGSizeMake(0, 1.0f);
//        _titleLabel.backgroundColor = [UIColor clearColor];
//        _titleLabel.numberOfLines = 0;
//        _titleLabel.text = ((Exercise*)self.selectedExercise).nameBasic;
//        
//        [containerView addSubview:self.titleLabel];
//        
//        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 6 + titleTextSize.height, 275, subtitleTextSize.height)];
//        _subtitleLabel.textColor = [UIColor whiteColor];
//        _subtitleLabel.font = [UIFont systemFontOfSize:14.0f];
//        _subtitleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.75f];
//        _subtitleLabel.shadowOffset = CGSizeMake(0, 1.0f);
//        _subtitleLabel.backgroundColor = [UIColor clearColor];
//        _subtitleLabel.numberOfLines = 0;
//        _subtitleLabel.text = ((Exercise*)self.selectedExercise).nameTechnical;
//        
//        [containerView addSubview:self.subtitleLabel];        
//        
//        NSArray * exerciseTypes = [[self.selectedExercise types] allObjects];
//        UIView * firstTagView = nil;
//        int i = 0;
//        CGFloat tagXOffsetAccum = 0;
//        for(ExerciseType * type in exerciseTypes) {
//            
//            CGFloat tagWidth = [ExerciseDetailTagView widthForExerciseType:type];
//            ExerciseDetailTagView * tagView = [[ExerciseDetailTagView alloc] initWithFrame:CGRectMake(12 + tagXOffsetAccum, 12+titleTextSize.height+subtitleTextSize.height, tagWidth, 20) andExerciseType:type];
//            
//            if(!firstTagView) {
//                firstTagView = tagView;
//            }
//            tagXOffsetAccum += tagWidth + 10;
//            
//            [containerView addSubview:tagView];
//            i++;
//        }
//        
//        CGFloat mediaContainerYOffset = firstTagView.frame.size.height + firstTagView.frame.origin.y + 10.f;
//        ExerciseSelectorView * selectorView = [[ExerciseSelectorView alloc] initWithFrame:CGRectMake(1, mediaContainerYOffset, 300, kMediaSelectorContainerHeight)];
//        selectorView.delegate = self;
//        
//        if([self.selectedExercise isKindOfClass:[PractitionerExercise class]]) {
//            [selectorView setVideoEnabled:NO];
//        } else {
//            [selectorView setVideoEnabled:YES];
//        }
//        
//        [containerView addSubview:selectorView];
//        
//        CGFloat greyGradientYOffset = mediaContainerYOffset + selectorView.frame.size.height + 72;
//        
//        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//            
//            CAGradientLayer * greyGradientLayer = [CAGradientLayer layer];
//            greyGradientLayer.frame = CGRectMake(0, greyGradientYOffset, containerView.frame.size.width, 172);
//            greyGradientLayer.colors = @[ (id)[RGBCOLOR(255, 255, 255) CGColor], (id)[RGBCOLOR(225, 225, 225) CGColor] ];
//            [containerView.layer insertSublayer:greyGradientLayer atIndex:0];
//            
//        }
//        
//        NSMutableArray * mutableMediaViews = [[NSMutableArray alloc] init];
//        CGFloat exerciseImageContainerYOffset = mediaContainerYOffset + selectorView.frame.size.height + 12;
//        
//        for(int i = 0; i < 2; i++) {
//            NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
//            if(i == 0) {
//                
//                if([exercise isKindOfClass:[Exercise class]]) {
//                    options[@"images"] = [exercise getImages];
//                } else if([exercise isKindOfClass:[PractitionerExercise class]]) {
//                    if(((PractitionerExercise*)exercise).image) {
//                        options[@"images"] = @[ [NSURL URLWithString:((PractitionerExercise*)exercise).image] ];
//                    } else {
//                        options[@"images"] = @[];
//                    }
//                }
//            
//            } else {
//                if([exercise isKindOfClass:[Exercise class]] && [exercise getVideoFilePath]) {
//                    options[@"videos"] = @[[exercise getVideoFilePath]];                    
//                }
//            }
//            
//            ExerciseGalleryView * galleryView = [[ExerciseGalleryView alloc] initWithFrame:CGRectMake(0 + (i * self.frame.size.width), exerciseImageContainerYOffset, 258+18, kMediaViewHeight+kMediaViewPadding) options:options];
//            galleryView.delegate = self;
//            [containerView addSubview:galleryView];
//            [mutableMediaViews addObject:galleryView];
//        }
//        self.mediaViews = [NSArray arrayWithArray:mutableMediaViews];
//        
//        // Instructions section header and tableview
//        ExerciseGalleryView * firstGalleryView = mutableMediaViews[0];
//        CGFloat instructionHeaderYOffset = exerciseImageContainerYOffset + firstGalleryView.frame.size.height + 14;
//        OrangeSectionHeaderView * sectionHeaderView = [[OrangeSectionHeaderView alloc] initWithFrame:CGRectMake(0, instructionHeaderYOffset, kOrangeSectionHeaderViewWidth, kOrangeSectionHeaderViewHeight) text: @"Instructions"];
//        [containerView addSubview:sectionHeaderView];
//        
//        // Determine required table size to display all instructions without clipping
//        CGFloat instructionTableHeightAccum = [[self class] heightForInstructionsTableViewWithExercise:exercise];
//        
//        CGFloat tableViewYOffset = sectionHeaderView.frame.size.height + sectionHeaderView.frame.origin.y;
//        
//        self.instructionsTableView = [[ExerciseInstructionTableView alloc] initWithFrame:CGRectMake(0, tableViewYOffset, containerView.frame.size.width, instructionTableHeightAccum) selectedExercise:self.selectedExercise mode:ExerciseInstructionTableViewModeNormal];
//        
//        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
//            _instructionsTableView.separatorInset = UIEdgeInsetsZero;
//        }
//        
//        [containerView addSubview:self.instructionsTableView];
//        
//        CGFloat equipmentHeaderYOffset = tableViewYOffset + instructionTableHeightAccum;
//        OrangeSectionHeaderView * equipmentSectionHeaderView = [[OrangeSectionHeaderView alloc] initWithFrame:CGRectMake(0, equipmentHeaderYOffset, kOrangeSectionHeaderViewWidth, kOrangeSectionHeaderViewHeight) text: @"Equipment"];
//        [containerView addSubview:equipmentSectionHeaderView];
//        
//        CGFloat moreInformationYOffset = equipmentHeaderYOffset;
//        if(([exercise isKindOfClass:[Exercise class]] && [exercise getEquipment] != nil) || ([exercise isKindOfClass:[PractitionerExercise class]] && ((PractitionerExercise*)exercise).equipment && [((PractitionerExercise*)exercise).equipment count] > 0)) {
//            
//            CGFloat containerHeight = 0;
//            if([exercise isKindOfClass:[Exercise class]]) {
//                containerHeight = ([[exercise getEquipment] count] > 2) ? kEquipmentContainerHeightExpanded : kEquipmentContainerHeightCompact;
//            } else {
//                containerHeight = ([[((PractitionerExercise*)exercise) equipment] count] > 2) ? kEquipmentContainerHeightExpanded : kEquipmentContainerHeightCompact;
//            }
//
//            CGFloat yOffset = equipmentHeaderYOffset + equipmentSectionHeaderView.frame.size.height;
//            
//            UIImage * equipmentBackgroundResizable = [[UIImage imageNamed:@"exercise-equipment-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 0, 12, 0)];
//            UIImageView * equipmentBackgroundImageView = [[UIImageView alloc] initWithImage:equipmentBackgroundResizable];
//            equipmentBackgroundImageView.frame = CGRectMake(0, yOffset, 302, containerHeight);
//            [containerView addSubview:equipmentBackgroundImageView];
//            
//            self.equipmentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, yOffset + 10, 302, containerHeight - 20) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
//            _equipmentCollectionView.backgroundColor = [UIColor clearColor];
//            
//            _equipmentCollectionView.delegate = self;
//            _equipmentCollectionView.dataSource = self;
//            
//            [_equipmentCollectionView registerClass:[ExerciseEquipmentCell class] forCellWithReuseIdentifier:kExerciseEquipmentCellReuseIdentifier];
//            [containerView addSubview:self.equipmentCollectionView];
//            
//            moreInformationYOffset = equipmentHeaderYOffset + equipmentSectionHeaderView.frame.size.height + containerHeight;
//        }
//        
//        OrangeSectionHeaderView * moreInformationSectionHeaderView = [[OrangeSectionHeaderView alloc] initWithFrame:CGRectMake(0, moreInformationYOffset, kOrangeSectionHeaderViewWidth, kOrangeSectionHeaderViewHeight) text: @"More Information"];
//        [containerView addSubview:moreInformationSectionHeaderView];
//        
//        CGSize sizeForPurpose = [[exercise purpose] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(208, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//        CGSize sizeForLevelText = [[exercise getLevelString] sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(kLevelImageWidth + 10, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//        
//        CGFloat moreInformationGradientYOffset = moreInformationSectionHeaderView.frame.origin.y + moreInformationSectionHeaderView.frame.size.height;
//        
//        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//            
//            CAGradientLayer * moreInformationGradient = [CAGradientLayer layer];
//            moreInformationGradient.frame = CGRectMake(0, moreInformationGradientYOffset, containerView.frame.size.width, 172);
//            moreInformationGradient.colors = @[ (id)[RGBCOLOR(255, 255, 255) CGColor], (id)[RGBCOLOR(225, 225, 225) CGColor] ];
//            [containerView.layer insertSublayer:moreInformationGradient atIndex:0];
//            
//        }
//        
//        UIImageView * levelImageView = [[UIImageView alloc] initWithImage:[exercise getLevelImage]];
//        
//        UIButton * levelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, moreInformationGradientYOffset + 10, levelImageView.frame.size.width, levelImageView.frame.size.height)];
//        [levelButton addSubview:levelImageView];
//        [levelButton addTarget:self action:@selector(didTapLevelButton:) forControlEvents:UIControlEventTouchUpInside];
//        [containerView addSubview:levelButton];
//        
//        UILabel * purposeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + levelButton.frame.size.width + 10 + 4, moreInformationGradientYOffset + 7, 208, 18.0f)];
//        purposeTitleLabel.text = @"Purpose";
//        purposeTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
//        purposeTitleLabel.backgroundColor = [UIColor clearColor];
//        purposeTitleLabel.textColor = RGBCOLOR(51, 51, 51);
//        purposeTitleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
//        purposeTitleLabel.shadowOffset = CGSizeMake(0, 1.0f);
//        [containerView addSubview:purposeTitleLabel];
//        
//        CALayer * borderLayer = [CALayer layer];
//        [borderLayer setBackgroundColor:RGBCOLOR(204, 204, 204).CGColor];
//        [borderLayer setFrame:CGRectMake(10 + levelButton.frame.size.width + 10 + 4, purposeTitleLabel.frame.origin.y + purposeTitleLabel.frame.size.height + 4, 208, 1)];
//        [containerView.layer addSublayer:borderLayer];
//        
//        CALayer * highlightBorderLayer = [CALayer layer];
//        [highlightBorderLayer setBackgroundColor:RGBCOLOR(255, 255, 255).CGColor];
//        [highlightBorderLayer setFrame:CGRectMake(10 + levelButton.frame.size.width + 10 + 4, purposeTitleLabel.frame.origin.y + purposeTitleLabel.frame.size.height + 5, 208, 1)];
//        [containerView.layer addSublayer:highlightBorderLayer];
//        
//        UILabel * levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, levelButton.frame.origin.y + levelButton.frame.size.height + 5, levelButton.frame.size.width + 10, sizeForLevelText.height)];
//        levelLabel.backgroundColor = [UIColor clearColor];
//        levelLabel.text = [exercise getLevelString];
//        levelLabel.font = [UIFont systemFontOfSize:12.0f];
//        levelLabel.numberOfLines = 0;
//        levelLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        levelLabel.textAlignment = NSTextAlignmentCenter;
//        levelLabel.textColor = RGBCOLOR(119, 119, 119);
//        levelLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
//        levelLabel.shadowOffset = CGSizeMake(0, 1.0f);
//        [containerView addSubview:levelLabel];
//        
//        UILabel * purposeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + levelButton.frame.size.width + 10 + 4, moreInformationGradientYOffset + 10 + 18.0f + 7, 208, sizeForPurpose.height)];
//        purposeLabel.backgroundColor = [UIColor clearColor];
//        purposeLabel.text = ((Exercise*)exercise).purpose;
//        purposeLabel.textColor = RGBCOLOR(119, 119, 119);
//        purposeLabel.font = [UIFont systemFontOfSize:13.0f];
//        purposeLabel.numberOfLines = 0;
//        purposeLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        purposeLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
//        purposeLabel.shadowOffset = CGSizeMake(0, 1.0f);
//        [containerView addSubview:purposeLabel];
//        
//        if([exercise isKindOfClass:[Exercise class]] && [((Exercise*)exercise).related count] > 0) {
//            
//            CGFloat relatedYOffset = (moreInformationGradientYOffset + 172);
//            
//            OrangeSectionHeaderView * moreInformationSectionHeaderView = [[OrangeSectionHeaderView alloc] initWithFrame:CGRectMake(0, relatedYOffset, kOrangeSectionHeaderViewWidth, kOrangeSectionHeaderViewHeight) text: @"Related Exercises"];
//            [containerView addSubview:moreInformationSectionHeaderView];
//            
//            CGFloat heightForRelatedExercisesTableView = [[self class] heightForRelatedExercisesTableViewWithExercise:exercise];
//            
//            CGRect relatedFrame = CGRectMake(8, relatedYOffset + moreInformationSectionHeaderView.frame.size.height, kOrangeSectionHeaderViewWidth - 16, heightForRelatedExercisesTableView);
//            self.relatedExercisesTableView = [[UITableView alloc] initWithFrame:relatedFrame style:UITableViewStylePlain];
//            _relatedExercisesTableView.dataSource = self;
//            _relatedExercisesTableView.delegate = self;
//            
//            [_relatedExercisesTableView registerClass:[ExerciseCell class] forCellReuseIdentifier:kRelatedExerciseCellReuseIdentifier];
//            [containerView addSubview:_relatedExercisesTableView];
//        }
//        
//        [self addSubview:containerView];
//        
//        UIView * startExerciseContainerView = [self createActionButtonContainerViewWithParentContainerView:containerView andParentContainerHeight:heightWithExercise offsetFromParentHeight: 20];
//        UIButton * startExerciseButton = [self createActionButtonWithText:@"Start Exercise"];
//        [startExerciseButton addTarget:self action:@selector(startExercise:) forControlEvents:UIControlEventTouchUpInside];
//        [startExerciseContainerView addSubview:startExerciseButton];
//        [self addSubview:startExerciseContainerView];
//        
//        UIView * addToExercisesContainerView = [self createActionButtonContainerViewWithParentContainerView:containerView andParentContainerHeight:heightWithExercise offsetFromParentHeight: 20 + kActionButtonContainerHeight + 10];
//        
//        NSString * exerciseButtonString = nil;
//        if([self.selectedExercise isKindOfClass:[Exercise class]] && [self.selectedExercise isExerciseSaved]) {
//            exerciseButtonString = @"Remove from My Exercises";
//        } else {
//            exerciseButtonString = @"Add to My Exercises";
//        }
//        
//        self.addToExercisesButton = [self createActionButtonWithText:exerciseButtonString];
//        [_addToExercisesButton addTarget:self action:@selector(toggleExerciseInMyExercises:) forControlEvents:UIControlEventTouchUpInside];
//        [addToExercisesContainerView addSubview:self.addToExercisesButton];
//        [self addSubview:addToExercisesContainerView];
    }
    return self;
}

//#pragma mark - UITableViewDelegate Methods
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if(tableView == self.relatedExercisesTableView) {
//        
//        NSArray * relatedExercises = [self.selectedExercise relatedExercises];
//        Exercise * relatedExercise = relatedExercises[indexPath.row];
//        
//        if([self.exerciseDelegate respondsToSelector:@selector(exerciseDetailScrollView:didSelectRelatedExercise:)]) {
//            [self.exerciseDelegate performSelector:@selector(exerciseDetailScrollView:didSelectRelatedExercise:) withObject:self withObject:relatedExercise];
//        }
//        
//        [_relatedExercisesTableView deselectRowAtIndexPath:indexPath animated:YES];        
//    }
//}
//
//- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if(tableView == self.instructionsTableView) {
//        
//        static NSString * cellIdentifier = @"instructionsCell";
//        ExerciseInstrutionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//        
//        NSArray * processedInstructions = [self.selectedExercise getInstructionList];
//        NSDictionary * cellInstruction = processedInstructions[indexPath.row];
//        
//        cell.exerciseInstructionString = cellInstruction[@"instruction"];
//        cell.numberLabel.text = cellInstruction[@"number"];
//        
//        return cell;
//        
//    } else {
//        
//        NSArray * relatedExercises = [self.selectedExercise relatedExercises];
//        Exercise * relatedExercise = relatedExercises[indexPath.row];
//        
//        ExerciseCell * cell = [_relatedExercisesTableView dequeueReusableCellWithIdentifier:kRelatedExerciseCellReuseIdentifier forIndexPath:indexPath];
//        
//        cell.textLabel.text  = relatedExercise.nameBasic;
//        cell.detailTextLabel.text = relatedExercise.typesString;
//        cell.imageView.image = [relatedExercise getThumbnailImage];
//        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        
//        return cell;
//    }
//}
//
//#pragma mark - UITableViewDataSource Methods
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    
//    if(tableView == self.instructionsTableView) {
//        NSArray * processedInstructions = [self.selectedExercise getInstructionList];
//        if(processedInstructions) {
//            return [processedInstructions count];
//        }
//        return 1;
//    } else {
//        return [[self.selectedExercise relatedExercises] count];
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if(tableView == self.instructionsTableView) {
//        
//        NSArray * processedInstructions = [self.selectedExercise getInstructionList];
//        NSDictionary * cellInstruction = processedInstructions[indexPath.row];
//        NSString * instructionString = cellInstruction[@"instruction"];
//        
//        return [ExerciseInstrutionCell heightWithExerciseInstructionString:instructionString];
//        
//    } else {
//        return 55.0f;
//    }
//}
//
//#pragma mark - Private Methods
//- (void)startExercise:(id)sender {
//    NSLog(@"startExercise");
//
//    if([self.exerciseDelegate respondsToSelector:@selector(exerciseDetailScrollView:didStartExercise:)]) {
//        [self.exerciseDelegate performSelector:@selector(exerciseDetailScrollView:didStartExercise:) withObject:self withObject:self.selectedExercise];
//    }
//}
//
//- (void)toggleExerciseInMyExercises:(id)sender {
//    NSLog(@"addExerciseToMyExercises");
//    
//    if([self.exerciseDelegate respondsToSelector:@selector(exerciseDetailScrollView:shouldToggleExerciseInMyExercises:)]) {
//        [self.exerciseDelegate performSelector:@selector(exerciseDetailScrollView:shouldToggleExerciseInMyExercises:)
//                                    withObject:self withObject:self.selectedExercise];
//        
//        // Update star view with new color
//        if([self.selectedExercise isExerciseSaved]) {
//            self.starView.starBackgroundColor = StarBackgroundColorOrange;
//        } else {
//            self.starView.starBackgroundColor = StarBackgroundColorDarkBlue;
//        }
//        
//        NSString * exerciseButtonString = nil;
//        if([self.selectedExercise isExerciseSaved]) {
//            exerciseButtonString = @"Remove from My Exercises";
//        } else {
//            exerciseButtonString = @"Add to My Exercises";
//        }
//        [self.addToExercisesButton setTitle:exerciseButtonString forState:UIControlStateNormal];
//        
//        [self setNeedsDisplay];
//    }
//}
//
//- (UIView*)createActionButtonContainerViewWithParentContainerView:(UIView*)containerView andParentContainerHeight:(CGFloat)heightWithExercise offsetFromParentHeight:(CGFloat)parentOffset {
//    
//    CGRect actionButtonContainerRect = CGRectMake(9, heightWithExercise + parentOffset, containerView.frame.size.width, kActionButtonContainerHeight);
//    UIView * actionButtonContainerView = [[UIView alloc] initWithFrame:actionButtonContainerRect];
//    actionButtonContainerView.backgroundColor = [UIColor whiteColor];
//    
//    UIBezierPath *actionButtonContainerMaskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, containerView.frame.size.width, kActionButtonContainerHeight)
//                                                                 byRoundingCorners: UIRectCornerAllCorners cornerRadii:CGSizeMake(8.0, 8.0)];
//    
//    CAShapeLayer *actionButtonContainerMaskPathBottomMaskLayer = [CAShapeLayer layer];
//    actionButtonContainerMaskPathBottomMaskLayer.frame = actionButtonContainerView.bounds;
//    actionButtonContainerMaskPathBottomMaskLayer.path = actionButtonContainerMaskPath.CGPath;
//    actionButtonContainerView.layer.mask = actionButtonContainerMaskPathBottomMaskLayer;
//    
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//        
//        CAGradientLayer * actionButtonContainerGradient = [CAGradientLayer layer];
//        actionButtonContainerGradient.frame = CGRectMake(0, 0, containerView.frame.size.width, kActionButtonContainerHeight);
//        actionButtonContainerGradient.colors = @[ (id)[RGBCOLOR(255, 255, 255) CGColor], (id)[RGBCOLOR(225, 225, 225) CGColor] ];
//        [actionButtonContainerView.layer insertSublayer:actionButtonContainerGradient atIndex:0];
//        
//    } else {
//        
//        actionButtonContainerView.layer.borderWidth = 1.0f;
//        actionButtonContainerView.layer.borderColor = [RGBCOLOR(201, 201, 201) CGColor];
//    }
//    
//    return actionButtonContainerView;
//}
//
//- (UIButton*)createActionButtonWithText:(NSString*)text {
//    
//    UIButton * actionButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, 286, 46)];
//    UIImage * resizableActionButtonImage = [UIImage imageNamed:@"exercise-action-button-bg"];
//    [actionButton setBackgroundImage:resizableActionButtonImage forState:UIControlStateNormal];
//    [actionButton setTitle:text forState:UIControlStateNormal];
//    actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
//    actionButton.titleLabel.shadowColor = RGBCOLOR(0, 0, 0);
//    actionButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
//    
//    return actionButton;
//}
//
//- (void)didTapGalleryButton:(id)sender {
//    if([self.exerciseDelegate respondsToSelector:@selector(exerciseDetailScrollView:didTapGalleryButton:)]) {
//        [self.exerciseDelegate performSelector:@selector(exerciseDetailScrollView:didTapGalleryButton:) withObject:self withObject:sender];
//    }
//}
//
//+ (CGFloat)heightForScrollViewWithExercise:(id)exercise {
//    
//    CGFloat heightAccum = 0.0f;
//    
//    CGSize titleTextSize = [((Exercise*)exercise).nameBasic sizeWithFont:[UIFont boldSystemFontOfSize:24.0f] constrainedToSize:CGSizeMake(275.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//    CGSize subtitleTextSize = [((Exercise*)exercise).nameTechnical sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(275.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    heightAccum = 8 + titleTextSize.height + 6 + subtitleTextSize.height + 12 + kExerciseTagHeight + 10 + kMediaSelectorContainerHeight + kMediaViewPadding + kMediaViewHeight + kMediaTabViewHeight + kMediaTabBottomPadding + kOrangeSectionHeaderViewHeight;
//    
//    CGFloat instructionsTableHeight = [[self class] heightForInstructionsTableViewWithExercise:exercise];
//    heightAccum += instructionsTableHeight;
//    
//    if([exercise isKindOfClass:[Exercise class]] && [exercise getEquipment] != nil) {
//        
//        CGFloat containerHeight = ([[exercise getEquipment] count] > 2) ? kEquipmentContainerHeightExpanded : kEquipmentContainerHeightCompact;
//        heightAccum += kOrangeSectionHeaderViewHeight + containerHeight;
//        
//    } else if([exercise isKindOfClass:[PractitionerExercise class]] && ((PractitionerExercise*)exercise).equipment && [((PractitionerExercise*)exercise).equipment count] > 0) {
//        
//        CGFloat containerHeight = ([((PractitionerExercise*)exercise).equipment count] > 2) ? kEquipmentContainerHeightExpanded : kEquipmentContainerHeightCompact;
//        heightAccum += kOrangeSectionHeaderViewHeight + containerHeight;
//    }
//    
//    heightAccum += kOrangeSectionHeaderViewHeight;
//    
//    CGSize sizeForLevelText = [[exercise getLevelString] sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(kLevelImageWidth + 10, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//    CGSize sizeForPurpose = [[exercise purpose] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(208, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    CGFloat exerciseLevelHeight = 10.0f + kLevelImageWidth + sizeForLevelText.height + 15.0f;
//    CGFloat purposeHeight = 7.0f + 16.0f + 10.0f + sizeForPurpose.height + 15.0f;
//    
//    heightAccum += MAX(exerciseLevelHeight, purposeHeight);
//    
//    if([exercise isKindOfClass:[Exercise class]] && [((Exercise*)exercise).related count] > 0) {
//        heightAccum += 40 + ([[self class] heightForRelatedExercisesTableViewWithExercise:exercise]) + 15.0f;
//    }
//    
//    return heightAccum;
//}
//
//+ (CGFloat)heightForInstructionsTableViewWithExercise:(id)exercise {
//    
//    CGFloat instructionTableHeightAccum = 0.0f;
//    if([exercise isKindOfClass:[Exercise class]]) {
//     
//        NSArray * processedInstructions = [((Exercise*)exercise) getInstructionList];
//        for(NSDictionary * instructionDict in processedInstructions) {
//            instructionTableHeightAccum += [ExerciseInstrutionCell heightWithExerciseInstructionString:instructionDict[@"instruction"]];
//        }
//        
//    } else if([exercise isKindOfClass:[PractitionerExercise class]]) {
//        
//        PractitionerExercise * practitionerExercise = (PractitionerExercise*)exercise;
//        if(practitionerExercise.instructions) {
//            for(NSDictionary * instructionDict in practitionerExercise.instructions) {
//                instructionTableHeightAccum += [ExerciseInstrutionCell heightWithExerciseInstructionString:instructionDict[@"instruction"]];
//            }
//        }
//    }
//    
//    return instructionTableHeightAccum;
//}
//
//+ (CGFloat)heightForRelatedExercisesTableViewWithExercise:(Exercise*)exercise {
//    return ([exercise.relatedExercises count] * 55.0f);
//}
//
//#pragma mark - UICollectionViewDataSource Methods
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    
//    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
//        return [[self.selectedExercise getEquipment] count];
//    } else {
//        return [[((PractitionerExercise*)self.selectedExercise) equipment] count];
//    }
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    ExerciseEquipmentCell * cell = (ExerciseEquipmentCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kExerciseEquipmentCellReuseIdentifier forIndexPath:indexPath];    
//    
//    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
//     
//        NSArray * equipmentStrings = [self.selectedExercise getEquipment];
//        cell.equipmentString = equipmentStrings[indexPath.row];
//        
//    } else {
//        
//        PractitionerExercise * practitionerExercise = (PractitionerExercise*)self.selectedExercise;
//        NSDictionary * equipmentDict = practitionerExercise.equipment[indexPath.row];
//        
//        if(equipmentDict) {
//            cell.equipmentString = equipmentDict[@"name"];
//            
//            if([[equipmentDict allKeys] containsObject:@"image"] && [equipmentDict[@"image"] length] > 0) {
//                
//                __block ExerciseEquipmentCell * blockCell = cell;
//                [cell.equipmentImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:equipmentDict[@"image"]]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                    
//                    blockCell.equipmentImageView.image = image;
//                    [blockCell setNeedsLayout];
//                    
//                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                    NSLog(@"Unable to load equipment image: %@", [error localizedDescription]);
//                }];
//            }
//        }
//    }
//    
//    return cell;
//}
//
//#pragma mark - UICollectionViewDelegate Methods
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSLog(@"collectionView: didSelectItemAtIndexPath:");    
//    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
//    
//    ExerciseEquipmentCell *cell = (ExerciseEquipmentCell*)[self.equipmentCollectionView cellForItemAtIndexPath:indexPath];
//    cell.itemHighlightView.alpha = 1.0f;
//    [UIView animateWithDuration:0.5f delay:0 options:(UIViewAnimationOptionAllowUserInteraction)
//        animations:^{
//            NSLog(@"animation start");
//            cell.itemHighlightView.alpha = 0.0f;
//        }
//        completion:^(BOOL finished){
//            NSLog(@"animation end");
//        }
//     ];
//    
//    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
//        NSArray * equipmentStrings = [self.selectedExercise getEquipment];
//        
//        if([self.exerciseDelegate respondsToSelector:@selector(exerciseDetailScrollView:didTapExerciseEquipmentItem:)]) {
//            [self.exerciseDelegate performSelector:@selector(exerciseDetailScrollView:didTapExerciseEquipmentItem:) withObject:self withObject:equipmentStrings[indexPath.row]];
//        }
//        
//    } else if([self.selectedExercise isKindOfClass:[PractitionerExercise class]]) {
//        
//        PractitionerExercise * practitionerExercise = (PractitionerExercise*)self.selectedExercise;
//        NSDictionary * equipmentDict = practitionerExercise.equipment[indexPath.row];
//        
//        // TODO: Equipment has image, show in FGalleryController
//        if([[equipmentDict allKeys] containsObject:@"image"] && [equipmentDict[@"image"] length] > 0) {
//            
//        }
//    }
//}
//
//#pragma mark - UICollectionViewDelegateFlowLayout Methods
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(kExerciseEquipmentCellBoxWidth, kExerciseEquipmentCellBoxHeight);
//}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
//        insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(6, 6, 10, 6);
//}
//
//#pragma mark - ExerciseGalleryViewDelegate Methods
//- (void)exerciseGalleryView:(ExerciseGalleryView*)galleryView didTapZoomButtonWithImage:(UIImage*)image {
//    if([self.exerciseDelegate respondsToSelector:@selector(exerciseDetailScrollView:didTapGalleryButtonWithImage:)]) {
//        [self.exerciseDelegate performSelector:@selector(exerciseDetailScrollView:didTapGalleryButtonWithImage:) withObject:self withObject:image];
//    }
//}
//
//#pragma mark - ExerciseSelectionChangeDelegate Methods
//- (void)exerciseSelectorView:(ExerciseSelectorView *)view didChangeSelection:(NSNumber*)selectionIndex {
//    
//    if([selectionIndex intValue] == self.visibleMediaView) return;
//    
//    self.visibleMediaView = [selectionIndex intValue];
//    [UIView animateWithDuration:0.3f animations:^{
//        
//        // Video -> Images
//        if(self.visibleMediaView == ExerciseMediaViewImages) {
//            
//            ExerciseGalleryView * galleryView = self.mediaViews[0];
//            galleryView.frame = CGRectMake(0, galleryView.frame.origin.y, galleryView.frame.size.width, galleryView.frame.size.height);
//            
//            ExerciseGalleryView * altGalleryView = self.mediaViews[1];
//            altGalleryView.frame = CGRectMake(self.frame.size.width, galleryView.frame.origin.y, galleryView.frame.size.width, galleryView.frame.size.height);
//            
//        } else { // Images -> Video
//            
//            ExerciseGalleryView * galleryView = self.mediaViews[0];
//            galleryView.frame = CGRectMake(-self.frame.size.width, galleryView.frame.origin.y, galleryView.frame.size.width, galleryView.frame.size.height);
//            
//            ExerciseGalleryView * altGalleryView = self.mediaViews[1];
//            altGalleryView.frame = CGRectMake(0, galleryView.frame.origin.y, galleryView.frame.size.width, galleryView.frame.size.height);
//            
//            // If a video exists and hasn't yet been played
//            if([self.selectedExercise getVideoFilePath] && !self.videoInitiallyPlayed) {
//                [altGalleryView.playerController play];
//                self.videoInitiallyPlayed = YES;
//            }
//            
//        }
//    }];
//}
//
//- (void)didTapStar:(id)sender {
//    NSLog(@"didTapStar:");
//    [self toggleExerciseInMyExercises:sender];
//}
//
//- (void)didTapLevelButton:(id)sender {
//    
//    UIButton * levelButton = (UIButton*)sender;
//    
//    if([self.exerciseDelegate respondsToSelector:@selector(exerciseDetailScrollView:didTapDifficultyButton:)]) {
//        [self.exerciseDelegate performSelector:@selector(exerciseDetailScrollView:didTapDifficultyButton:) withObject:self withObject:levelButton];
//    }
//}

@end
