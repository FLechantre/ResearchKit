/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKDirectionView.h"


static const CGFloat kArrowWidth = 8;
static const CGFloat kArrowLineWidth = 4;


@interface ORKArrowView : UIView

@property (nonatomic, assign) BOOL completed;

@end


@implementation ORKArrowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize {
    return (CGSize){kArrowWidth + 2 * kArrowLineWidth, 2 * (kArrowWidth + kArrowLineWidth)};
}

- (void)setCompleted:(BOOL)completed {
    _completed = completed;
    self.alpha = (completed ? 1.0f : 0.6f);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, kArrowLineWidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    [self.tintColor setStroke];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, kArrowLineWidth, kArrowLineWidth);
    CGPathAddLineToPoint(path, NULL, kArrowLineWidth + kArrowWidth, kArrowLineWidth + kArrowWidth);
    CGPathAddLineToPoint(path, NULL, kArrowLineWidth, kArrowLineWidth + 2 * kArrowWidth);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

@end


@interface ORKDirectionView ()

@property (nonatomic, strong) ORKArrowView *leftArrow;
@property (nonatomic, strong) ORKArrowView *middleArrow;
@property (nonatomic, strong) ORKArrowView *rightArrow;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSArray *constraints;

@end


@implementation ORKDirectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        
        _leftArrow = [[ORKArrowView alloc] init];
        _leftArrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftArrow];
        
        _middleArrow = [[ORKArrowView alloc] init];
        _middleArrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_middleArrow];
        
        _rightArrow = [[ORKArrowView alloc] init];
        _rightArrow.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_rightArrow];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    self.leftArrow.completed = NO;
    self.middleArrow.completed = NO;
    self.rightArrow.completed = NO;
    
    switch (index) {
        case 3:
            self.rightArrow.completed = YES;
        case 2:
            self.middleArrow.completed = YES;
        case 1:
            self.leftArrow.completed = YES;
        default:
            break;
    }
}

- (void)didMoveToWindow {
    if (self.window) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}

- (void)startAnimating {
    [self stopAnimating];
    self.index = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(incrementIndex) userInfo:nil repeats:YES];
}

- (void)stopAnimating {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)incrementIndex {
    self.index = (self.index + 1) % 4;
}

- (void)updateConstraints {
    if ([_constraints count]) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }
    
    NSMutableArray *constraintsArray = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_leftArrow, _middleArrow, _rightArrow);
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftArrow][_middleArrow][_rightArrow]|"
                                             options:NSLayoutFormatAlignAllCenterY
                                             metrics:nil views:views]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.middleArrow
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1
                                                              constant:0]];
    
    self.constraints = constraintsArray;
    [self addConstraints:self.constraints];
    
    [NSLayoutConstraint activateConstraints:self.constraints];
    [super updateConstraints];
}

@end
