//
//  ViewController.m
//  X_Toturial1_GLKit
//
//  Created by admin on 2017/12/28.
//  Copyright © 2017年 gcg. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

/** GL上下文 */
@property (nonatomic, strong) EAGLContext *mContext;
/** <##> */
@property (nonatomic, strong) GLKBaseEffect *mEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setConfig];
    [self uploadVertexArr];
    [self uploadTexture];
}

- (void)setConfig{
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];//2.0 还有1.0和3.0
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;//颜色缓冲区格式
    [EAGLContext setCurrentContext:self.mContext];
}

- (void)uploadVertexArr{
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat vertexData[] = {
        /*
        1.0,-1.0,0.0f,  1.0,0.0f,//右下
        1.0,1.0,0.0f,   1.0,1.0,//右上
        -0.5,0.5,0.0f,  0.0f,1.0,//左上
        
        0.5,-0.5,0.0f,  1.0,0.0f,//右下
        -1.0,1.0,0.0f,  0.0f,1.0,//左上
        -1.0,-1.0,0.0f,  0.0f,0.0f//左下
         */
        //左边图片
        -1.0,0.5,0.0f,  0.0,1.0f,//左上
        -1.0,-0.5,0.0f,   0.0,0.0,//左下
        0,-0.5,0.0f,  1.0f,0.0,//右下
        
        -1.0,0.5,0.0f,  0.0,1.0f,//左上
        0.0,0.5,0.0f,  1.0f,1.0,//右上
        0,-0.5,0.0f,  1.0f,0.0,//右下
        
        //右边图片
        0.0f,0.5,0.0f,  1.0,1.0f,//左上
        0.0f,-0.5,0.0f,   1.0,0.0,//左下
        1.0,-0.5,0.0f,  0.0f,0.0f,//右下
        
        0.0f,0.5,0.0f,  1.0,1.0f,//左上
        1.0,0.5,0.0f,  0.0f,1.0,//右上
        1.0,-0.5,0.0f,  0.0f,0.0f,//右下
    };
    
    //顶点数据缓存
    GLuint buffer;
    glGenBuffers(1, &buffer);//glGenBuffers申请一个标识符
    glBindBuffer(GL_ARRAY_BUFFER, buffer);//glBindBuffer把标识符绑定到GL_ARRAY_BUFFER上
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);//glBufferData把顶点数据从cpu内存复制到gpu内存
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);//缓存顶点数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+0);//glEnableVertexAttribArray 是开启对应的顶点属性
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);//纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+3);//glVertexAttribPointer设置合适的格式从buffer里面读取数据
}

- (void)uploadTexture{
    /*
    GLKTextureLoader读取图片，创建纹理GLKTextureInfo
    创建着色器GLKBaseEffect，把纹理赋值给着色器
     */
    //纹理贴图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"for_test" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
}


//渲染场景代码
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.3, 0.6, 1.0, 1.0);//设置背景颜色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 12);//
    /*
    #define GL_POINTS                                        0x0000
    #define GL_LINES                                         0x0001
    #define GL_LINE_LOOP                                     0x0002
    #define GL_LINE_STRIP                                    0x0003
    #define GL_TRIANGLES                                     0x0004
    #define GL_TRIANGLE_STRIP                                0x0005
    #define GL_TRIANGLE_FAN
     */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
