//
//  LearnView.m
//  X_Toturial2_shader
//
//  Created by admin on 2017/12/29.
//  Copyright © 2017年 gcg. All rights reserved.
//

#import "LearnView.h"
#import <OpenGLES/ES2/gl.h>

@interface LearnView ()

/** <##> */
@property (nonatomic, strong) EAGLContext *myContext;
/** <##> */
@property (nonatomic, strong) CAEAGLLayer *myEagLayer;
/** <##> */
@property (nonatomic, assign) GLuint myProgram;
/** <##> */
@property (nonatomic, assign) GLuint myColorRenderBuffer;
/** <##> */
@property (nonatomic, assign) GLuint myColorFrameBuffer;

- (void)setupLayer;

@end

@implementation LearnView

//default is [CALayer class]. Used when creating the underlying layer for the view.
/*
    每一个UIView都是寄宿在一个CALayer的示例上。这个图层是由视图自动创建和管理的，那我们可以用别的图层类型替代它么？一旦被创建，我们就无法代替这个图层了。但是如果我们继承了UIView，那我们就可以重写+layerClass方法使得在创建的时候能返回一个不同的图层子类。UIView会在初始化的时候调用+layerClass方法，然后用它的返回类型来创建宿主图层
 */
+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews{
    [self setupLayer];

}

- (void)setupLayer{
    


}

@end
