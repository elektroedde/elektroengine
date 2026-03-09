#include "Rectangle.hpp"

RectangleData getRectangle() {
    // Geometry
    float width = 12;
    float height = 5;
    float meshSize = width / 100;

    // Gmsh setup
    gmsh::initialize();
    gmsh::option::setNumber("General.Terminal", 0);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMax", meshSize);
    gmsh::model::occ::addRectangle(-width/2, -height/2, 0, width, height);
    
    gmsh::model::occ::synchronize();
    gmsh::model::mesh::generate(2);

    // Output vectors
    vector<size_t> nodes;
    vector<double> nodeCoords;

    // Unused output parameters required by Gmsh API
    vector<size_t> unused_st;
    vector<double> unused_d;

    // Retrieve mesh data
    gmsh::model::mesh::getElementsByType(2, unused_st, nodes);
    gmsh::model::mesh::getNodes(unused_st, nodeCoords, unused_d);
    
    // Get nodes on boundaries for Dirichlet
    vector<size_t> topBoundaryNodes;
    vector<size_t> rightBoundaryNodes;
    vector<size_t> leftBoundaryNodes;
    vector<size_t> bottomBoundaryNodes;
    
    gmsh::model::mesh::getNodes(bottomBoundaryNodes, unused_d, unused_d, 1, 1);
    gmsh::model::mesh::getNodes(rightBoundaryNodes, unused_d, unused_d, 1, 2);
    gmsh::model::mesh::getNodes(topBoundaryNodes, unused_d, unused_d, 1, 3);
    gmsh::model::mesh::getNodes(leftBoundaryNodes, unused_d, unused_d, 1, 4);

    // Get elements and node connectivity on boundaries for Robin
    vector<size_t> bottomBoundaryElementTags, bottomBoundaryElementNodes;
    vector<size_t> rightBoundaryElementTags, rightBoundaryElementNodes;
    vector<size_t> topBoundaryElementTags, topBoundaryElementNodes;
    vector<size_t> leftBoundaryElementTags, leftBoundaryElementNodes;
    
    gmsh::model::mesh::getElementsByType(1, bottomBoundaryElementTags, bottomBoundaryElementNodes, 1);
    gmsh::model::mesh::getElementsByType(1, rightBoundaryElementTags, rightBoundaryElementNodes, 2);
    gmsh::model::mesh::getElementsByType(1, topBoundaryElementTags, topBoundaryElementNodes, 3);
    gmsh::model::mesh::getElementsByType(1, leftBoundaryElementTags, leftBoundaryElementNodes, 4);

    // Pack result
    RectangleData data;
    data.nodes = nodes;
    data.nodeCoords = nodeCoords;
    data.topBoundaryNodes = topBoundaryNodes;
    data.bottomBoundaryNodes = bottomBoundaryNodes;
    data.leftBoundaryNodes = leftBoundaryNodes;
    data.rightBoundaryNodes = rightBoundaryNodes;
    data.topBoundaryElementTags = topBoundaryElementTags;
    data.topBoundaryElementNodes = topBoundaryElementNodes;
    data.rightBoundaryElementTags = rightBoundaryElementTags;
    data.rightBoundaryElementNodes = rightBoundaryElementNodes;
    data.bottomBoundaryElementTags = bottomBoundaryElementTags;
    data.bottomBoundaryElementNodes = bottomBoundaryElementNodes;
    data.leftBoundaryElementTags = leftBoundaryElementTags;
    data.leftBoundaryElementNodes = leftBoundaryElementNodes;
    
    gmsh::finalize();

    return data;
}
