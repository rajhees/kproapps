//
//  ExerciseCleanDetailScrollView.m
//  Exersite
//
//  Created by James Eunson on 25/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseCleanDetailScrollView.h"
#import "PractitionerExercise.h"
#import "Exercise.h"
#import "ExerciseType.h"
#import "NSObject+PerformBlockAfterDelay.h"
#import "ExerciseDetailSubtitleCell.h"
#import "ExerciseCell.h"
#import "ExerciseInstrutionCell.h"
#import "UIImageView+AFNetworking.h"

#define kExerciseMediaContainerHeight 240.0f
#define kExerciseMediaScrollViewHeight 180.0f

#define kDifficultyCellReuseIdentifier @"difficultyCell"
#define kPurposeCellReuseIdentifier @"purposeCell"
#define kEquipmentCellReuseIdentifier @"equipmentCell"
#define kPrescribedTimeCellReuseIdentifier @"prescribedTimeCell"
#define kRelatedProgramCellReuseIdentifier @"relatedProgramCell"
#define kRelatedExerciseCellReuseIdentifier @"relatedExerciseCell"

#define kExercisePurposeCellTitle @"Exercise Purpose"

@interface ExerciseCleanDetailScrollView ()
- (void)didTapSubtitleButton:(id)sender;
- (void)didTapStarredButton:(id)sender;
- (void)didTapAddToMyExercisesButton:(id)sender;
- (void)didTapStartExerciseButton:(id)sender;

- (void)toggleStarredForSelectedExercise;

@property (nonatomic, strong) UIView * heightView;

@property (nonatomic, strong) NSMutableArray * relatedPrograms; // Stored here for stable ordering, away from original NSSet in model

@property (nonatomic, strong) NSMutableDictionary * foundCategoryForEquipment;
@property (nonatomic, strong) UIImage * foundCategoryEquipmentImage;
@property (nonatomic, assign) NSInteger foundCategoryRowIndex;

@end

@implementation ExerciseCleanDetailScrollView

- (id)init {
    self = [super init];
    if(self) {
        
        self.foundCategoryRowIndex = -1;
        self.contentSize = CGSizeMake(0, 0);
        self.backgroundColor = [UIColor clearColor];
        
        self.relatedPrograms = [[NSMutableArray alloc] init];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];
        
        self.technicalTitleLabel = [[UILabel alloc] init];
        _technicalTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _technicalTitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _technicalTitleLabel.backgroundColor = [UIColor clearColor];
        _technicalTitleLabel.numberOfLines = 0;
        _technicalTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_technicalTitleLabel];
        
        self.subtitleButton = [[UIButton alloc] init];
        [_subtitleButton addTarget:self action:@selector(didTapSubtitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_subtitleButton];
        
        self.subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _subtitleLabel.textColor = RGBCOLOR(142, 142, 149);
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        [_subtitleButton addSubview:_subtitleLabel];
     
        self.subtitleArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"program-item-arrow-ios7"]];
        [_subtitleButton addSubview:_subtitleArrowImageView];
        
        self.starredContainerView = [[UIView alloc] init];
        _starredContainerView.backgroundColor = [UIColor whiteColor];
        _starredContainerView.layer.borderColor = [RGBCOLOR(221, 221, 221) CGColor];
        _starredContainerView.layer.borderWidth = 1.0f;
        _starredContainerView.layer.masksToBounds = YES;
        _starredContainerView.layer.cornerRadius = 4.0f;
        [self addSubview:_starredContainerView];
        
        self.starredButton = [[UIButton alloc] init];
        _starredButton.frame = CGRectMake(0, 0, 28, 26);
        [_starredButton setImage:[UIImage imageNamed:@"exercise-detail-starred-normal-icon-ios7"] forState:UIControlStateNormal];
        [_starredButton setImage:[UIImage imageNamed:@"exercise-detail-starred-selected-icon-ios7"] forState:UIControlStateSelected];
        [_starredButton addTarget:self action:@selector(didTapStarredButton:) forControlEvents:UIControlEventTouchUpInside];
        [_starredContainerView addSubview:_starredButton];
        
        self.mediaView = [[ExerciseMediaView alloc] init];
        _mediaView.delegate = self;
        [self addSubview:_mediaView];
        
        self.instructionsTitleLabel = [[UILabel alloc] init];
        _instructionsTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _instructionsTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _instructionsTitleLabel.backgroundColor = [UIColor clearColor];
        _instructionsTitleLabel.text = @"Instructions";
        [self addSubview:_instructionsTitleLabel];
        
        self.instructionsTableViewTopBorder = [CALayer layer];
        _instructionsTableViewTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_instructionsTableViewTopBorder atIndex:100];
        
        self.instructionsTableView = [[ExerciseInstructionTableView alloc] initWithFrame:CGRectZero selectedExercise:self.selectedExercise mode:ExerciseInstructionTableViewModeNormal];
        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            _instructionsTableView.separatorInset = UIEdgeInsetsZero;
        }
        [self addSubview:self.instructionsTableView];
        
        self.moreInformationTitleLabel = [[UILabel alloc] init];
        _moreInformationTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _moreInformationTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _moreInformationTitleLabel.backgroundColor = [UIColor clearColor];
        _moreInformationTitleLabel.text = @"More Information";
        [self addSubview:_moreInformationTitleLabel];
        
        self.moreInformationTopBorder = [CALayer layer];
        _moreInformationTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_moreInformationTopBorder atIndex:100];
        
        self.moreInformationTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _moreInformationTableView.delegate = self;
        _moreInformationTableView.dataSource = self;
        _moreInformationTableView.separatorInset = UIEdgeInsetsZero;
        [_moreInformationTableView registerClass:[ExerciseDetailSubtitleCell class] forCellReuseIdentifier:kDifficultyCellReuseIdentifier];
        [_moreInformationTableView registerClass:[ExerciseDetailSubtitleCell class] forCellReuseIdentifier:kPurposeCellReuseIdentifier];
        [self addSubview:_moreInformationTableView];
        
        self.equipmentTitleLabel = [[UILabel alloc] init];
        _equipmentTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _equipmentTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _equipmentTitleLabel.backgroundColor = [UIColor clearColor];
        _equipmentTitleLabel.text = @"Equipment";
        [self addSubview:_equipmentTitleLabel];
        
        self.equipmentTopBorder = [CALayer layer];
        _equipmentTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_equipmentTopBorder atIndex:100];
        
        self.equipmentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _equipmentTableView.delegate = self;
        _equipmentTableView.dataSource = self;
        _equipmentTableView.separatorInset = UIEdgeInsetsZero;
        [_equipmentTableView registerClass:[ExerciseDetailSubtitleCell class] forCellReuseIdentifier:kEquipmentCellReuseIdentifier];
        [self addSubview:_equipmentTableView];
        
        self.relatedProgramsTitleLabel = [[UILabel alloc] init];
        _relatedProgramsTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _relatedProgramsTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _relatedProgramsTitleLabel.backgroundColor = [UIColor clearColor];
        _relatedProgramsTitleLabel.text = @"Related Programs";
        _relatedProgramsTitleLabel.hidden = YES;
        [self addSubview:_relatedProgramsTitleLabel];
        
        self.relatedProgramsTopBorder = [CALayer layer];
        _relatedProgramsTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        _relatedProgramsTopBorder.hidden = YES;
        [self.layer insertSublayer:_relatedProgramsTopBorder atIndex:100];
        
        self.relatedProgramsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _relatedProgramsTableView.delegate = self;
        _relatedProgramsTableView.dataSource = self;
        _relatedProgramsTableView.separatorInset = UIEdgeInsetsZero;
        [_relatedProgramsTableView registerClass:[ExerciseDetailSubtitleCell class] forCellReuseIdentifier:kRelatedProgramCellReuseIdentifier];
        _relatedProgramsTableView.hidden = YES;
        [self addSubview:_relatedProgramsTableView];
        
        self.relatedExercisesTitleLabel = [[UILabel alloc] init];
        _relatedExercisesTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _relatedExercisesTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _relatedExercisesTitleLabel.backgroundColor = [UIColor clearColor];
        _relatedExercisesTitleLabel.text = @"Related Exercises";
        [self addSubview:_relatedExercisesTitleLabel];
        
        self.relatedExercisesTopBorder = [CALayer layer];
        _relatedExercisesTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_relatedExercisesTopBorder atIndex:100];
        
        self.relatedExercisesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _relatedExercisesTableView.delegate = self;
        _relatedExercisesTableView.dataSource = self;
        _relatedExercisesTableView.separatorInset = UIEdgeInsetsZero;
        [_relatedExercisesTableView registerClass:[ExerciseDetailSubtitleCell class] forCellReuseIdentifier:kRelatedExerciseCellReuseIdentifier];
        [self addSubview:_relatedExercisesTableView];
        
        self.addToMyExercisesButton = [[ExerciseBigButton alloc] init];
        _addToMyExercisesButton.exerciseButtonType = ExerciseBigButtonTypeAddToMyExercises;
        [_addToMyExercisesButton addTarget:self action:@selector(didTapAddToMyExercisesButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addToMyExercisesButton];
        
        self.startExerciseButton = [[ExerciseBigButton alloc] init];
        _startExerciseButton.exerciseButtonType = ExerciseBigButtonTypeStartExercise;
        [_startExerciseButton addTarget:self action:@selector(didTapStartExerciseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_startExerciseButton];
        
//        self.heightView = [[UIView alloc] init];
//        _heightView.userInteractionEnabled = NO;
//        _heightView.backgroundColor = [UIColor redColor];
//        _heightView.alpha = 0.3f;
//        [self addSubview:_heightView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTitleLabel = [_titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f - 55.0f - 8.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.titleLabel.frame = CGRectMake(8.0f, 8.0f, sizeForTitleLabel.width, sizeForTitleLabel.height);
    
    CGSize sizeForTechnicalTitleLabel = [_technicalTitleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f - 55.0f - 8.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.technicalTitleLabel.frame = CGRectMake(8.0f, _titleLabel.frame.origin.y + _titleLabel.frame.size.height, sizeForTechnicalTitleLabel.width, sizeForTechnicalTitleLabel.height);
    
    _starredContainerView.frame = CGRectMake(self.frame.size.width - 55.0f + 10.0f, 8, 55.0f, 35.0f);
    _starredButton.frame = CGRectMake(8.0f, (_starredContainerView.frame.size.height / 2) - (_starredButton.frame.size.height / 2) - 1.0f, _starredButton.frame.size.width, _starredButton.frame.size.height);
    
    CGSize subtitleTextSize = [self.subtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 90.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.subtitleLabel.frame = CGRectMake(0, 0, subtitleTextSize.width, subtitleTextSize.height);
    
    self.subtitleArrowImageView.frame = CGRectMake(_subtitleLabel.frame.origin.x + _subtitleLabel.frame.size.width + 6.0f, 2.0f, _subtitleArrowImageView.frame.size.width, _subtitleArrowImageView.frame.size.height);
    
    self.subtitleButton.frame = CGRectMake(8, _technicalTitleLabel.frame.origin.y + _technicalTitleLabel.frame.size.height + 2.0f, subtitleTextSize.width + _subtitleArrowImageView.frame.size.width + 6.0f, MAX(_subtitleLabel.frame.size.height, _subtitleArrowImageView.frame.size.height));
    
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        self.mediaView.frame = CGRectMake(0, _subtitleButton.frame.origin.y + _subtitleButton.frame.size.height + 19.0f, self.frame.size.width, kExerciseMediaContainerHeight);
    } else {
        self.mediaView.frame = CGRectMake(0, _subtitleButton.frame.origin.y + _subtitleButton.frame.size.height + 19.0f, self.frame.size.width, kExerciseMediaContainerPractitionerExerciseHeight);
    }
    
    CGSize sizeForMoreInformationTitleLabel = [_moreInformationTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
    _moreInformationTitleLabel.frame = CGRectMake(8.0f, _mediaView.frame.origin.y + _mediaView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, sizeForMoreInformationTitleLabel.height);
    
    _moreInformationTopBorder.frame = CGRectMake(0, _moreInformationTitleLabel.frame.origin.y + _moreInformationTitleLabel.frame.size.height + 19.0f, self.frame.size.width, 1.0f);
    _moreInformationTableView.frame = CGRectMake(0, _moreInformationTitleLabel.frame.origin.y + _moreInformationTitleLabel.frame.size.height + 20.0f, self.frame.size.width, ([ExerciseDetailSubtitleCell heightForCellWithText:[self.selectedExercise getLevelString] detailText:[self.selectedExercise getLevelExplanationString]]) + ([ExerciseDetailSubtitleCell heightForCellWithText:kExercisePurposeCellTitle detailText:[self.selectedExercise purpose]]));
    
    CGSize sizeForInstructionsTitleLabel = [_instructionsTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
    _instructionsTitleLabel.frame = CGRectMake(8.0f, _moreInformationTableView.frame.origin.y + _moreInformationTableView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, sizeForInstructionsTitleLabel.height);
    
    _instructionsTableViewTopBorder.frame = CGRectMake(0, _instructionsTitleLabel.frame.origin.y + _instructionsTitleLabel.frame.size.height + 19.0f, self.frame.size.width, 1.0f);
    _instructionsTableView.frame = CGRectMake(0, _instructionsTitleLabel.frame.origin.y + _instructionsTitleLabel.frame.size.height + 20.0f, self.frame.size.width, [ExerciseInstructionTableView heightForInstructionsTableViewWithExercise:self.selectedExercise]);
    
    CGFloat startPointForActionButtons = _instructionsTableView.frame.origin.y + _instructionsTableView.frame.size.height;
    CGFloat startPointForRelatedPrograms = _instructionsTableView.frame.origin.y + _instructionsTableView.frame.size.height;
    CGFloat startPointForRelatedExercises = _instructionsTableView.frame.origin.y + _instructionsTableView.frame.size.height;
    
    if(!self.equipmentTableView.hidden) {
        
        CGSize sizeForEquipmentTitleLabel = [_equipmentTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
        _equipmentTitleLabel.frame = CGRectMake(8.0f, _instructionsTableView.frame.origin.y + _instructionsTableView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, sizeForEquipmentTitleLabel.height);
        
        NSInteger equipmentCount = [[_selectedExercise getEquipment] count];
        _equipmentTopBorder.frame = CGRectMake(0, _equipmentTitleLabel.frame.origin.y + _equipmentTitleLabel.frame.size.height + 19.0f, self.frame.size.width, 1.0f);
        _equipmentTableView.frame = CGRectMake(0, _equipmentTitleLabel.frame.origin.y + _equipmentTitleLabel.frame.size.height + 20.0f, self.frame.size.width, equipmentCount * 50.0f); // TODO!

        startPointForRelatedPrograms = _equipmentTableView.frame.origin.y + _equipmentTableView.frame.size.height;
        startPointForRelatedExercises = _equipmentTableView.frame.origin.y + _equipmentTableView.frame.size.height;
        startPointForActionButtons = _equipmentTableView.frame.origin.y + _equipmentTableView.frame.size.height;
    }
    
    if(!self.relatedProgramsTableView.hidden) {
        
        CGSize sizeForRelatedProgramsTitleLabel = [_relatedProgramsTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
        _relatedProgramsTitleLabel.frame = CGRectMake(8.0f, startPointForRelatedPrograms + 8.0f, self.frame.size.width - 16.0f, sizeForRelatedProgramsTitleLabel.height);
        
        _relatedProgramsTopBorder.frame = CGRectMake(0, _relatedProgramsTitleLabel.frame.origin.y + _relatedProgramsTitleLabel.frame.size.height + 19.0f, self.frame.size.width, 1.0f);
        _relatedProgramsTableView.frame = CGRectMake(0, _relatedProgramsTitleLabel.frame.origin.y + _relatedProgramsTitleLabel.frame.size.height + 20.0f, self.frame.size.width, [_relatedPrograms count] * 50.0f);
        
        startPointForRelatedExercises = _relatedProgramsTableView.frame.origin.y + _relatedProgramsTableView.frame.size.height;
        startPointForActionButtons = _relatedProgramsTableView.frame.origin.y + _relatedProgramsTableView.frame.size.height;
    }
    
    if(!self.relatedExercisesTableView.hidden) {
        
        CGSize sizeForRelatedExercisesTitleLabel = [_relatedExercisesTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
        _relatedExercisesTitleLabel.frame = CGRectMake(8.0f, startPointForRelatedExercises + 8.0f, self.frame.size.width - 16.0f, sizeForRelatedExercisesTitleLabel.height);
        
        _relatedExercisesTopBorder.frame = CGRectMake(0, _relatedExercisesTitleLabel.frame.origin.y + _relatedExercisesTitleLabel.frame.size.height + 19.0f, self.frame.size.width, 1.0f);
        _relatedExercisesTableView .frame = CGRectMake(0, _relatedExercisesTitleLabel.frame.origin.y + _relatedExercisesTitleLabel.frame.size.height + 20.0f, self.frame.size.width, [[((Exercise*)self.selectedExercise) relatedExercises] count] * 50.0f);
        
        startPointForActionButtons = _relatedExercisesTableView.frame.origin.y + _relatedExercisesTableView.frame.size.height;
    }
    
    _addToMyExercisesButton.frame = CGRectMake(8.0f, startPointForActionButtons + 8.0f, self.frame.size.width - 16.0f, 44.0f);
    _startExerciseButton.frame = CGRectMake(8.0f, _addToMyExercisesButton.frame.origin.y + _addToMyExercisesButton.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
    
//    _heightView.frame = CGRectMake(0, 0, self.frame.size.width, [[self class] heightForScrollViewWithExercise:self.selectedExercise]);
    
    self.contentSize = CGSizeMake(self.frame.size.width, [[self class] heightForScrollViewWithExercise:self.selectedExercise]);
}

+ (CGFloat)heightForScrollViewWithExercise:(id)selectedExercise {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 0;
    
    Exercise * databaseExercise = (Exercise*)selectedExercise;
    
    CGSize sizeForTitleLabel = [databaseExercise.nameBasic sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f - 55.0f - 8.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize sizeForTechnicalTitleLabel = [databaseExercise.nameTechnical sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f - 55.0f - 8.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    heightAccumulator += 8.0f + sizeForTitleLabel.height + sizeForTechnicalTitleLabel.height;
    
    CGSize subtitleTextSize = CGSizeZero;
    if([selectedExercise isKindOfClass:[PractitionerExercise class]]) {
        
        NSString * firstType = [((PractitionerExercise*)selectedExercise).types firstObject];
        subtitleTextSize = [firstType sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 90.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
    } else {
        ExerciseType * firstType = [[databaseExercise.types allObjects] firstObject];
        subtitleTextSize = [firstType.name sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 90.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    CGSize sizeForInstructionsTitleLabel = [@"Instructions" sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
    heightAccumulator += 2.0f + 1.0f + subtitleTextSize.height + 20.0f + kExerciseMediaContainerHeight + 8.0f + sizeForInstructionsTitleLabel.height + 20;
    
    if([selectedExercise isKindOfClass:[PractitionerExercise class]]) {
        for(NSDictionary * instruction in ((PractitionerExercise*)selectedExercise).instructions) {
            heightAccumulator += [ExerciseInstrutionCell heightWithExerciseInstructionString:instruction[@"instruction"]];
        }
    } else {
        for(NSDictionary * instruction in [databaseExercise getInstructionList]) {
            heightAccumulator += [ExerciseInstrutionCell heightWithExerciseInstructionString:instruction[@"instruction"]];
        }
    }
    
    CGSize sizeForMoreInformationTitleLabel = [@"More Information" sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
    heightAccumulator += 8.0f + sizeForMoreInformationTitleLabel.height + 20.0f + ([ExerciseDetailSubtitleCell heightForCellWithText:[databaseExercise getLevelString] detailText:[databaseExercise getLevelExplanationString]]) + ([ExerciseDetailSubtitleCell heightForCellWithText:kExercisePurposeCellTitle detailText:[databaseExercise purpose]]);
    
    if([selectedExercise isKindOfClass:[PractitionerExercise class]]) {
        
        PractitionerExercise * practitionerExercise = (PractitionerExercise*)selectedExercise;
        if(practitionerExercise.equipment && [practitionerExercise.equipment count] > 0) {
            CGSize sizeForEquipmentTitleLabel = [@"Equipment" sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
            heightAccumulator += 8.0f + sizeForEquipmentTitleLabel.height + 20.0f + (50.0f * [practitionerExercise.equipment count]);
        }
        
    } else {
        if([databaseExercise getEquipment] && [[databaseExercise getEquipment] count] > 0) {
            
            CGSize sizeForEquipmentTitleLabel = [@"Equipment" sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
            heightAccumulator += 8.0f + sizeForEquipmentTitleLabel.height + 20.0f + (50.0f * [[databaseExercise getEquipment] count]);
        }
        
        if([databaseExercise programs] && [[databaseExercise programs] count] > 0) {
            CGSize sizeForRelatedExercisesTitleLabel = [@"Related Programs" sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
            heightAccumulator += 8.0f + sizeForRelatedExercisesTitleLabel.height + 20.0f + (50.0f * [[databaseExercise programs] count]);
        }
        
        if([databaseExercise relatedExercises] && [[databaseExercise relatedExercises] count] > 0) {
            CGSize sizeForRelatedExercisesTitleLabel = [@"Related Exercises" sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
            heightAccumulator += 8.0f + sizeForRelatedExercisesTitleLabel.height + 20.0f + (50.0f * [[databaseExercise relatedExercises] count]);
        }
    }
    
    heightAccumulator += 8.0f + (44.0f * 2) + 20.0f; // Bottom padding of 20.0f
    
    return heightAccumulator;
}

- (void)updateMediaScrollViewContentOffset {
    [self.mediaView updateMediaScrollViewContentOffset];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.moreInformationTableView) {
        return 2;
        
    } else if(tableView == self.equipmentTableView) {
        
        if([self.selectedExercise isKindOfClass:[Exercise class]]) {
            return [[self.selectedExercise getEquipment] count];
        } else {
            return [((PractitionerExercise*)_selectedExercise).equipment count];
        }
        
    } else if(tableView == self.relatedExercisesTableView) {
        
        if([self.selectedExercise isKindOfClass:[Exercise class]]) {
            return [[self.selectedExercise relatedExercises] count];
        }
        
    } else if(tableView == self.relatedProgramsTableView) {
        
        if([self.selectedExercise isKindOfClass:[Exercise class]]) {
            return [_relatedPrograms count];
        }
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.moreInformationTableView) {
        return 1;
        
    } else if(tableView == self.equipmentTableView) {
        return 1;
        
    } else if(tableView == self.relatedExercisesTableView) {
        return 1;
        
    } else if(tableView == self.relatedProgramsTableView) {
        return 1;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.moreInformationTableView) {
        
        ExerciseDetailSubtitleCell * cell = [self.moreInformationTableView dequeueReusableCellWithIdentifier:kDifficultyCellReuseIdentifier forIndexPath:indexPath];
        
        if(indexPath.row == 0) {
            
            cell.textLabel.text = [self.selectedExercise getLevelString];
            
            ExerciseLevel level = [((Exercise*)self.selectedExercise).level integerValue];
            
            cell.type = ExerciseDetailSubtitleCellTypeDifficulty;
            cell.difficultyLevel = level;
            cell.detailTextLabel.text = [((Exercise*)self.selectedExercise) getLevelExplanationString];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
        } else if(indexPath.row == 1) {
            
            cell.textLabel.text = kExercisePurposeCellTitle;
            cell.detailTextLabel.text = [self.selectedExercise purpose];
            
            cell.type = ExerciseDetailSubtitleCellTypePurpose;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
        
    } else if(tableView == self.equipmentTableView) {
        
        ExerciseDetailSubtitleCell * cell = [self.equipmentTableView dequeueReusableCellWithIdentifier:kEquipmentCellReuseIdentifier forIndexPath:indexPath];
        
        NSString * equipmentString = nil;
        if([self.selectedExercise isKindOfClass:[Exercise class]]) {
            equipmentString = [self.selectedExercise getEquipment][indexPath.row];
            
            if(_foundCategoryForEquipment && _foundCategoryEquipmentImage) {
                
                cell.imageView.image = _foundCategoryEquipmentImage;
                cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                cell.imageView.layer.cornerRadius = 4.0f;
                cell.imageView.layer.masksToBounds = YES;
                cell.imageView.layer.borderColor = [RGBCOLOR(203, 203, 203) CGColor];
                cell.imageView.layer.borderWidth = 1.0f;
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                
            } else {
                
                if(_equipmentCategories) {
                    for(NSDictionary * category in _equipmentCategories) {
                        if([[category[@"name"] lowercaseString] rangeOfString:[equipmentString lowercaseString]].location != NSNotFound) {
                            self.foundCategoryForEquipment = [category mutableCopy];
                            self.foundCategoryRowIndex = [indexPath row];
                            
                            // Required for the related shop controller to function
                            _foundCategoryForEquipment[@"related"] = _foundCategoryForEquipment[@"short-name"];
                            break;
                        }
                    }
                }
                
                if(_foundCategoryForEquipment) {
                    
                    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:_foundCategoryForEquipment[@"image"]]];
                    
                    __block ExerciseDetailSubtitleCell * blockCell = cell;
                    [cell.imageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"exercise-detail-equipment-icon-ios7"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        
                        self.foundCategoryEquipmentImage = image;
                        
                        blockCell.imageView.image = image;
                        [blockCell setNeedsLayout];
                        
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        
                    }];
                    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                    cell.imageView.layer.cornerRadius = 4.0f;
                    cell.imageView.layer.masksToBounds = YES;
                    cell.imageView.layer.borderColor = [RGBCOLOR(203, 203, 203) CGColor];
                    cell.imageView.layer.borderWidth = 1.0f;
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
            
        } else {
            NSDictionary * equipment = ((PractitionerExercise*)self.selectedExercise).equipment[indexPath.row];
            equipmentString = equipment[@"name"];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = equipmentString;
        cell.type = ExerciseDetailSubtitleCellTypeEquipment;
        
        return cell;
        
    } else if(tableView == self.relatedExercisesTableView) {
        
        Exercise * relatedExercise = [self.selectedExercise relatedExercises][indexPath.row];
        ExerciseDetailSubtitleCell * cell = [self.relatedExercisesTableView dequeueReusableCellWithIdentifier:kRelatedExerciseCellReuseIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = relatedExercise.nameBasic;
        cell.detailTextLabel.text = relatedExercise.typesString;
        
        cell.imageView.image = [[relatedExercise getImages] firstObject];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.layer.cornerRadius = 4.0f;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.borderColor = [RGBCOLOR(203, 203, 203) CGColor];
        cell.imageView.layer.borderWidth = 1.0f;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    } else if(tableView == self.relatedProgramsTableView) {
        
        Program * relatedProgram = _relatedPrograms[indexPath.row];
        ExerciseDetailSubtitleCell * cell = [self.relatedProgramsTableView dequeueReusableCellWithIdentifier:kRelatedProgramCellReuseIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = relatedProgram.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d exercises", [relatedProgram.exercises count]];
        
        cell.imageView.image = [[[[relatedProgram.exercises allObjects] firstObject] getImages] firstObject];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.layer.cornerRadius = 4.0f;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.layer.borderColor = [RGBCOLOR(203, 203, 203) CGColor];
        cell.imageView.layer.borderWidth = 1.0f;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.moreInformationTableView) {
        if(indexPath.row == 0) {
            return [ExerciseDetailSubtitleCell heightForCellWithText:[self.selectedExercise getLevelString] detailText:[self.selectedExercise getLevelExplanationString]];
        } else if(indexPath.row == 1) {
            return [ExerciseDetailSubtitleCell heightForCellWithText:@"Exercise Purpose" detailText:[self.selectedExercise purpose]];
        }
    }
    
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == self.equipmentTableView) {
        
        if(!_foundCategoryForEquipment || indexPath.row != self.foundCategoryRowIndex) {
            return;
        }
        
        if([self.exerciseDetailDelegate respondsToSelector:@selector(exerciseCleanDetailScrollView:didSelectEquipmentCategory:)]) {
            [self.exerciseDetailDelegate performSelector:@selector(exerciseCleanDetailScrollView:didSelectEquipmentCategory:) withObject:self withObject:_foundCategoryForEquipment];
        }
        
    } else if(tableView == self.moreInformationTableView && indexPath.row == 0) {
        
        if([self.exerciseDetailDelegate respondsToSelector:@selector(exerciseCleanDetailScrollView:didSelectDifficultyExplanationWithIndexPath:)]) {
            [self.exerciseDetailDelegate performSelector:@selector(exerciseCleanDetailScrollView:didSelectDifficultyExplanationWithIndexPath:) withObject:self withObject:indexPath];
        }
        
    } else if(tableView == self.relatedExercisesTableView) {
        Exercise * selectedRelatedExercise = [((Exercise*)self.selectedExercise) relatedExercises][indexPath.row];
        
        if([self.exerciseDetailDelegate respondsToSelector:@selector(exerciseCleanDetailScrollView:didSelectRelatedExercise:)]) {
            [self.exerciseDetailDelegate performSelector:@selector(exerciseCleanDetailScrollView:didSelectRelatedExercise:) withObject:self withObject:selectedRelatedExercise];
        }
        
    } else if(tableView == self.relatedProgramsTableView) {
        
        Program * selectedRelatedProgram = _relatedPrograms[indexPath.row];
        
        if([self.exerciseDetailDelegate respondsToSelector:@selector(exerciseCleanDetailScrollView:didSelectRelatedProgram:)]) {
            [self.exerciseDetailDelegate performSelector:@selector(exerciseCleanDetailScrollView:didSelectRelatedProgram:) withObject:self withObject:selectedRelatedProgram];
        }
    }
}

#pragma mark - Property Override
- (void)setSelectedExercise:(id)selectedExercise {
    _selectedExercise = selectedExercise;
    
    if([selectedExercise isKindOfClass:[PractitionerExercise class]]) {
        
        PractitionerExercise * practitionerExercise = (PractitionerExercise*)selectedExercise;
        _starredContainerView.hidden = YES;
        _subtitleArrowImageView.hidden = YES;
        
        self.titleLabel.text = practitionerExercise.nameBasic;
        self.technicalTitleLabel.text = practitionerExercise.nameTechnical;
        
        self.instructionsTableView.selectedExercise = practitionerExercise;
        [self.instructionsTableView reloadData];
        
        NSString * type = [[practitionerExercise types] firstObject];
        self.subtitleLabel.text = type;
        
        _mediaView.selectedExercise = practitionerExercise;
        
        BOOL equipmentSectionHidden = !([practitionerExercise equipment] && [[practitionerExercise equipment] count] > 0);
        self.equipmentTitleLabel.hidden = self.equipmentTableView.hidden = self.equipmentTopBorder.hidden = equipmentSectionHidden;
        
        self.relatedProgramsTitleLabel.hidden = self.relatedProgramsTableView.hidden = self.relatedProgramsTopBorder.hidden = YES;
        self.relatedExercisesTitleLabel.hidden = self.relatedExercisesTableView.hidden = self.relatedExercisesTopBorder.hidden = YES;
        
    } else { // Exercise from local database
        
        Exercise * databaseExercise = (Exercise*)selectedExercise;
        _starredContainerView.hidden = NO;
        _subtitleArrowImageView.hidden = NO;
        
        self.titleLabel.text = databaseExercise.nameBasic;
        self.technicalTitleLabel.text = databaseExercise.nameTechnical;
        
        self.instructionsTableView.selectedExercise = databaseExercise;
        [self.instructionsTableView reloadData];
        
        ExerciseType * type = [[[databaseExercise types] allObjects] firstObject];
        self.subtitleLabel.text = type.name;
        
        if([databaseExercise isExerciseSaved]) {
            
            [_starredButton setSelected:YES];
            _addToMyExercisesButton.addToCartLabel.text = @"Remove from My Exercises";
        } else {
            [_starredButton setSelected:NO];
            _addToMyExercisesButton.addToCartLabel.text = @"Add to My Exercises";
        }
        
        _mediaView.selectedExercise = databaseExercise;

        BOOL equipmentSectionHidden = !([databaseExercise getEquipment] && [[databaseExercise getEquipment] count] > 0);
        self.equipmentTitleLabel.hidden = self.equipmentTableView.hidden = self.equipmentTopBorder.hidden = equipmentSectionHidden;
        
//        self.equipmentTitleLabel.hidden = equipmentSectionHidden;
//        self.equipmentTableView.hidden = equipmentSectionHidden;
//        self.equipmentTopBorder.hidden = equipmentSectionHidden;
        
        BOOL relatedProgramsSectionHidden = YES;
        if([databaseExercise isKindOfClass:[Exercise class]] && ([databaseExercise programs] && [[databaseExercise programs] count] > 0)) {
            relatedProgramsSectionHidden = NO;
        }
        
        if(!relatedProgramsSectionHidden) {
            [_relatedPrograms addObjectsFromArray:[[databaseExercise programs] allObjects]];
        }
        
        self.relatedProgramsTitleLabel.hidden = self.relatedProgramsTableView.hidden = self.relatedProgramsTopBorder.hidden = relatedProgramsSectionHidden;
        
//        self.relatedProgramsTitleLabel.hidden = relatedProgramsSectionHidden;
//        self.relatedProgramsTableView.hidden = relatedProgramsSectionHidden;
//        self.relatedProgramsTopBorder.hidden = relatedProgramsSectionHidden;
        
        BOOL relatedSectionHidden = YES;
        if([databaseExercise isKindOfClass:[Exercise class]] && ([databaseExercise relatedExercises] && [[databaseExercise relatedExercises] count] > 0)) {
            relatedSectionHidden = NO;
        }
        
        self.relatedExercisesTitleLabel.hidden = self.relatedExercisesTableView.hidden = self.relatedExercisesTopBorder.hidden = relatedSectionHidden;
        
//        self.relatedExercisesTitleLabel.hidden = relatedSectionHidden;
//        self.relatedExercisesTableView.hidden = relatedSectionHidden;
//        self.relatedExercisesTopBorder.hidden = relatedSectionHidden;
    }
    [self setNeedsLayout];
}

#pragma mark - Private Methods
- (void)didTapSubtitleButton:(id)sender {
//    NSLog(@"didTapSubtitleButton");
    
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        if([self.exerciseDetailDelegate respondsToSelector:@selector(exerciseCleanDetailScrollView:didTapSubtitleButton:)]) {
            [self.exerciseDetailDelegate performSelector:@selector(exerciseCleanDetailScrollView:didTapSubtitleButton:) withObject:self withObject:sender];
        }
    }
}

- (void)didTapStarredButton:(id)sender {
//    NSLog(@"didTapStarredButton:");
    [self toggleStarredForSelectedExercise];
}

- (void)didTapAddToMyExercisesButton:(id)sender {
//    NSLog(@"didTapAddToMyExercisesButton:");
    [self toggleStarredForSelectedExercise];
}

- (void)didTapStartExerciseButton:(id)sender {
//    NSLog(@"didTapStartExerciseButton:");
    
    if([self.exerciseDetailDelegate respondsToSelector:@selector(exerciseCleanDetailScrollView:didTapStartExerciseButton:)]) {
        [self.exerciseDetailDelegate performSelector:@selector(exerciseCleanDetailScrollView:didTapStartExerciseButton:) withObject:self withObject:sender];
    }
}

- (void)toggleStarredForSelectedExercise {

    if([self.exerciseDetailDelegate respondsToSelector:@selector(exerciseCleanDetailScrollView:didTapStarredButton:)]) {
        [self.exerciseDetailDelegate performSelector:@selector(exerciseCleanDetailScrollView:didTapStarredButton:) withObject:self withObject:nil];
    }
    
    Exercise * databaseExercise = (Exercise*)self.selectedExercise;
    
    if([databaseExercise isExerciseSaved]) {
        _addToMyExercisesButton.addToCartLabel.text = @"Remove from My Exercises";
        [_starredButton setSelected:YES];
        
    } else {
        _addToMyExercisesButton.addToCartLabel.text = @"Add to My Exercises";
        [_starredButton setSelected:NO];
    }
}

#pragma mark - ExerciseMediaViewDelegate Methods
- (void)exerciseMediaView:(ExerciseMediaView*)scrollView didTapImageViewWithParameters:(NSDictionary*)parameters {
//    NSLog(@"exerciseMediaView:didTapImageViewWithParameters:");
    
    if([self.exerciseDetailDelegate respondsToSelector:@selector(exerciseCleanDetailScrollView:didTapImageViewWithParameters:)]) {
        [self.exerciseDetailDelegate performSelector:@selector(exerciseCleanDetailScrollView:didTapImageViewWithParameters:) withObject:self withObject:parameters];
    }
}

@end
