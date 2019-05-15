//
//  ViewController.m
//  GraffitiDemo
//
//  Created by yangtt on 2019/4/26.
//  Copyright © 2019 hikvision. All rights reserved.
//

#import "ViewController.h"
#import "YMGraffitiGraphicsView.h"

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic ,strong)UIView *bgView;
@property (nonatomic ,strong) YMGraffitiGraphicsView *gView;

@property (nonatomic ,strong) UIButton *roundButton;
@property (nonatomic ,strong) UIButton *squareButton;
@property (nonatomic ,strong) UIButton *withdrawButton;
@property (nonatomic ,strong) UIButton *forwardButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.center = self.view.center;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:scrollView];
    UIImage *image = [UIImage imageNamed:@"background_image"];
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*image.size.height/image.size.width)];
    _bgView.center = scrollView.center;
    [scrollView addSubview:_bgView];
    scrollView.contentSize = _bgView.bounds.size;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 2.0;

    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.height, 50)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];

    CGFloat itemW = self.view.bounds.size.width/5;
    _roundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_roundButton setTitle:@"绘圆" forState:UIControlStateNormal];
    [_roundButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _roundButton.frame = CGRectMake(0, 0, itemW, 50);
    [bottomView addSubview:_roundButton];
    [_roundButton addTarget:self action:@selector(drawCircle:) forControlEvents:UIControlEventTouchUpInside];

    _squareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_squareButton setTitle:@"绘方形" forState:UIControlStateNormal];
    [_squareButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _squareButton.frame = CGRectMake(itemW * 1, 0, itemW, 50);
    [bottomView addSubview:_squareButton];
    [_squareButton addTarget:self action:@selector(drawSquare:) forControlEvents:UIControlEventTouchUpInside];
    _squareButton.selected = YES;
    
    _withdrawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_withdrawButton setTitle:@"撤销" forState:UIControlStateNormal];
    [_withdrawButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _withdrawButton.frame = CGRectMake(itemW * 2, 0, itemW, 50);
    [bottomView addSubview:_withdrawButton];
    [_withdrawButton addTarget:self action:@selector(withdrawAStep) forControlEvents:UIControlEventTouchUpInside];
    _withdrawButton.enabled = NO;
    
    _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forwardButton setTitle:@"前进" forState:UIControlStateNormal];
    [_forwardButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _forwardButton.frame = CGRectMake(itemW * 3, 0, itemW, 50);
    [bottomView addSubview:_forwardButton];
    [_forwardButton addTarget:self action:@selector(forwardAStep) forControlEvents:UIControlEventTouchUpInside];
    _forwardButton.enabled = NO;

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(itemW * 4, 0, itemW, 50);
    [bottomView addSubview:saveButton];
    [saveButton addTarget:self action:@selector(saveClicked) forControlEvents:UIControlEventTouchUpInside];
    
    YMGraffitiGraphicsModel *model = [[YMGraffitiGraphicsModel alloc]init];
    model.drawType = YMGraffitiGraphicsViewTypeCircular;
    model.locationFrame = CGRectMake(0.1, 0.1, 0.5, 0.5);
    YMGraffitiGraphicsModel *model2 = [[YMGraffitiGraphicsModel alloc]init];
    model2.drawType = YMGraffitiGraphicsViewTypeSquare;
    model2.locationFrame = CGRectMake(0.6, -0.1, 0.2, 0.3);
    __weak typeof(self) weakSelf = self;
    _gView = [[YMGraffitiGraphicsView alloc]initWithImage:[YMGraffitiGraphicsView imageWithOriginalImage:image graffitiList:@[model, model2]] frame:self.bgView.bounds drawToolStatus:^(BOOL canWithdraw, BOOL canForward) {
        // 是否可回退或前进
        weakSelf.withdrawButton.enabled = canWithdraw;
        weakSelf.forwardButton.enabled = canForward;
    } drawingCallback:^(BOOL isDrawing) {
        // 是否z正在绘制
    } drawingDidTap:^{
        // 点击画布
    }];
    [self.bgView addSubview:_gView];
}

#pragma mark - Action

- (void)drawCircle:(UIButton *)button {
    if (button.selected) {
        return;
    }
    button.selected = YES;
    _squareButton.selected = NO;
    _gView.drawType = YMGraffitiGraphicsViewTypeCircular;
    
}

- (void)drawSquare:(UIButton *)button {
    if (button.selected) {
        return;
    }
    button.selected = YES;
    _roundButton.selected = NO;
    _gView.drawType = YMGraffitiGraphicsViewTypeSquare;
}

- (void)withdrawAStep {
    [_gView withdrawAStep];
}

- (void)forwardAStep {
    [_gView forwardAStep];
}

- (void)saveClicked {
    UIImageWriteToSavedPhotosAlbum([_gView imageWithGraffitiGraphics], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _bgView;
}

@end
