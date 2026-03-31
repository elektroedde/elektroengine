//
//  Circle2D.hpp
//  elektroengine
//
//  Created by Edvin on 2026-03-28.
//

#ifndef Circle2D_hpp
#define Circle2D_hpp

#include <stdio.h>
#include <gmsh.h>
using namespace std;
struct Circle2DData {
    vector<size_t> nodes;
    vector<double> nodeCoords;
    vector<size_t> boundaryNodes;
};

Circle2DData getCircle();

#endif /* Circle2D_hpp */
