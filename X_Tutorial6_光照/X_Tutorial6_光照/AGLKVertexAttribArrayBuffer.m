//
//  AGLKVertexAttribArrayBuffer.m
//  X_Tutorial6_光照
//
//  Created by admin on 2018/1/8.
//  Copyright © 2018年 gcg. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@interface AGLKVertexAttribArrayBuffer ()

/** <##> */
@property (nonatomic, assign) GLsizeiptr bufferSizeBytes;
/** <##> */
@property (nonatomic, assign) GLsizeiptr stride;

@end

@implementation AGLKVertexAttribArrayBuffer

@synthesize name;
@synthesize bufferSizeBytes;
@synthesize stride;

//This method creates a vertex attribute array buffer in the current OpenGL ES context for the thread upon which this method is called.
- (id)initWithAttribStride:(GLsizeiptr)aStride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage{
    NSParameterAssert(0 < aStride);
    NSAssert((0 < count && NULL != dataPtr) || (0 == count && NULL == dataPtr), @"data must not be NULL or count > 0");
    if (nil != (self = [super init])) {
        stride = aStride;
        bufferSizeBytes = stride * count;
        
    }
    return self;
}

@end
