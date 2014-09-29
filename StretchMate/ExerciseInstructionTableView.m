//
//  ExerciseInstructionTableView.m
//  StretchMate
//
//  Created by James Eunson on 9/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseInstructionTableView.h"
#import "ExerciseInstrutionCell.h"
#import "PractitionerExercise.h"

@interface ExerciseInstructionTableView()

@end

@implementation ExerciseInstructionTableView

- (id)initWithFrame:(CGRect)frame selectedExercise:(id)selectedExercise mode:(ExerciseInstructionTableViewMode)mode
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        
        self.selectedExercise = selectedExercise;
        self.mode = mode;
        
        self.delegate = self;
        self.dataSource = self;
        
        if(mode == ExerciseInstructionTableViewModeCompleting) {
            self.currentlySelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];            
        }
        
        [self registerClass:[ExerciseInstrutionCell class] forCellReuseIdentifier:@"instructionsCell"];
    }
    return self;
}

#pragma mark - UITableViewDelegate Methods
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"instructionsCell";
    
//    NSArray * processedInstructions = [self.selectedExercise getInstructionList];
    NSArray * instructions = nil;
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        instructions = [self.selectedExercise getInstructionList];
    } else {
        instructions = ((PractitionerExercise*)self.selectedExercise).instructions;
    }
    
    if(self.mode == ExerciseInstructionTableViewModeCompleting && indexPath.row == [instructions count]) { // Filler row
        
        // Blank cell
        UITableViewCell * cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else {
        
        ExerciseInstrutionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
        NSDictionary * cellInstruction = instructions[indexPath.row];
        
        cell.exerciseInstructionString = cellInstruction[@"instruction"];
        if([cellInstruction[@"number"] isKindOfClass:[NSNumber class]]) {
            cell.numberLabel.text = [cellInstruction[@"number"] stringValue];
        } else {
            cell.numberLabel.text = cellInstruction[@"number"];
        }
        
        if(self.mode == ExerciseInstructionTableViewModeCompleting) {
            if([indexPath isEqual:self.currentlySelectedIndexPath]) {
                cell.currentSelectedCell = YES;
            } else {
                cell.currentSelectedCell = NO;
            }
        }
        
        return cell;        
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        
        NSArray * processedInstructions = [self.selectedExercise getInstructionList];
        if(processedInstructions) {
            
            if(self.mode == ExerciseInstructionTableViewModeCompleting) {
                return [processedInstructions count] + 1;
            } else {
                return [processedInstructions count];
            }
        }
        
    } else if([self.selectedExercise isKindOfClass:[PractitionerExercise class]]) {
        NSArray * instructions = ((PractitionerExercise*)self.selectedExercise).instructions;
        if(instructions) {
            if(self.mode == ExerciseInstructionTableViewModeCompleting) {
                return [instructions count] + 1;
            } else {
                return [instructions count];
            }
        }
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * instructions = nil;
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        instructions = [self.selectedExercise getInstructionList];
    } else {
        instructions = ((PractitionerExercise*)self.selectedExercise).instructions;
    }
    
    if(self.mode == ExerciseInstructionTableViewModeCompleting && indexPath.row == [instructions count]) { // Filler cell
        
        // Should be size of last three items, to ensure the entire list is scrollable
        return self.frame.size.height;
        
    } else {
        
        NSDictionary * cellInstruction = instructions[indexPath.row];
        NSString * instructionString = cellInstruction[@"instruction"];
        
        return [ExerciseInstrutionCell heightWithExerciseInstructionString:instructionString];
    }
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.mode == ExerciseInstructionTableViewModeCompleting) {
        if(self.currentlySelectedIndexPath.row == indexPath.row || indexPath.row == ([self tableView:tableView numberOfRowsInSection:0] - 1)) {
            return;
        }
        
        [self deselectRowAtIndexPath:indexPath animated:NO];        
        [self updateSelectedIndexPath:indexPath shouldScrollToNewIndexPath:YES shouldNotifyDelegate:YES];
    }
}

+ (CGFloat)heightForInstructionsTableViewWithExercise:(id)exercise {
    
    CGFloat instructionTableHeightAccum = 0.0f;
    
    NSArray * instructions = nil;
    
    if([exercise isKindOfClass:[Exercise class]]) {
        instructions = [exercise getInstructionList];
    } else if([exercise isKindOfClass:[PractitionerExercise class]]) {
        instructions = ((PractitionerExercise*)exercise).instructions;
    }

    for(NSDictionary * instructionDict in instructions) {
        instructionTableHeightAccum += [ExerciseInstrutionCell heightWithExerciseInstructionString:instructionDict[@"instruction"]];
    }
    
    return instructionTableHeightAccum;
}

- (void)setSelectedExercise:(id)selectedExercise {
    
    _selectedExercise = selectedExercise;
    [self reloadData];
}

// Snap to target cell
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    
//    NSIndexPath * targetIndexPath = [self indexPathForRowAtPoint:*targetContentOffset];
//    
//    NSInteger lastRowNumber = [self numberOfRowsInSection:targetIndexPath.section] - 1;
//    NSIndexPath * lastIndexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:targetIndexPath.section];
//    NSIndexPath * secondLastIndexPath = [NSIndexPath indexPathForRow:lastRowNumber-1 inSection:targetIndexPath.section];
//    
//    if([lastIndexPath isEqual:targetIndexPath] || [lastIndexPath isEqual:secondLastIndexPath]) {
//        return;
//    }
//    
//    if(targetIndexPath.row < ([self numberOfRowsInSection:targetIndexPath.section] - 1)) {
//        
//        NSIndexPath * nextToTargetIndexPath = [NSIndexPath indexPathForRow:(targetIndexPath.row + 1) inSection:targetIndexPath.section];
//        CGRect nextTargetRectOfCellInTableView = [self rectForRowAtIndexPath:nextToTargetIndexPath];
//        CGRect rectOfCellInTableView = [self rectForRowAtIndexPath:targetIndexPath];
//        
//        CGFloat targetContentOffsetY = (CGFloat)(targetContentOffset->y);
//        
//        CGFloat nextTargetDiff = abs(targetContentOffsetY - nextTargetRectOfCellInTableView.origin.y);
//        CGFloat targetDiff = abs(targetContentOffsetY - rectOfCellInTableView.origin.y);
//        
//        if(nextTargetDiff < (3 * targetDiff)) {
//            targetIndexPath = nextToTargetIndexPath;
//        }
//    }
//    CGRect rectOfCellInTableView = [self rectForRowAtIndexPath:targetIndexPath];
//
//    if(self.mode == ExerciseInstructionTableViewModeCompleting) {
////        self.currentlySelectedIndexPath = targetIndexPath;
//        [self updateSelectedIndexPath:targetIndexPath shouldScrollToNewIndexPath:NO shouldNotifyDelegate:YES];
//    }
//    
//    *targetContentOffset = CGPointMake(targetContentOffset->x, rectOfCellInTableView.origin.y);
//}

- (void)updateSelectedIndexPath:(NSIndexPath*)indexPath shouldScrollToNewIndexPath:(BOOL)shouldScrollToNextIndexPath shouldNotifyDelegate:(BOOL)shouldNotify {
    
    self.currentlySelectedIndexPath = indexPath;
    
    if([self numberOfRowsInSection:self.currentlySelectedIndexPath.section] > 0) {
        [self reloadRowsAtIndexPaths:[self indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if(shouldScrollToNextIndexPath) {
            [self selectRowAtIndexPath:self.currentlySelectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        
        if(shouldNotify) {
            if([self.rowChangeDelegate respondsToSelector:@selector(exerciseInstructionTableView:selectedRowDidChangeToNewIndexPath:)]) {
                [self.rowChangeDelegate performSelector:@selector(exerciseInstructionTableView:selectedRowDidChangeToNewIndexPath:) withObject:self withObject:indexPath];
            }
        }
    }
}

@end
