//
//  ViewController.m
//  猜图游戏
//
//  Created by Li Rui on 16/1/19.
//  Copyright © 2016年 Li Rui. All rights reserved.
//

#import "ViewController.h"
#import "PicQuestion.h"
/*
 需求分析：
 1、搭建界面
 1>上半部分，固定的，用xib做
 2>下半部分，根据题目的变化，不断变化和调整，用代码的方式实现会比较合适
    *备选按钮区域
    *答案按钮区域
 
 2、编写代码
 1>大图小图的切换
 2>下一题
 2>备选按钮的点击
 3>备选按钮的点击，让蚊子进入答案区
 4>判断胜负
    *胜利：进入下一题
    *失败：提示用户重新选择
 5>答题按钮的点击
    *把答案区的文字回复到备选区域
 
 3、收尾工作：图标和启动图片
 重点：MVC,游戏代码的逻辑实现为主，不过分抽取代码，保证代码的逻辑连贯性
 */
#define  kButtonWH      35
#define  kButtonMargin  10
#define  kTotoalCol     7
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *noLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property(nonatomic,strong)UIButton *cover;
@property(nonatomic,strong)NSArray *questions;
//题目索引
@property(nonatomic,assign)int index;
@property (weak, nonatomic) IBOutlet UIButton *nextQuestionButton;
@property (weak, nonatomic) IBOutlet UIView *anserView;

@property (weak, nonatomic) IBOutlet UIView *optionView;
@property (weak, nonatomic) IBOutlet UIButton *scoreButton;

@end

@implementation ViewController

-(NSArray *)questions
{
    if (_questions==nil) {
        _questions=[PicQuestion questions];
    }
    return _questions;
}

-(UIButton *)cover
{
    if (_cover==nil) {
        _cover=[[UIButton alloc]initWithFrame:self.view.bounds];
        _cover.alpha=0.0;
        _cover.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.5];
        [_cover addTarget:self action:@selector(bigImg) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cover];
    }
    return _cover;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",self.questions);
    
    self.index = -1;
    [self nextQuestion];
    
//    NSArray *array=@[@(1),@(2),@(3),@(4)];
//    //排序
//    array =[array sortedArrayUsingComparator:^NSComparisonResult(NSNumber *num1, NSNumber *num2) {
//        
//        //乱序=》一会升序一会降序
//        //随机 arc4random_uniform(10)=>0~9之间的随机数
//        int seed = arc4random_uniform(2);
//        if (seed) {
//            return [num1 compare:num2];
//        }else{
//            return [num2 compare:num1];
//        }
//    }];
//    NSLog(@"%@",array);

    
//    for (PicQuestion *obj in _questions) {
//        NSLog(@"%@",obj);
//    }

}

/*
 调整状态栏的颜色
 UIStatusBarStyleLightContent 亮色状态栏
  UIStatusBarStyleDefault     黑色状态栏
 */
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
   
}
/*
 主要的方法：尽量保留简短的代码，主要体现思路和流程即可。
 */
#pragma mark -下一题
- (IBAction)nextQuestion {
    
    //1、当前答题的索引，索引递增
    self.index++;
    if (self.index ==self.questions.count) {
        NSLog(@"通关啦");
        return;
    }
    //如果index已经最后一题，提示用户，播放音乐
    
    //2、从数组中按照索引取出题目模型数据
    PicQuestion *question = _questions[self.index];
    
    //3、设置基本信息
    [self setBasicInfo:question];
    
    //4、设置答案按钮
    [self createAnswerButton:question];
    
    //5、设置答案区按钮
    [self createOptionButton:question];
    
    
}

//设置基本信息
-(void)setBasicInfo:(PicQuestion *)question
{
    //设置基本信息
    _noLabel.text=[NSString stringWithFormat:@"%d/%d",self.index+1,self.questions.count];
    _titleLabel.text=question.title;
    [self.iconButton setImage:[UIImage imageNamed:question.icon] forState:UIControlStateNormal];
    
    //如果到达最后一题，禁用下一个题按钮
    self.nextQuestionButton.enabled=(self.index < self.questions.count-1);

}

#pragma mark -创建答案区按钮
-(void)createAnswerButton:(PicQuestion *)question
{
    //设置答案按钮
    
    //首先清除掉答题区内的所有按钮
    //所有控件都继承自UIView，多态的应用
    
    for (UIView *btn in self.anserView.subviews) {
        
        [btn removeFromSuperview];
    }
    
    CGFloat anserW = self.anserView.bounds.size.width;
    int length =question.answer.length;
    CGFloat anserX = (anserW - kButtonWH*length - kButtonMargin *(length - 1))*0.5;
    
    //创建所有答案的按钮
    for (int i=0; i<length; i++) {
        CGFloat x = anserX + i * (kButtonMargin + kButtonWH);
        UIButton *btn =[[UIButton alloc]initWithFrame:CGRectMake(x, 0, kButtonWH, kButtonWH)];
       // btn.backgroundColor=[UIColor whiteColor];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        
        //设置标题区颜色
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.anserView addSubview:btn];
        
        [btn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
    }
 
    
}

#pragma mark -创建备选区按钮
-(void)createOptionButton:(PicQuestion *)question
{
    /*
        问题：每次调用下一题方法时，都会重新创建21个按钮
        解决：如果按钮已经存在，并且是21个，只需要改按钮标题即可。
     */
//设置备选区按钮
    if (self.optionView.subviews.count !=question.options.count) {
        
        //重新创建所有按钮
        for (UIView *view in self.optionView.subviews) {
            [view removeFromSuperview];
        }
        
        CGFloat optionsW = self.optionView.bounds.size.width;
        CGFloat optionsX = ((optionsW -kTotoalCol *kButtonWH) - (kTotoalCol -1)*kButtonMargin )*0.5;
        
        for (int i =0; i<question.options.count; i++) {
            int row = i /kTotoalCol;
            int col = i %kTotoalCol;
            
            CGFloat x = optionsX + col *(kButtonMargin +kButtonWH);
            CGFloat y = row *(kButtonWH + kButtonMargin);
            UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(x, y, kButtonWH, kButtonWH)];
            //btn.backgroundColor=[UIColor whiteColor];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
           // [btn setTitle:question.options[i] forState:UIControlStateNormal];
            
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.optionView addSubview:btn];
            
            //添加按钮监听方法
            [btn addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];

        }


    }
    
    //若果按钮已经存在，再点击下一题的时候，只需要设置标题即可
    int i=0;
    
//    //方法一：让模型打乱数据，每次点击下一题时，都会乱序一次
//    [question randomOptions];
    for (UIButton *btn in self.optionView.subviews) {
        
        //设置备选答案
        [btn setTitle:question.options[i++] forState:UIControlStateNormal];
        
        //恢复所有按钮的隐藏状态
        btn.hidden = NO;
        
    }
    
}
#pragma mark -候选按钮点击方法
-(void)optionClick:(UIButton *)button
{
   //NSLog(@"%@",button.currentTitle);
    //1、在答案区找到第一个文字为空的按钮
    UIButton *btn =[self firstAnwersBtn];
    
    //如果没有找到空按钮=>所有的“答题按钮都有字”，直接返回
    if (btn==nil)
    {
        //都有字判断胜负
        
    }else{
        //2、将btn上的标题设置给答案区的按钮
        [btn setTitle:button.currentTitle forState:UIControlStateNormal];
        
        //3、将btn隐藏
        button.hidden = YES;
    }
    
    //4.判断结果
    [self judge];

}

#pragma mark -判断结果
-(void)judge
{
    //遍历所有按钮
    BOOL isFull = YES;
    NSMutableString *strM=[NSMutableString string];
    for (UIButton *btn in self.anserView.subviews) {
        if (btn.currentTitle.length == 0) {
            //只要有一个按钮没有字
            isFull = NO;
            break;
        }else
        {
            //有字，拼接临时字符串
            [strM appendString:btn.currentTitle];
        }
    }
    if (isFull) {
        NSLog(@"都有字");
        //判断是否和答案一致
        //根据self.index获得当前的question
        PicQuestion *question = self.questions[self.index];
        
        //如果一致，进入下一题
        if ([strM isEqualToString:question.answer]) {
            NSLog(@"答对了");
            [self setAnwerButtonsColor:[UIColor blueColor]];
            
            //增加分数
            [self changeScore:1000];
            //等待0.5s,进图下一题
            [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:0.5];
        }else{
            //若不一致，修改按钮文字颜色，提示用户
            NSLog(@"答错了");
            [self setAnwerButtonsColor:[UIColor redColor]];
        }
   
    }
}
#pragma mark -修改答题区按钮的颜色
-(void)setAnwerButtonsColor:(UIColor *)color
{
    for (UIButton *btn in self.anserView.subviews) {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}
//在答题区找到第一个文字为空的按钮
-(UIButton *)firstAnwersBtn
{
    //取按钮的标题，
    //遍历答案区所有按钮
    for (UIButton *btn  in self.anserView.subviews) {
        //字符串的比较效率较低
        if (btn.currentTitle.length ==0) {
            return btn;
        }
    }
    return nil;
}

#pragma mark -  答题区按钮点击方法
-(void)answerClick:(UIButton *)button
{
    //1、若按钮没有字，直接返回
    if (button.currentTitle.length ==0) return;
    
    //2、如果有字，清除文字，候选区按钮显示
    //1.使用button
    UIButton *btn =[self optionButtonWithTitle:button.currentTitle isHidden:YES];
    
    //2.显示对应按钮
    btn.hidden = NO;
    
    //3.清楚button的文字()
    [button setTitle:@"" forState:UIControlStateNormal];
    
    //只要点击了按钮上的文字，意味着答题区的内容是不完整地
    [self setAnwerButtonsColor:[UIColor blackColor]];
    
}
-(UIButton *)optionButtonWithTitle:(NSString *)title isHidden:(BOOL)isHidden
{
    for (UIButton *button in self.optionView.subviews) {
        if ([button.currentTitle isEqualToString:title] && button.isHidden == isHidden) {
            return button;
        }
    }
    return nil;
}

#pragma mark -提示功能
- (IBAction)tipClick {
        //把答题区所有按钮清空
         for (UIButton *btn in self.anserView.subviews) {
             [self answerClick:btn];
         }
        //把正确答案的第一个字设置到答题区
        //1、知道答案的第一个字
    PicQuestion *question = self.questions[self.index];
    NSString *firstWord =[question.answer substringToIndex:1];
    
    //取出文字对应的候选按钮
//    for (UIButton *btn in self.optionView.subviews) {
//        if ([btn.currentTitle isEqualToString:firstWord]&& !btn.isHidden) {
//            
//            [self optionClick:btn];
//            
//            break;
//        }
//    }
    
    UIButton *btn =[self optionButtonWithTitle:firstWord isHidden:NO];
  
    [self optionClick:btn];
    
    //扣分
    [self changeScore:-500];
}
#pragma mark -分数处理
-(void)changeScore:(int)score
{
    //取出当前的分数
    int currentScore = self.scoreButton.currentTitle.intValue;
    
    //使用score调整分数
    currentScore +=score;
    
    //重新设置分数
    [self.scoreButton setTitle:[NSString stringWithFormat:@"%d",currentScore] forState:UIControlStateNormal];
}
#pragma mark -图片缩放
//图片缩放
- (IBAction)bigImg
{
    /*
     视图
     1、添加一个蒙板
     2、将图像按钮弄到最前面
     3、动画放大图像按钮
     */
    
    //如果没有放大，就放大，否则就缩小
    //通过蒙板的alpha来判断按钮是否已经被放大
    
    if (self.cover.alpha==0) {//放大
        //1、添加一个蒙板
        //    UIButton *cover=[[UIButton alloc]initWithFrame:self.view.bounds];
        //    cover.alpha=0.0;
        //    cover.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.5];
        //    [cover addTarget:self action:@selector(smallImg:) forControlEvents:UIControlEventTouchUpInside];
        //    [self.view addSubview:cover];
        
        //self.cover已经调用了get方法，可以省略
//        //由于懒加载，在前置子视图并没有被创建，
//        [self cover];
        
        //将子视图前置
        [self.view bringSubviewToFront:self.iconButton];
        
        //3、动画放大图像按钮
        CGFloat w = self.view.bounds.size.width;
        CGFloat h=w;
        CGFloat y=(self.view.bounds.size.height - h)*0.5;
        
        [UIView animateWithDuration:1.0f animations:^{
            
            self.iconButton.frame = CGRectMake(0, y, w, h);
            //直到这里cover才被创建
            self.cover.alpha=1.0;
        }];
        

    }else{//缩小
        [UIView animateWithDuration:1.0f animations:^{
            
            //将图像回复初始位置
            self.iconButton.frame=CGRectMake(85, 85, 150, 150);
            self.cover.alpha=0.0;
        } ];

        
    }
    
   
}

-(void)sortWith:(NSArray *)array
{
    //排序
    array =[array sortedArrayUsingComparator:^NSComparisonResult(NSNumber *num1, NSNumber *num2) {
        NSLog(@"%@ %@",num1,num2);
        //降序
        return [num2 compare:num1];
    }];
    NSLog(@"%@",array);

}
-(void)arrayWith:(NSArray *)array
{
    
    int i=0;
    for (NSNumber *num in array) {
        NSLog(@"%@",num);
        
        if (i==1) {
            break;
        }
        i++;
    }
    
    //参数：对象，索引，是否中断
    [array enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * __nonnull stop) {
        NSLog(@"%@",obj);
        
        //如果idx==1,退出循环
        if (idx==1) {
            *stop = YES;
        }
    }];
    
    
    
}
- (IBAction)helpButton {
    
    //清楚答案区按钮上的文字
    for (UIButton *btn in self.anserView.subviews) {
        
        [self answerClick:btn];
    }
    
    
    //扣分
    
    int score = self.scoreButton.currentTitle.intValue;
    if (score <= -800 ) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"您的金币所剩不多" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil ];
      
        
        [alert show];
    }else{
        //把正确答案设置到答题区
        PicQuestion *question =self.questions[self.index];
        NSMutableArray *titles=[NSMutableArray array];
        for (int i=0; i<question.answer.length; i++) {
            NSString *words = [question.answer substringWithRange:NSMakeRange(i, 1)];
            
            [titles addObject:words];
            
            UIButton *btn =self.anserView.subviews[i];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }

        [self changeScore:-800];
        
    }
}

/*
    小图
 */

//-(void)smallImg:(UIButton *)cover
//{
//    //动画一定义，马上就开始
//    [UIView animateWithDuration:1.0f animations:^{
//       
//        //将图像回复初始位置
//        self.iconButton.frame=CGRectMake(85, 85, 150, 150);
//        self.cover.alpha=0.0;
//    } completion:^(BOOL finished) {
//        
////        //删除cover.使用懒加载，不需要删除蒙板
////        [self.cover removeFromSuperview];
//
//    }];
//    
//}
@end
