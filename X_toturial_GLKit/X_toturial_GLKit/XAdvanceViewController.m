//
//  XAdvanceViewController.m
//  X_toturial_GLKit
//
//  Created by admin on 2018/1/3.
//  Copyright © 2018年 gcg. All rights reserved.
//

#import "XAdvanceViewController.h"

@interface XAdvanceViewController ()

/** <##> */
@property (nonatomic, strong) EAGLContext *myContext;
/** <##> */
@property (nonatomic, strong) GLKBaseEffect *myEffect;

@property (nonatomic , assign) int mCount;
@property (nonatomic , assign) float mDegreeX;
@property (nonatomic , assign) float mDegreeY;
@property (nonatomic , assign) float mDegreeZ;

@property (nonatomic , assign) BOOL mBoolX;
@property (nonatomic , assign) BOOL mBoolY;
@property (nonatomic , assign) BOOL mBoolZ;

@end

@implementation XAdvanceViewController{
    dispatch_source_t timer;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    //新建openGL上下文
    self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.myContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.myContext];
    glEnable(GL_DEPTH_TEST);//如果不开启会有什么效果
    //新的图形
    [self renderNew];
}

- (void)renderNew{
    //顶点数据，前三个是顶点坐标，中间三个是顶点颜色，最后两个是纹理坐标
    GLfloat attrArr[] =
    {
        -0.5f,0.5f,0.0f,    0.0f,0.0f,0.5f,    0.0f,1.0f,//左上
        -0.5f,-0.5f,0.0f,    0.5f,0.0f,1.0f,    0.0f,0.0f,//左下
        0.5f,-0.5f,0.0f,    0.0f,0.0f,0.5f,    1.0f, 0.0f,//右下
        0.5f,0.5f,0.0f,    0.0f,0.5f,0.0f,    1.0f, 1.0f,//右上
        0.0f,0.0f,1.0f,    1.0f,1.0f,1.0f,    0.5f, 0.5f,//顶点
    };
    //顶点索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 2,
        0, 1, 4,
        2, 4, 1,
        2, 3, 4,
        0, 4, 3,
    };
    self.mCount = sizeof(indices)/sizeof(GLuint);
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    //顶点坐标
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL);
    //顶点颜色
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+3);
    //纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+6);
    //加载纹理
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"png"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //着色器
    self.myEffect = [[GLKBaseEffect alloc] init];
    self.myEffect.texture2d0.enabled = GL_TRUE;
    self.myEffect.texture2d0.name = textureInfo.name;
    //初始的投影
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width/size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1, 10.0f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    self.myEffect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.myEffect.transform.modelviewMatrix = modelViewMatrix;
    
    //定时器
    double delayInSeconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delayInSeconds*NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{
        self.mDegreeX += 0.1  * self.mBoolX;
        self.mDegreeY += 0.1 * self.mBoolY;
        self.mDegreeZ += 0.1 * self.mBoolZ;
    });
    dispatch_resume(timer);
}

- (IBAction)onX:(id)sender {
    self.mBoolX = !self.mBoolX;
}

- (IBAction)onY:(id)sender {
    self.mBoolY = !self.mBoolY;
}

- (IBAction)onZ:(id)sender {
    self.mBoolZ = !self.mBoolZ;
}

/** 场景数据变化  这个是glkit的回调 */
- (void)update{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.mDegreeX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.mDegreeY);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.mDegreeZ);
    self.myEffect.transform.modelviewMatrix = modelViewMatrix;
}

/** 渲染场景代码 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.myEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
}

@end
