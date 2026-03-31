//
//  Circle2D.cpp
//  elektroengine
//
//  Created by Edvin on 2026-03-28.
//

#include "Circle2D.hpp"


Circle2DData getCircle() {
    float rx = 2;
    float ry = 2;
    float meshSize = rx / 10;

    // Gmsh setup
    gmsh::initialize();
    gmsh::option::setNumber("General.Terminal", 0);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMin", meshSize);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMax", meshSize);
    
    gmsh::model::occ::addDisk(0, 0, 0, rx, ry);
    
    gmsh::model::occ::synchronize();
    gmsh::model::mesh::generate(2);
    
    // Output vectors
    vector<size_t> nodes;
    vector<double> nodeCoords;
    vector<size_t> boundaryNodes;

    // Unused output parameters required by Gmsh API
    vector<size_t> unused_st;
    vector<double> unused_d;

    // Retrieve mesh data
    gmsh::model::mesh::getElementsByType(2, unused_st, nodes);
    gmsh::model::mesh::getNodes(unused_st, nodeCoords, unused_d);
    gmsh::model::mesh::getNodesByElementType(1, boundaryNodes, unused_d, unused_d);
    
    gmsh::finalize();
    
    Circle2DData circle;
    
    circle.nodes = nodes;
    circle.boundaryNodes = boundaryNodes;
    circle.nodeCoords = nodeCoords;
    
    return circle;
}
