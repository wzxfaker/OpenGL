//
//  sceneUtil.m
//  X_Tutorial6_光照
//
//  Created by admin on 2018/1/8.
//  Copyright © 2018年 gcg. All rights reserved.
//

#import "sceneUtil.h"

#pragma mark - Triangle
/**
 *  创建一个三角形
 *
 *  @param vertexA 顶点A
 *  @param vertexB 顶点B
 *  @param vertexC 顶点C
 *
 *  @return 三角形
 */
SceneTriangle SceneTriangleMake(const SceneVertex vertexA,const SceneVertex vertexB,const SceneVertex vertexC){
    SceneTriangle result;
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    return result;
}


