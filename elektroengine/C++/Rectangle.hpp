//
//  Rectangle.hpp
//  elektroengine
//
//  Created by Edvin on 2026-03-09.
//

#ifndef Rectangle_hpp
#define Rectangle_hpp

#include <stdio.h>
#include <gmsh.h>
using namespace std;
struct RectangleData {
    vector<size_t> nodes;
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
};

RectangleData getRectangle(float w = 5, float h = 5);
#endif /* Rectangle_hpp */
