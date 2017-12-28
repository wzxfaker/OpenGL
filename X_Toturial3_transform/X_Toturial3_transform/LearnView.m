//
//  LearnView.m
//  X_Toturial3_transform
//
//  Created by admin on 2017/12/28.
//  Copyright © 2017年 gcg. All rights reserved.
//

#import "LearnView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESUtils.h"
#import "GLESMath.h"

@interface LearnView ()

/** <##> */
@property (nonatomic, strong) EAGLContext *myContext;
/** <##> */
@property (nonatomic, strong) CAEAGLLayer *myEagLayer;
/** <##> */
@property (nonatomic, assign) GLuint myProgram;
/** <##> */
@property (nonatomic, assign) GLuint myVertices;
/** <##> */
@property (nonatomic, assign) GLuint myColorRenderBuffer;
/** <##> */
@property (nonatomic, assign) GLuint myColorFrameBuffer;

@end

@implementation LearnView{
    float degree;
    float yDegree;
    BOOL bX;
    BOOL bY;
    NSTimer *myTimer;
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews{
    [self setupLayer];
    [self setupContext];
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self render];
}

- (IBAction)xOnTimer:(id)sender {
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onRes:) userInfo:nil repeats:YES];
    }
    bX = !bX;
}

- (IBAction)yOnTimer:(id)sender {
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(onRes:) userInfo:nil repeats:YES];
    }
    bY = !bY;
}

- (void)onRes:(id)sender{
    degree += bX*5;
    yDegree += bY*5;
    [self render];
}

- (void)setupLayer{
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.myEagLayer.opaque = YES;
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    self.myContext = context;
}

- (void)destoryRenderAndFrameBuffer{
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
}

- (void)setupRenderBuffer{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}

- (void)setupFrameBuffer{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorRenderBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

- (void)render{
    glClearColor(0.5, 0.5, 0.8, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x*scale, self.frame.origin.y*scale, self.frame.size.width*scale, self.frame.size.height*scale);
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"glsl"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"glsl"];
    if (self.myProgram) {
        glDeleteProgram(self.myProgram);
        self.myProgram = 0;
    }
    self.myProgram = [self loadShaders:vertFile frag:fragFile];
    
    glLinkProgram(self.myProgram);
    GLint linkSuccess;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        
        return ;
    }else{
        glUseProgram(self.myProgram);
    }
    //把三个数字当做下标去attrArr中取相应的点绘制三角形
    GLuint indices[] =
    {
        0,3,2,
        0,1,3,
        0,2,4,
        0,4,1,
        2,3,4,
        1,4,3,
    };
    if (self.myVertices == 0) {
        glGenBuffers(1, &_myVertices);
    }
    //后三个是顶点颜色值
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      0.5f, 0.5f, 1.0f, //左上
        0.5f, 0.5f, 0.0f,       1.0f, 0.8f, 1.0f, //右上
        -0.5f, -0.5f, 0.0f,     1.0f, 0.0f, 1.0f, //左下
        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, //右下
        0.0f, 0.0f, 1.0f,      0.0f, 1.0f, 0.0f, //顶点
    };
    glBindBuffer(GL_ARRAY_BUFFER, _myVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, _myVertices);
    
    //获取三个，从第零个开始
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, NULL);
    glEnableVertexAttribArray(position);
    
    //获取三个，从第三个((float *)NULL + 3)开始
    GLuint positionColor = glGetAttribLocation(self.myProgram, "positionColor");
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (float *)NULL + 3);
    glEnableVertexAttribArray(positionColor);
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.myProgram, "projectionMatrix");
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.myProgram, "modelViewMatrix");
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    float aspect = width/height;//长宽比
    ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0f, 20.0f);//透视变换，视角30
    //设置glsl里面的投影矩阵
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    glEnable(GL_CULL_FACE);
    
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    //平移
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -10.0);
    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    //旋转
    ksRotate(&_rotationMatrix, degree, 1.0, 0.0, 0.0);//绕x轴
    ksRotate(&_rotationMatrix, yDegree, 0.0, 1.0, 0.0);//绕y轴
    ksRotate(&_rotationMatrix, yDegree, 0.0, 0.0, 1.0);//绕z轴
    //把变换矩阵想乘，注意先后顺序
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
//    NSLog(@"🏀--%lu,%lu",sizeof(indices),sizeof(indices[0]));
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag{
    GLuint verShader,fragShader;
    GLint program = glCreateProgram();
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

@end
