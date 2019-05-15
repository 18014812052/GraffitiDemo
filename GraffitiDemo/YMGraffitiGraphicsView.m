//
//  YMGraffitiGraphicsView.m
//  GraffitiDemo
//
//  Created by yangtt on 2019/5/13.
//  Copyright © 2019 hikvision. All rights reserved.
//

#import "YMGraffitiGraphicsView.h"

@interface YMGraffitiGraphicsView ()

@property (nonatomic ,strong) UIImage *image;
@property (nonatomic ,assign) CGPoint startPoint;
@property (nonatomic ,strong) YMGraffitiGraphicsModel *currentModel;
// 所有的path数组
@property (nonatomic ,strong, readwrite) NSMutableArray <YMGraffitiGraphicsModel *>*allDataArr;
// 撤销的path数组
@property (nonatomic, strong) NSMutableArray<YMGraffitiGraphicsModel *>*canceledDataArr;
// 记录是否有撤回
@property (nonatomic ,assign) BOOL hasWithdraw;
// 几个回调block
@property (nonatomic, copy) void (^drawToolStatus)(BOOL canWithdraw,BOOL canForward);
@property (nonatomic, copy) void (^drawingCallback)(BOOL isDrawing);
@property (nonatomic, copy) void (^drawingDidTap)(void);

@end

@implementation YMGraffitiGraphicsView

+ (UIImage *)imageWithOriginalImage:(UIImage *)originalImage graffitiList:(NSArray <YMGraffitiGraphicsModel *>*)graffitiList {
    if (!originalImage || originalImage.size.width == 0 || originalImage.size.height == 0) {
        return nil;
    }
    CGRect frame = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    [originalImage drawInRect:frame];
    for (YMGraffitiGraphicsModel *model in graffitiList) {
        UIBezierPath *path;
        CGRect gFrame = model.locationFrame;
        CGRect drawFrame = CGRectMake(gFrame.origin.x * frame.size.width, gFrame.origin.y * frame.size.height, gFrame.size.width * frame.size.width, gFrame.size.height * frame.size.height);
        if (drawFrame.size.width > 0 && drawFrame.size.height > 0) {
            if (model.drawType == YMGraffitiGraphicsViewTypeSquare) {
                path = [UIBezierPath bezierPathWithRect:drawFrame];
            } else if (model.drawType == YMGraffitiGraphicsViewTypeCircular) {
                path = [UIBezierPath bezierPathWithOvalInRect:drawFrame];
            }
        }
        if (path) {
            path.lineWidth = 2;
            [[UIColor orangeColor] setStroke];
            [path stroke];
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame drawToolStatus:(void (^)(BOOL canWithdraw,BOOL canForward))drawToolStatus drawingCallback:(void (^)(BOOL isDrawing))drawingCallback drawingDidTap:(void (^)(void))drawingDidTap {
    self = [super initWithFrame:frame];
    if (self) {
        _drawType = YMGraffitiGraphicsViewTypeSquare;
        _lineWidth = 2;
        _lineColor = [UIColor orangeColor];
        _image = image;
        _drawToolStatus = drawToolStatus;
        _drawingCallback = drawingCallback;
        _drawingDidTap = drawingDidTap;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidTap:)];
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (_image) {
        [_image drawInRect:rect];
    }
    
    _currentModel.path.lineWidth = _lineWidth;
    [_lineColor setStroke];
    [_currentModel.path stroke];
    
    for (YMGraffitiGraphicsModel *model in self.allDataArr) {
        if (model != _currentModel) {
            model.path.lineWidth = _lineWidth;
            [_lineColor setStroke];
            [model.path stroke];
        }
    }
}

- (UIImage *)imageWithGraffitiGraphics {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.bounds.size.width, self.bounds.size.height), NO, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - =============== Actions =============

// 撤回一步
- (void)withdrawAStep {
    _currentModel = nil;
    _hasWithdraw = YES;
    [self.canceledDataArr addObject:_allDataArr.lastObject];
    [_allDataArr removeLastObject];
    [self setNeedsDisplay];
    if (self.drawToolStatus) {
        self.drawToolStatus(_allDataArr.count > 0 ? : NO,_canceledDataArr.count > 0 ? : NO);
    }
}

// 前进一步
- (void)forwardAStep {
    _currentModel = nil;
    [_allDataArr addObject:_canceledDataArr.lastObject];
    [_canceledDataArr removeLastObject];
    [self setNeedsDisplay];
    if (self.drawToolStatus) {
        self.drawToolStatus(_allDataArr.count > 0 ? : NO,_canceledDataArr.count > 0 ? : NO);
    }
}

- (void)drawingViewDidTap:(UITapGestureRecognizer *)sender {
    if (self.drawingDidTap) {
        self.drawingDidTap();
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    self.startPoint = [touch locationInView:self];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.drawingCallback) {
        self.drawingCallback(YES);
    }
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    switch (_drawType) {
        case YMGraffitiGraphicsViewTypeSquare:
            _currentModel = [[YMGraffitiGraphicsModel alloc]initWithPath:[UIBezierPath bezierPathWithRect:CGRectMake(self.startPoint.x, self.startPoint.y, point.x - self.startPoint.x, point.y - self.startPoint.y)]];
            break;
            
        case YMGraffitiGraphicsViewTypeCircular:
            _currentModel = [[YMGraffitiGraphicsModel alloc]initWithPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.startPoint.x, self.startPoint.y, point.x - self.startPoint.x, point.y - self.startPoint.y)]];
            break;
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.drawingCallback) {
        self.drawingCallback(NO);
    }
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _currentModel.locationFrame = CGRectMake((self.startPoint.x * 1.0)/self.bounds.size.width, (self.startPoint.y * 1.0)/self.bounds.size.height, (fabs(point.x - self.startPoint.x) * 1.0)/self.bounds.size.width, (fabs(point.y - self.startPoint.y) * 1.0)/self.bounds.size.height);
    if (_currentModel.locationFrame.size.width > 0.0 && _currentModel.locationFrame.size.height > 0.0) {
        [self.allDataArr addObject:_currentModel];
    }
    [self setNeedsDisplay];
    
    if (_hasWithdraw) {
        [_canceledDataArr removeAllObjects];
    }
    _hasWithdraw = NO;
    if (self.drawToolStatus) {
        self.drawToolStatus(_allDataArr.count > 0 ? : NO,_canceledDataArr.count > 0 ? : NO);
    }
}

- (NSMutableArray<YMGraffitiGraphicsModel *> *)allDataArr {
    if (!_allDataArr) {
        _allDataArr = [NSMutableArray array];
    }
    return _allDataArr;
}

- (NSMutableArray<YMGraffitiGraphicsModel *> *)canceledDataArr {
    if (!_canceledDataArr) {
        _canceledDataArr = [NSMutableArray array];
    }
    return _canceledDataArr;
}

@end

/************************/

@implementation YMGraffitiGraphicsModel

- (instancetype)initWithPath:(UIBezierPath *)path {
    self = [super init];
    if (self) {
        _path = path;
    }
    return self;
}

- (instancetype)initWithDrawType:(YMGraffitiGraphicsViewType)drawType locationFrame:(CGRect)locationFrame {
    self = [super init];
    if (self) {
        _drawType = drawType;
        _locationFrame = locationFrame;
        _lineWidth = 2;
        _lineColor = [UIColor blackColor];
    }
    return self;
}

- (instancetype)initWithDrawType:(YMGraffitiGraphicsViewType)drawType locationFrame:(CGRect)locationFrame lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor {
    self = [super init];
    if (self) {
        _drawType = drawType;
        _locationFrame = locationFrame;
        _lineWidth = lineWidth;
        _lineColor = lineColor;
    }
    return self;
}

@end
