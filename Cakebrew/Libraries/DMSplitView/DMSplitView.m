//
//  DMSplitView.h
//  New NSSplitView class with multiple subviews resize behaviors and animated transitions
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 12/21/12.
//  Copyright (c) 2012 http://www.danielemargutti.com. All rights reserved.
//	Licensed under MIT License
//

#import "DMSplitView.h"
#import <Quartz/Quartz.h>

#define DMSubviewAnimationDuration  0.2

#pragma mark - Internal Constraint Implementation

/** DMSubviewConstraint allows you to set custom constraint for a DMSplitView subview object. You can specify if subview can be collapsed and minimum & maximum allowed size. Default DMSplitView implementation does not set any constraint */

@interface DMSubviewConstraint : NSObject { }

/** YES if subview can be collapsed */
@property (assign)              BOOL        canCollapse;
/** minimum allowed size of the subview */
@property (assign)              CGFloat     minSize;
/** maximum allowed size of the subview */
@property (assign)              CGFloat     maxSize;
/** YES if at least one dimension constraint has been set */
@property (nonatomic,readonly)  BOOL        hasSizeContraints;

@end

@implementation DMSubviewConstraint

@synthesize canCollapse,minSize,maxSize;

- (id)init {
    self = [super init];
    if (self) {
        self.minSize = 0;
        self.maxSize = 0;
        self.canCollapse = NO;
    }
    return self;
}

- (BOOL) hasSizeContraints { return ((minSize > 0) || (maxSize > 0)); }

@end

#pragma mark - DMSplitView Implementation

@interface DMSplitView() {
	NSMutableDictionary*    priorityIndexes;
    NSMutableArray*         subviewContraints;
    NSMutableDictionary*    viewsToCollapseByDivider;
    CGFloat*                lastValuesBeforeCollapse;
    CGFloat*                subviewsStates;

    // override divider thickneess
    CGFloat                 oDividerThickness;
    BOOL                    dividerThicknessOverriden;
    
    CGFloat                 collapsedSubviewDimension;
    BOOL                    isAnimating; // an animation is in progress
	
	// delta adjustment needed because the original thickness of a NSSplitView created with the xib is 1
	// and the subviews are sized consequently so the thickness is changed programmatically,
	// before resizing the subviews proportionally I have to consider this delta adjustment.
	// now this adjustment is calculated in the dividerThickness setter, but it works just
	// when the original thickness used to create the initial subviews frame is equal to 1
	// (like in the xib)
	// another way to calculate this delta (stronger but more expensive) may be to caulculate
	// every time in "applyProportionalResizeFromOldSize:" the total size of the subviews
	// obtaining the delta adjustment with totalSize-oldsize
	CGFloat					deltaAdjustmentForDividerThickness;
}
@end

@implementation DMSplitView

@synthesize eventsDelegate;
@synthesize shouldDrawDivider,shouldDrawDividerHandle,dividerThickness,dividerColor,dividerRectEdge;

- (id)init {
    self = [self initWithFrame:NSZeroRect];
    if (self) { }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeSplitView];
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self initializeSplitView];
    }
    return self;
}


- (void) initializeSplitView {
    self.delegate = self;
    self.subviewsResizeMode = DMSplitViewResizeModeProportional;
    
    dividerThicknessOverriden = NO;
    oDividerThickness = 1.0f;
    deltaAdjustmentForDividerThickness = 0;
	
    priorityIndexes = [[NSMutableDictionary alloc] init];
    viewsToCollapseByDivider = [[NSMutableDictionary alloc] init];
    subviewContraints = [[NSMutableArray alloc] init];
    lastValuesBeforeCollapse = calloc(sizeof(CGFloat)*self.subviews.count, 1);
    subviewsStates = calloc(sizeof(CGFloat)*self.subviews.count, 1);

    for (NSUInteger k = 0; k < self.subviews.count; k++)
        [subviewContraints addObject:[[DMSubviewConstraint alloc] init]];
}

- (void) reset {
    [self initializeSplitView];
}

- (void)dealloc {
    free(lastValuesBeforeCollapse);
}

#pragma mark - Appearance Properties

- (void) setShouldDrawDivider:(BOOL)newShouldDrawDivider {
    shouldDrawDivider = newShouldDrawDivider;
    [self setNeedsDisplay:YES];
}

- (void) setDividerColor:(NSColor *)newDividerColor {
    if (newDividerColor != dividerColor) {
        dividerColor = newDividerColor;
        [self setNeedsDisplay:YES];
    }
}

- (CGFloat) dividerThickness {
    if (dividerThicknessOverriden)
        return oDividerThickness;
    return [super dividerThickness];
}

- (void) setDividerThickness:(CGFloat)newDividerThickness {
	deltaAdjustmentForDividerThickness += (newDividerThickness-oDividerThickness)*(self.subviews.count-1);
    oDividerThickness = newDividerThickness;
    dividerThicknessOverriden = YES;
    [self setNeedsDisplay:YES];
}

- (void) setDividerRectEdge:(NSRectEdge)newDividerRectEdge {
    dividerRectEdge = newDividerRectEdge;
    [self setNeedsDisplay:YES];
}

- (void) setShouldDrawDividerHandle:(BOOL)newShouldDrawDividerHandle {
    shouldDrawDividerHandle = newShouldDrawDividerHandle;
    [self setNeedsDisplay:YES];
}

- (BOOL)isSubviewCollapsed:(NSView *)subview {
    // Overloaded version of [NSSplitView isSubviewCollapsed:] which take into account the subview dimension: it is a far more tolerant version of the method.
    if (self.isVertical)
        return ([super isSubviewCollapsed:subview] || ([subview frame].size.width == 0));
    else
        return ([super isSubviewCollapsed:subview] || ([subview frame].size.height == 0));
}


#pragma mark - Appearance Drawing Routines

-(void)drawRect:(NSRect)dirtyRect {
	if (dividerColor.alphaComponent > 0)
		[super drawRect:dirtyRect];
}

- (void)drawDividerInRect:(NSRect)aRect {
    if (self.shouldDrawDivider) {
        if (self.dividerStyle == NSSplitViewDividerStyleThin) {
            [self.dividerColor set];
            NSRectFill(aRect);
        } else {
            if (self.shouldDrawDividerHandle) {
                NSColor * tempDividerColor = self.dividerColor;
				self.dividerColor = [NSColor clearColor];
				[super drawDividerInRect:aRect];
				self.dividerColor = tempDividerColor;
            }
            
            [self.dividerColor set];
            switch (self.dividerRectEdge) {
                case NSMaxYEdge:
                    aRect.origin.y += aRect.size.height - 1.0;
                    aRect.size.height = 1.0;
                    break;
                case NSMinYEdge:
                    aRect.size.height = 1.0;
                    break;
                case NSMaxXEdge:
                    aRect.origin.x += aRect.size.width - 1.0;
                    aRect.size.width = 1.0;
                    break;
                case NSMinXEdge:
                    aRect.size.width = 1.0;
                    break;
			}
			
			NSRectFill(aRect);
        }
    } else { // OS's standard handler
        [super drawDividerInRect:aRect];
    }
}

#pragma mark - Behavior Properties Set

- (void) setPriority:(NSInteger)priorityIndex ofSubviewAtIndex:(NSInteger)subviewIndex {
    [priorityIndexes setObject:@(subviewIndex) forKey:@(priorityIndex)];
}

- (void) setMaxSize:(CGFloat) maxSize ofSubviewAtIndex:(NSUInteger) subviewIndex {
    ((DMSubviewConstraint*)subviewContraints[subviewIndex]).maxSize = maxSize;
}

- (void) setMinSize:(CGFloat) minSize ofSubviewAtIndex:(NSUInteger) subviewIndex {
    ((DMSubviewConstraint*)subviewContraints[subviewIndex]).minSize = minSize;
}

- (CGFloat) minSizeForSubviewAtIndex:(NSUInteger) subviewIndex {
    return ((DMSubviewConstraint*)subviewContraints[subviewIndex]).minSize;
}

- (CGFloat) maxSizeForSubviewAtIndex:(NSUInteger) subviewIndex {
    return ((DMSubviewConstraint*)subviewContraints[subviewIndex]).maxSize;
}

- (void) setCanCollapse:(BOOL) canCollapse subviewAtIndex:(NSUInteger) subviewIndex {
    ((DMSubviewConstraint*)subviewContraints[subviewIndex]).canCollapse = canCollapse;
}

- (BOOL) canCollapseSubviewAtIndex:(NSUInteger) subviewIndex {
    return ((DMSubviewConstraint*)subviewContraints[subviewIndex]).canCollapse;
}

- (void)setCollapseSubviewAtIndex:(NSUInteger)viewIndex forDoubleClickOnDividerAtIndex:(NSUInteger)dividerIndex {
    [viewsToCollapseByDivider setObject:@(viewIndex) forKey:@(dividerIndex)];
}

- (NSUInteger) subviewIndexToCollapseForDoubleClickOnDividerAtIndex:(NSUInteger) dividerIndex {
    if (viewsToCollapseByDivider[@(dividerIndex)] != nil)
        return ((NSNumber*)viewsToCollapseByDivider[@(dividerIndex)]).integerValue;
    return NSNotFound;
}

#pragma mark - Splitview delegate methods

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)viewIndex {
    DMSubviewConstraint *subviewConstraint = ((DMSubviewConstraint*)subviewContraints[viewIndex]);
    if (!subviewConstraint.hasSizeContraints) // no constraint set for this
        return proposedMin;
    
    NSView *targetSubview = ((NSView*)splitView.subviews[viewIndex]);
    CGFloat subviewOrigin = (splitView.isVertical ? targetSubview.frame.origin.x : targetSubview.frame.origin.y);
    CGFloat finalCoordinate = subviewOrigin + subviewConstraint.minSize;
    return finalCoordinate;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset {
    DMSubviewConstraint *constraintShrinkingSubview = ((DMSubviewConstraint*)subviewContraints[offset+1]);
    
    NSView *growingSubview = self.subviews[offset];
	NSView *shrinkingSubview = self.subviews[offset + 1];
	NSRect growingSubviewFrame = growingSubview.frame;
	NSRect shrinkingSubviewFrame = shrinkingSubview.frame;
	CGFloat shrinkingSize;
	CGFloat currentCoordinate;
	if (self.isVertical) {
		currentCoordinate = growingSubviewFrame.origin.x + growingSubviewFrame.size.width;
		shrinkingSize = shrinkingSubviewFrame.size.width;
	} else {
		currentCoordinate = growingSubviewFrame.origin.y + growingSubviewFrame.size.height;
		shrinkingSize = shrinkingSubviewFrame.size.height;
	}
	
	CGFloat minimumSize =constraintShrinkingSubview.minSize;
	return currentCoordinate + (shrinkingSize - minimumSize);
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    if (isAnimating) { // if we are inside an animated session we want to redraw correctly NSSplitView elements (as like the moving divider)
        [self setNeedsDisplay:YES];
        return; // relayout constraint does not happend while animating... we don't want to interfere with animation.
    }
    
    switch (self.subviewsResizeMode) {
        case DMSplitViewResizeModeUniform: // UNIFORM RESIZE
            [self applyUniformResizeFromOldSize:oldSize];
            break;
        case DMSplitViewResizeModePriorityBased: // PRIORITY BASED RESIZE
            [self applyPriorityResizeFromOldSize:oldSize];
            break;
        case DMSplitViewResizeModeProportional: // PROPORTIONAL RESIZE
        default:
            [self applyProportionalResizeFromOldSize:oldSize];
            break;
    }
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    BOOL canCollapse = [self constraintForSubview:subview].canCollapse;
    return canCollapse;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    NSUInteger indexOfSubviewToCollapse = [self subviewIndexToCollapseForDoubleClickOnDividerAtIndex:dividerIndex];
    NSUInteger indexOfSubview = [self.subviews indexOfObject:subview];
    
    return ((indexOfSubviewToCollapse == NSNotFound) || (indexOfSubview == indexOfSubviewToCollapse));
}

#pragma mark - Utilities Methods

- (DMSubviewConstraint *) constraintForSubview:(NSView *) subview {
    NSUInteger viewIndex = [self.subviews indexOfObject:subview];
	if (viewIndex == NSNotFound) return nil;
	return subviewContraints[viewIndex];
}

#pragma mark - Resizes Operations

- (void) applyUniformResizeFromOldSize:(CGSize) splitViewOldSize {
    NSSize splitViewNewSize = self.bounds.size;
    __block CGFloat deltaValue = (self.isVertical ?  (splitViewNewSize.width-splitViewOldSize.width) : (splitViewNewSize.height-splitViewOldSize.height));
    
    __block NSUInteger numberOfResizableSubviews = 0;
    BOOL *resizableSubviews = calloc(sizeof(BOOL)*self.subviews.count, 1);
    [self calculateResizableSubviews:resizableSubviews
                         totalNumber:&numberOfResizableSubviews
                          totalWidth:nil
                           withDelta:deltaValue];
    
    CGFloat *subviewsSizes = calloc(sizeof(CGFloat)*self.subviews.count, 1);
    [self calculateSubviewsSizesArrayInto:subviewsSizes];
    
    /** We loop because it's possible that the first time through, we hit min/max size,
        which then causes not all of the delta to be used. Since this is uniform, if
        we loop, the remaining is uniformly split over the views which can still resize.
     */
    while (fabs(deltaValue) > 0.5f) {
        // The amount we'll resize each view by to start with
        CGFloat deltaPerSubview = (deltaValue / (CGFloat)numberOfResizableSubviews);
        if (deltaPerSubview < 0) deltaPerSubview = floor(deltaPerSubview);
        else if (deltaPerSubview > 0) deltaPerSubview = ceil(deltaPerSubview);
        
        // guard looping from unexpected calculation
        if (isinf(deltaPerSubview))
            break;
            
        // Resize each of the subviews by a uniform amount (may be off by a teen bit in the last one due to rounding)
        [subviewContraints enumerateObjectsUsingBlock:^(DMSubviewConstraint *constraint, NSUInteger subviewIndex, BOOL *stop) {
            BOOL isSubviewResizable = resizableSubviews[subviewIndex];
            if (isSubviewResizable) {
                CGFloat oldSubviewSize = subviewsSizes[subviewIndex];
                CGFloat newSubviewSize = oldSubviewSize;
                
                // Resize subview according to max/min constraint
                newSubviewSize += deltaPerSubview;
                if ((constraint.minSize > 0) && (newSubviewSize < constraint.minSize)) {
                    numberOfResizableSubviews--;
                    resizableSubviews[subviewIndex] = NO;
                    newSubviewSize = constraint.minSize;
                }
                
                if ((constraint.maxSize > 0) && (newSubviewSize > constraint.maxSize)) {
                    numberOfResizableSubviews --;
                    resizableSubviews[subviewIndex] = NO;
                    newSubviewSize = constraint.maxSize;
                }
                
                subviewsSizes[subviewIndex] = newSubviewSize;
                deltaValue -= (newSubviewSize - oldSubviewSize);
                if (fabs(deltaValue) <= 0.5f)
                    *stop = YES;
            }
        }];
    }
    
    [self setSubviewsSizes:subviewsSizes];
    free(subviewsSizes); free(resizableSubviews);
}

- (void) applyProportionalResizeFromOldSize:(CGSize) splitViewOldSize {
    NSSize splitViewNewSize = self.bounds.size;
    __block CGFloat deltaValue = (self.isVertical ?  (splitViewNewSize.width-splitViewOldSize.width) : (splitViewNewSize.height-splitViewOldSize.height));
    
	if (deltaAdjustmentForDividerThickness != 0) {
		deltaValue -= deltaAdjustmentForDividerThickness;
		deltaAdjustmentForDividerThickness = 0;
	}
	
    __block NSUInteger numberOfResizableSubviews = 0;
    CGFloat oldResizableSubviewsWidth = 0;
    
    BOOL *resizableSubviews = calloc(sizeof(BOOL)*self.subviews.count, 1);
    [self calculateResizableSubviews:resizableSubviews
                         totalNumber:&numberOfResizableSubviews
                          totalWidth:&oldResizableSubviewsWidth
                           withDelta:deltaValue];
    
    CGFloat *subviewsSizes = calloc(sizeof(CGFloat)*self.subviews.count, 1);
    [self calculateSubviewsSizesArrayInto:subviewsSizes];
    
    // Get proportions to use for resizing
    CGFloat *subviewsProportions = calloc(sizeof(CGFloat)*self.subviews.count, 1);
    [subviewContraints enumerateObjectsUsingBlock:^(DMSubviewConstraint* constraint, NSUInteger subviewIndex, BOOL *stop) {
        BOOL isResizable = resizableSubviews[subviewIndex];
        if (isResizable) {
            NSView *subview = self.subviews[subviewIndex];
            CGFloat targetSize = (self.isVertical ? NSWidth(subview.frame) : NSHeight(subview.frame));
            subviewsProportions[subviewIndex] = (targetSize / oldResizableSubviewsWidth);
        }
    }];
    
    /* Proportionally increment/decrement subview size. Need to loop because if we hit min/max of a subview, there'll be left over delta. */
    while (fabs(deltaValue)) {
        __block CGFloat remainingDeltaValue = deltaValue;
        
        [subviewContraints enumerateObjectsUsingBlock:^(DMSubviewConstraint* constraint, NSUInteger subviewIndex, BOOL *stop) {
            CGFloat oldSize = subviewsSizes[subviewIndex];
            CGFloat newSize = oldSize;
            
            // determine the appropriate delta for current subview
            CGFloat subviewDelta = roundf(subviewsProportions[subviewIndex]*deltaValue);
            // resize it according to max/min
            newSize +=  subviewDelta;
            if (constraint.minSize > 0.0f) newSize = MAX(constraint.minSize,newSize);
            if (constraint.maxSize > 0.0f) newSize = MIN(constraint.maxSize,newSize);
						
            subviewsSizes[subviewIndex] = newSize;
            
            // reduce delta
            remainingDeltaValue -= (newSize-oldSize);
            if (fabs(remainingDeltaValue) <= 0.5f)
                *stop = YES;
        }];
		
		// avoid loop (for example if the remaining value is 1 and no one subview has a proportion greather that 0.5, each subviewDelta will be 0 and we have a loop)
		if (deltaValue != 0.0f && deltaValue == remainingDeltaValue) {
			// find the subview with the bigger proportion that can be resized with the remaining delta value
			__block NSUInteger subviewIndexToResize = 0;
			__block CGFloat maxProportion = 0;
			[subviewContraints enumerateObjectsUsingBlock:^(DMSubviewConstraint* constraint, NSUInteger subviewIndex, BOOL *stop) {
				if (subviewsProportions[subviewIndex] > maxProportion) {
					CGFloat oldSize = subviewsSizes[subviewIndex];
					CGFloat newSize = oldSize;
					newSize += remainingDeltaValue;
					// check if it has enough space
					if ((constraint.minSize == 0.0f || newSize >= constraint.minSize) &&
						(constraint.maxSize == 0.0f || newSize < constraint.maxSize)) {
						maxProportion = subviewsProportions[subviewIndex];
						subviewIndexToResize = subviewIndex;
					}
				}
			}];
			// resize this subview
			subviewsSizes[subviewIndexToResize] += remainingDeltaValue;
			remainingDeltaValue -= remainingDeltaValue;
		}
			
        deltaValue = remainingDeltaValue;
    }
    
    [self setSubviewsSizes:subviewsSizes];
    free(subviewsSizes); free(subviewsProportions); free(resizableSubviews);
}

- (void) applyPriorityResizeFromOldSize:(CGSize) splitViewOldSize {
    __block CGFloat deltaValue = (self.isVertical ?  (self.bounds.size.width-splitViewOldSize.width) :
                                                     (self.bounds.size.height-splitViewOldSize.height));
	
	if (deltaAdjustmentForDividerThickness != 0) {
		deltaValue -= deltaAdjustmentForDividerThickness;
		deltaAdjustmentForDividerThickness = 0;
	}
	
    for (NSNumber *priorityIndex in [[priorityIndexes allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        NSNumber *subviewIndex = [priorityIndexes objectForKey:priorityIndex];
        if (subviewIndex.integerValue >= self.subviews.count)
			continue;
    
        NSView *subview = (NSView*)self.subviews[subviewIndex.integerValue];
        if (![self isSubviewCollapsed:subview]) {
            NSSize frameSize = subview.frame.size;
            DMSubviewConstraint *constraint = [self constraintForSubview:subview];
            CGFloat minValue = constraint.minSize;
        
            if (self.isVertical) {
                frameSize.height = self.bounds.size.height;
                if (deltaValue > 0.0f || frameSize.width + deltaValue >= minValue) {
                    frameSize.width += deltaValue;
                    deltaValue = 0.0f;
                } else if (deltaValue < 0.0f) {
                    deltaValue += frameSize.width-minValue;
                    frameSize.width = minValue;
                }
            } else {
                frameSize.width = self.bounds.size.width;
                if (deltaValue > 0.0f || frameSize.height + deltaValue >= minValue) {
                    frameSize.height += deltaValue;
                    deltaValue = 0.0f;
                } else if (deltaValue < 0.0f) {
                    deltaValue += frameSize.height - minValue;
                    frameSize.height = minValue;
                }
            }
            [subview setFrameSize:frameSize];
        }
    }
    [self layoutSubviews];
}

- (void) layoutSubviews {
	CGFloat offset = 0;
    NSUInteger k = 0;
	for (NSView *subview in self.subviews) {
		NSRect viewFrame = subview.frame;
		NSPoint viewOrigin = viewFrame.origin;
		
        if (self.isVertical)    viewOrigin.x = offset;
        else                    viewOrigin.y = offset;
		[subview setFrameOrigin:viewOrigin];
		offset += (self.isVertical ? viewFrame.size.width :viewFrame.size.height) + self.dividerThickness;
        k++;
        
        // When a subview is collapsed NSSplitView set it's hidden property as YES
        // So we need to set it as visible if we set as uncollapsed programmatically, otherwise we will see
        // a blank space instead of our superview
        if (self.isVertical)    [subview setHidden:!(subview.frame.size.width > 0)];
        else    [subview setHidden:!(subview.frame.size.height > 0)];
	}
}

#pragma mark - Additional Methods

- (void) setSubviewsSizes:(CGFloat *) subviewsSizes {
    [self.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger subviewIndex, BOOL *stop) {
        CGSize targetSize;
        if (self.isVertical)
            targetSize = NSMakeSize(subviewsSizes[subviewIndex], NSHeight(self.bounds));
        else
            targetSize = NSMakeSize(NSWidth(self.bounds), subviewsSizes[subviewIndex]);
        [subview setFrameSize:targetSize];
	}];
	
    [self layoutSubviews];
}

- (void) calculateSubviewsSizesArrayInto:(CGFloat *) subviewsSizesArray {
    [self.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger viewIndex, BOOL *stop) {
        CGFloat size = (self.isVertical ? NSWidth(subview.frame) : NSHeight(subview.frame));
        subviewsSizesArray[viewIndex] = size;
    }];
}

- (void) calculateResizableSubviews:(BOOL *) subviewCanBeResized
                        totalNumber:(NSUInteger *) numberOfResizableSubviews
                         totalWidth:(CGFloat *) resizableArea
                          withDelta:(CGFloat) deltaValue {
    [subviewContraints enumerateObjectsUsingBlock:^(DMSubviewConstraint* constraint, NSUInteger viewIndex, BOOL *stop) {
        NSView* subview = self.subviews[viewIndex];
        CGFloat size = (self.isVertical ? subview.frame.size.width : subview.frame.size.height);
        BOOL canBeResized = YES;
        
        if (deltaValue < 0.0f) {
            if (constraint.minSize > 0.0f)
                canBeResized = !(fabs(size-constraint.minSize) < 0.5f);
        } else if (deltaValue > 0.0f) {
            if (constraint.maxSize > 0.0f)
                canBeResized = !(fabs(size-constraint.maxSize) < 0.5f);
        }
        
        if (subviewCanBeResized) subviewCanBeResized[viewIndex] = canBeResized;
        if (canBeResized) {
            if (numberOfResizableSubviews) *numberOfResizableSubviews += 1;
            if (resizableArea) *resizableArea += size;
        }
    }];
}

#pragma mark - Collapse


- (CGFloat)positionOfDividerAtIndex:(NSInteger)dividerIndex {
    // It looks like NSSplitView relies on its subviews being ordered left->right or top->bottom so we can too.
    // It also raises w/ array bounds exception if you use its API with dividerIndex > count of subviews.
    while (dividerIndex >= 0 && [self isSubviewCollapsed:[[self subviews] objectAtIndex:dividerIndex]])
        dividerIndex--;
    if (dividerIndex < 0)
        return 0.0f;
    
    NSRect priorViewFrame = [[[self subviews] objectAtIndex:dividerIndex] frame];
    return [self isVertical] ? NSMaxX(priorViewFrame) : NSMaxY(priorViewFrame);
}

- (void) getNewSubviewsRects:(NSRect *) newRect withIndexes:(NSArray *) indexes andPositions:(NSArray *) newPositions {
    CGFloat dividerTkn = self.dividerThickness;
    for (NSUInteger i = 0; i < self.subviews.count; i++)
        newRect[i] = [[self.subviews objectAtIndex:i] frame];
    
    for (NSNumber *indexObject in indexes) {
        NSInteger index = [indexObject integerValue];
        CGFloat  newPosition = [[newPositions objectAtIndex:[indexes indexOfObject:indexObject]] doubleValue];
        
        // save divider state where necessary
        [self saveCurrentDivididerState];
        
        if (self.isVertical) {
            CGFloat oldMaxXOfRightHandView = NSMaxX(newRect[index + 1]);
            newRect[index].size.width = newPosition - NSMinX(newRect[index]);
            CGFloat dividerAdjustment = (newPosition < NSWidth(self.bounds)) ? dividerTkn : 0.0;
            newRect[index + 1].origin.x = newPosition + dividerAdjustment;
            newRect[index + 1].size.width = oldMaxXOfRightHandView - newPosition - dividerAdjustment;
        } else {
            CGFloat oldMaxYOfBottomView = NSMaxY(newRect[index + 1]);
            newRect[index].size.height = newPosition - NSMinY(newRect[index]);
            CGFloat dividerAdjustment = (newPosition < NSHeight(self.bounds)) ? dividerTkn : 0.0;
            newRect[index + 1].origin.y = newPosition + dividerAdjustment;
            newRect[index + 1].size.height = oldMaxYOfBottomView - newPosition - dividerAdjustment;
        }
    }
}

- (BOOL) setPositions:(NSArray *)newPositions ofDividersAtIndexes:(NSArray *)indexes animated:(BOOL) animated completitionBlock:(void (^)(BOOL isEnded)) completition {
    __block NSUInteger numberOfSubviews = self.subviews.count;
    
    // indexes and newPositions arrays must have the same object count
    if (indexes.count == newPositions.count == NO) return NO;
    // trying to move too many dividers
    if (indexes.count < numberOfSubviews == NO) return NO;
    
	if (animated) {
		if ([self.eventsDelegate respondsToSelector:@selector(splitView:splitViewIsAnimating:)])
			[((id <DMSplitViewDelegate>)self.delegate) splitView:self splitViewIsAnimating:YES];
        
        isAnimating = YES;        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = DMSubviewAnimationDuration;
            NSRect newRect[numberOfSubviews];
            [self getNewSubviewsRects:newRect withIndexes:indexes andPositions:newPositions];
            for (NSUInteger i = 0; i < numberOfSubviews; i++) {
                NSView *subview = self.subviews[i];
                // unhide collapsed subview (collapsed subview are set to hidden state).
                // we need to hide it while animating for expand, otherwise we will not see the collapsed subview expanding
                // but only the divider and a blank placeholder
                if (subview.isHidden && ((self.isVertical ? newRect[i].size.width > 0 : newRect[i].size.height > 0)))
                    [subview setHidden:NO];
                [[subview animator] setFrame:newRect[i]];
            }
        } completionHandler:^{
            isAnimating = NO;
            [self setNeedsDisplay:YES];
            
            if (completition != nil) completition(YES);
            if ([self.eventsDelegate respondsToSelector:@selector(splitView:splitViewIsAnimating:)])
                [((id <DMSplitViewDelegate>)self.delegate) splitView:self splitViewIsAnimating:NO];
        }];
	} else {
        NSRect newRect[numberOfSubviews];
        [self getNewSubviewsRects:newRect withIndexes:indexes andPositions:newPositions];
        
        for (NSUInteger i = 0; i < numberOfSubviews; i++) {
            NSView *subview = self.subviews[i];
            [subview setFrame:newRect[i]];
        }
        if (completition != nil) completition(YES);
	}
    return YES;
}

- (BOOL) setPosition:(CGFloat)position ofDividerAtIndex:(NSInteger)dividerIndex animated:(BOOL) animated completitionBlock:(void (^)(BOOL isEnded)) completition {
    NSUInteger numberOfSubviews = self.subviews.count;
    if (dividerIndex >= numberOfSubviews) return NO;
    [self setPositions:@[@(position)] ofDividersAtIndexes:@[@(dividerIndex)] animated:animated completitionBlock:completition];
	return YES;
}

- (BOOL) collapseOrExpandSubviewAtIndex:(NSUInteger) subviewIndex animated:(BOOL) animated {
    if (subviewIndex >= self.subviews.count || subviewIndex == NSNotFound) return NO;
    // only side subviews can be collapsed (at least for now)
    if (subviewIndex != 0 && subviewIndex != self.subviews.count-1) return NO;
    BOOL isCollapsed = [self isSubviewCollapsed:self.subviews[subviewIndex]];
    
    NSView *subview = self.subviews[subviewIndex];
    NSInteger dividerIndex = (subviewIndex == 0 ? subviewIndex : subviewIndex-1);
    CGFloat newValue;
    if (isCollapsed) {
        newValue = lastValuesBeforeCollapse[dividerIndex];
    } else {
        if (subviewIndex == 0)
            newValue = 0.0f;
        else {
            newValue = [self positionOfDividerAtIndex:dividerIndex];
            newValue += (self.isVertical ? NSWidth(subview.frame) : NSHeight(subview.frame));
        }
    }
    [self setPosition:newValue
     ofDividerAtIndex:dividerIndex
             animated:animated completitionBlock:nil];
    return isCollapsed;
}

- (BOOL) collapseOrExpandSubview:(NSView *)subview animated:(BOOL) animated {
    return [self collapseOrExpandSubviewAtIndex:[self.subviews indexOfObject:subview]
                                       animated:animated];
}

#pragma mark - Other Events of the delegate

- (void) saveCurrentDivididerState {
    for (NSUInteger k=0; k<self.subviews.count-1; k++) {
        CGFloat position = [self positionOfDividerAtIndex:k];
        BOOL isCollapsedLeft = (position == 0);
        BOOL isCollapsedRight = (position == (self.isVertical ? NSWidth(self.frame) : NSHeight(self.frame))- self.dividerThickness);
        if (!isCollapsedLeft && !isCollapsedRight)
            lastValuesBeforeCollapse[k] = position;
    }
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    NSUInteger dividerIndex = ((NSString*)notification.userInfo[@"NSSplitViewDividerIndex"]).integerValue;
    CGFloat newPosition = [self positionOfDividerAtIndex:dividerIndex];
    
    // used to restore from collapse state; we want to save it before animating, not while animating and finally we won't save collapsed state
    if (!isAnimating) [self saveCurrentDivididerState];

    if (!isAnimating) {
        if ([self.eventsDelegate respondsToSelector:@selector(splitView:divider:movedAt:)])
            [self.eventsDelegate splitView:self
                                   divider:dividerIndex
                                   movedAt:newPosition];
        
        BOOL isCollapsing = (subviewsStates[dividerIndex] > 0) && (newPosition == 0);
        BOOL isExpanding = (subviewsStates[dividerIndex] == 0) && (newPosition > 0);
        
        if ([self.eventsDelegate respondsToSelector:@selector(splitView:subview:stateChanged:)]) {
            if (isCollapsing)
                [self.eventsDelegate splitView:self
                                       subview:dividerIndex
                                  stateChanged:DMSplitViewStateCollapsed];
            if (isExpanding)
                [self.eventsDelegate splitView:self
                                       subview:dividerIndex
                                  stateChanged:DMSplitViewStateExpanded];
        }
    }
    
    [self updateSubviewsState];
}

- (void) updateSubviewsState {
    [self.subviews enumerateObjectsUsingBlock:^(NSView* subview, NSUInteger subviewIndex, BOOL *stop) {
        CGFloat size = ([self isSubviewCollapsed:subview] ? 0.0 : (self.isVertical ? NSWidth(subview.frame) : NSHeight(subview.frame)));
        subviewsStates[subviewIndex] = size;
    }];
}

#pragma mark - Working with subview's sizes

- (BOOL) setSize:(CGFloat) size ofSubviewAtIndex:(NSInteger) subviewIndex
    animated:(BOOL) animated completition:(void (^)(BOOL isEnded)) completition {
  
    NSView *subview = self.subviews[subviewIndex];
    CGFloat frameOldSize = (self.isVertical ? NSWidth(subview.frame) : NSHeight(subview.frame));
    CGFloat deltaValue = (size-frameOldSize); // if delta > 0 subview will grow, otherwise if delta < 0 subview will shrink
    
    if (deltaValue == 0)
        return NO; // no changes required
    
    NSArray* involvedDividers;
    NSArray* dividersPositions;
    if (subviewIndex > 0 && subviewIndex < (self.subviews.count-1) && self.subviews.count > 2) {
        // We have more than 2 subviews and our target subview index has two dividers, one at left and another at right.
        // We want to apply the same delta value at both edges (proportional)
        NSUInteger leftDividerIndex = (subviewIndex-1);
        NSUInteger rightDividerIndex = subviewIndex;
        CGFloat leftDividerPosition = [self positionOfDividerAtIndex:leftDividerIndex];
        CGFloat rightDividerPosition = [self positionOfDividerAtIndex:rightDividerIndex];
        CGFloat deltaPerDivider = (deltaValue/2.0f);
        
        leftDividerPosition -= deltaPerDivider;
        rightDividerPosition += deltaPerDivider;
        
        involvedDividers = @[@(leftDividerIndex),@(rightDividerIndex)];
        dividersPositions = @[@(leftDividerPosition),@(rightDividerPosition)];
    } else {
        // We can shrink or grow only at one side because our index is the top left or the top right
        NSInteger dividerIndex = (subviewIndex > 0 ? subviewIndex-1 : subviewIndex);
        NSInteger dividerPosition = [self positionOfDividerAtIndex:dividerIndex];
        if (subviewIndex == 0) dividerPosition += deltaValue;
        else dividerPosition -= deltaValue;
        involvedDividers = @[@(dividerIndex)];
        dividersPositions = @[@(dividerPosition)];
    }
    
    [self setPositions:dividersPositions ofDividersAtIndexes:involvedDividers animated:animated
     completitionBlock:^(BOOL isEnded) {
         completition(isEnded);
     }];
    
    return YES;
}

@end
