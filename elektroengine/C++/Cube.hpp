//
//  Rectangle.hpp
//  elektroengine
//
//  Created by Edvin on 2026-03-09.
//

#ifndef Cube_hpp
#define Cube_hpp

#include <stdio.h>
#include <gmsh.h>
using namespace std;
struct CubeData {
    vector<size_t> nodes;
    vector<size_t> surfaceNodes;
    vector<double> nodeCoords;
    vector<size_t> topBoundaryNodes;
    vector<size_t> topBoundaryElementTags;
    vector<size_t> topBoundaryElementNodes;
    
    vector<size_t> rightBoundaryNodes;
    vector<size_t> rightBoundaryElementTags;
    vector<size_t> rightBoundaryElementNodes;
    
    vector<size_t> bottomBoundaryNodes;
    vector<size_t> bottomBoundaryElementTags;
    vector<size_t> bottomBoundaryElementNodes;
    
    vector<size_t> leftBoundaryNodes;
    vector<size_t> leftBoundaryElementTags;
    vector<size_t> leftBoundaryElementNodes;
    
    vector<size_t> frontBoundaryNodes;
    vector<size_t> frontBoundaryElementTags;
    vector<size_t> frontBoundaryElementNodes;
    
    vector<size_t> backBoundaryNodes;
    vector<size_t> backBoundaryElementTags;
    vector<size_t> backBoundaryElementNodes;

};

CubeData getCube(float w = 5, float h = 5, float d = 5);
#endif /* Cube_hpp */
