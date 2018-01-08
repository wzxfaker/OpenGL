//
//  AdvanceViewController.m
//  X_Tutorial6_光照
//
//  Created by admin on 2018/1/8.
//  Copyright © 2018年 gcg. All rights reserved.
//

#import "AdvanceViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sceneUtil.h"

@interface AdvanceViewController ()

/** <##> */
@property (nonatomic, strong) EAGLContext *myContext;
/** <##> */
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
/** <##> */
@property (nonatomic, strong) GLKBaseEffect *extraEffect;
/** <##> */
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
/** <##> */
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *extraBuffer;
/** <##> */
@property (nonatomic, assign) BOOL shouldUseFaceNormals;
/** <##> */
@property (nonatomic, assign) BOOL shouldDrawNormals;
/** <##> */
@property (nonatomic, assign) GLfloat centerVertexHeight;

//绘制法向量
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender;
//使用平面向量
- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender;
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender;

@end

@implementation AdvanceViewController{
    SceneTriangle triangles[NUM_FACES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    //新建OpenGLES上下文
    self.myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.myContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.myContext];
    
    /*
     ambientColor——环境色，材质对环境光颜色RGB各分量的反射系数
     diffuseColor——漫反射色，材质对光源颜色RGB各分量的漫反射系数
     specularColor——镜面反射色，材质对光源颜色RGB各分量的镜面反射系数
     emissiveColor——自发光色，材质自身的颜色
     shininess——光泽度，高光光斑的大小范围
     transparency——透明度，材质的透明状态，与真透明不同，这里的透明与厚度没有关系
     */
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1.0);
    self.baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 0.5, 0.0);
    
    self.extraEffect = [[GLKBaseEffect alloc] init];
    //A Boolean value that indicates whether or not to use the constant color.If the value is set to GL_TRUE, then the value stored in the constantColor property is used as the color value for each vertex. If the value is set to GL_FALSE, then your application is expected to enable the GLKVertexAttribColor attribute and provide per-vertex color data. The default value is GL_FALSE.
    self.extraEffect.useConstantColor = GL_TRUE;
    
    //尝试注释变化
    if (true) {
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60), 1.0, 0.0, 0.0);//先绕x轴转-60度
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30), 0.0, 0.0, 1.0);//再绕z轴转-30度
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0, 0.0, 0.5);//沿z轴移动0.5
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    
    [self setClearColor:GLKVector4Make(0.0, 0.0, 0.0, 1.0)];
    
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexC);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
    self.extraBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:0 bytes:NULL usage:GL_DYNAMIC_DRAW];
    self.centerVertexHeight = 0.0f;
    self.shouldUseFaceNormals = YES;
}

- (void)setClearColor:(GLKVector4)clearColorRGBA{
    glClearColor(clearColorRGBA.r, clearColorRGBA.g, clearColorRGBA.b, clearColorRGBA.a);

}


- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender {
    self.shouldDrawNormals = sender.isOn;
}

- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender {
    self.shouldUseFaceNormals = sender.isOn;
}

- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender {
    self.centerVertexHeight = sender.value;
}


#pragma mark - Accessors with side effects
- (void)setCenterVertexHeight:(GLfloat)centerVertexHeight{
    _centerVertexHeight = centerVertexHeight;
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = _centerVertexHeight;
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    [self updateNormals];
}

//使用平面向量
- (void)setShouldUseFaceNormals:(BOOL)aValue{
    if (aValue != _shouldUseFaceNormals) {
        _shouldUseFaceNormals = aValue;
        [self updateNormals];
    }
}

- (void)updateNormals{


}


@end
