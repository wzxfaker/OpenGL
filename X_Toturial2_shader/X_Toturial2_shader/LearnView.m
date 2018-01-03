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



/*
 OpenGL的渲染管线主要包括：
 
 1.准备顶点数据（通过VBO、VAO和Vertex attribute来传递数据给OpenGL）
 
 2.顶点处理（这里主要由Vertex Shader来完成，从上图中可以看出，它还包括可选的Tessellation和Geometry shader阶段）
 
 3.顶点后处理（主要包括Clipping,顶点坐标归一化和viewport变换）
 
 4.Primitive组装(比如3点组装成一个3角形）
 
 5.光栅化成一个个像素
 
 6.使用Fragment shader来处理这些像素
 
 7.采样处理（主要包括Scissor Test, Depth Test, Blending, Stencil Test等）。
 
 OpenGL Shader Language,简称GLSL，它是一种类似于C语言的专门为GPU设计的语言，它可以放在GPU里面被并行运行。
 
 */
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

- (void)setupLayer{
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    //设置放大倍数
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    //CALayer默认是透明的，必须将它设为不透明才能让其看见
    self.myEagLayer.opaque = YES;
    //设置描绘属性
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    //设置为当前上下文,下边的代码必须写
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
    glGenRenderbuffers(1, &buffer);//创建一个渲染缓冲区对象
    self.myColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);//将该渲染缓冲区对象绑定到管线上
    //为颜色缓冲区分配存储空间
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}

- (void)setupFrameBuffer{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);//创建一个帧缓冲区对象
    self.myColorFrameBuffer = buffer;//指定要清除哪些缓冲区，GL_COLOR_BUFFER_BIT表示颜色缓冲区，GL_DEPTH_BUFFER_BIT表示深度缓冲区，GL_STENCIL_BUFFER_BIT表示模板缓冲区
    //设置为当前frameBuffer
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);//将该帧缓冲区对象绑定到管线上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);//将创建的渲染缓冲区绑定到帧缓冲区上，并使用颜色填充
}
/*
 着色器就是一段包含着色信息的源代码字符串。通常着色器分为顶点着色器（Vertex Shader）和片元着色器（Fragment Shader），两个着色器分别写在不同的文件中，文件没有固定的后缀名，可以根据你自己的爱好写，但是最好能区别文件中写的是顶点着色器还是片元着色器，不然时间长了自己都不知道哪个文件中写的是什么信息了。如你可以给你的顶点着色器后缀名命名为：vert, ver, v, vsh等，给你的片元着色器后缀名命名为：frag, fra, f, fsh等。
 
 着色器源代码和OpenGL源代码不是一起编译的，所以要特别强调我刚才说的“着色器是一段包含着色信息的源代码字符串”。所以，OpenGL源代码肯定是和工程一起编译的，但是着色器源代码是在运行期编译的。你可能会问，着色器的源代码是一个字符串怎么编译呢？所以OpenGL ES提供了一套运行期动态编译的流程：
 
 （1）创建着色器：glCreateShader
 
 （2）指定着色器源代码字符串：glShaderSource
 
 （3）编译着色器：glCompileShader
 
 （4）创建着色器可执行程序：glCompileShader
 
 （5）向可执行程序中添加着色器：glAttachShader
 
 （6）链接可执行程序：glLinkProgram
 */
- (void)render{
    glClearColor(0, 1.0, 0, 1.0);//指定填充屏幕的RGBA值
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);//设置窗口大小
    //读取文件路径（具体可以看：https://www.cnblogs.com/slysky/p/3949718.html，讲解非常详细）
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];//.vsh 是 vertex shader，用与顶点计算，可以理解控制顶点的位置，在这个文件中我们通常会传入当前顶点的位置，和纹理的坐标。
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];//.fsh 是片段shader。在这里面我可以对于每一个像素点进行重新计算。
    //总结：vsh 负责搞定像素位置 ,填写  gl_Posizion 变量，偶尔搞定一下点大小的问题，填写 gl_PixelSize。
    //     fsh 负责搞定像素外观，填写 gl_FragColor ，偶尔配套填写另外一组变量。
    
    //加载shader
    self.myProgram = [self loadShaders:vertFile frag:fragFile];
    
    glLinkProgram(self.myProgram);//链接源程序，你可能添加了多个着色器，链接程序
    GLint linkSuccess;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);//查看链接是否成功
    if (linkSuccess == GL_FALSE) { //连接错误
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return ;
    }
    else {
        NSLog(@"link ok");
        glUseProgram(self.myProgram); //成功便使用，避免由于未使用导致的的bug
    }
    //前三个是顶点坐标， 后面两个是纹理坐标
    GLfloat attrArr[] =
    {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);//把顶点数据从CPU复制到GPU
    
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    glEnableVertexAttribArray(position);
    
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL + 3);
    glEnableVertexAttribArray(textCoor);
    
    //加载纹理
    [self setupTexture:@"laba"];
    //获取shader里面的变量，这里记得要在glLinkProgram后面
    GLuint rotate = glGetUniformLocation(self.myProgram, "rotateMatrix");
    float radians = 10*3.14159f/180.0f;
    float s = sin(radians);
    float c = cos(radians);
    
    //z轴旋转矩阵
    GLfloat zRotation[16] = {
        c,-s,0,0.2,
        s,c,0,0,
        0,0,1.0,0,
        0,0,0,1.0
    };
    //设置旋转矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    glDrawArrays(GL_TRIANGLES, 0, 6);//将顶点数组使用三角形渲染，GL_TRIANGLES表示三角形， 0表示数组第一个值的位置，vertexCount表示数组长度
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */

- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag{
    GLuint verShader,fragShader;
    GLuint program = glCreateProgram();//创建一个渲染程序
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    //读取字符串
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);//根据类型创建一个空着色器，可以是顶点着色器，也可以是片元着色器
    glShaderSource(*shader, 1, &source, NULL);//source代表要执行的源代码字符串数组，1表示源代码字符串数组的字符串个数是一个，0表示源代码字符串长度数组的个数为0个
    glCompileShader(*shader);//编译着色器
}

- (GLuint)setupTexture:(NSString *)fileName{
    //1.获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    //2.读取图片大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));//rgba共4个byte
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    //3.在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    //4.绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width,fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glBindTexture(GL_TEXTURE_2D, 0);
    free(spriteData);
    return 0;
}

@end
