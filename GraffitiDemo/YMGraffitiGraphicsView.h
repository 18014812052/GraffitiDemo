//
//  YMGraffitiGraphicsView.h
//  GraffitiDemo
//
//  Created by yangtt on 2019/5/13.
//  Copyright © 2019 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,YMGraffitiGraphicsViewType){
    YMGraffitiGraphicsViewTypeSquare = 0, // 矩形
    YMGraffitiGraphicsViewTypeCircular = 1, // 圆
};

NS_ASSUME_NONNULL_BEGIN

/**
 绘画涂鸦view 目前只支持矩形和圆
 */
@class YMGraffitiGraphicsModel;
@interface YMGraffitiGraphicsView : UIView

/// 所有的path数组
@property (nonatomic ,strong, readonly) NSMutableArray <YMGraffitiGraphicsModel *>*allDataArr;
/// 绘画类型 默认矩形
@property (nonatomic ,assign) YMGraffitiGraphicsViewType drawType;

/// 线宽 默认2
@property (nonatomic ,assign) CGFloat lineWidth;

/// 颜色 默认橘色
@property (nonatomic ,strong) UIColor *lineColor;

// 由原始图片和涂鸦model，获取涂鸦后的图片
+ (UIImage *)imageWithOriginalImage:(UIImage *)originalImage graffitiList:(NSArray <YMGraffitiGraphicsModel *>*)graffitiList;

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame drawToolStatus:(void (^)(BOOL canWithdraw,BOOL canForward))drawToolStatus drawingCallback:(void (^)(BOOL isDrawing))drawingCallback drawingDidTap:(void (^)(void))drawingDidTap;
// 撤回一步
- (void)withdrawAStep;
// 前进一步
- (void)forwardAStep;
// 获取涂鸦后的图片
- (UIImage *)imageWithGraffitiGraphics;

@end

/***************************/

/**
 涂鸦model
 */

@interface YMGraffitiGraphicsModel : NSObject

@property (nonatomic ,assign) YMGraffitiGraphicsViewType drawType;
@property (nonatomic ,assign) CGFloat lineWidth;
@property (nonatomic ,strong) UIColor *lineColor;
@property (nonatomic ,strong) UIBezierPath *path;
/// 位置 (x：左上顶点x/父视图width  y：左上顶点y/父视图height  width：width/父视图width  height：height/父视图height)
@property (nonatomic ,assign) CGRect locationFrame;

- (instancetype)initWithPath:(UIBezierPath *)path;
- (instancetype)initWithDrawType:(YMGraffitiGraphicsViewType)drawType locationFrame:(CGRect)locationFrame;
- (instancetype)initWithDrawType:(YMGraffitiGraphicsViewType)drawType locationFrame:(CGRect)locationFrame lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor;

@end

NS_ASSUME_NONNULL_END
