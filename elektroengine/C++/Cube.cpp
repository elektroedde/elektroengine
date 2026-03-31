#include "Cube.hpp"

CubeData getCube(float w, float h, float d) {
    // Geometry
    float width = w;
    float height = h;
    float depth = d;
    float meshSize = width / 10;

    // Gmsh setup
    gmsh::initialize();
    gmsh::option::setNumber("General.Terminal", 0);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMax", meshSize);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMin", meshSize);

    gmsh::model::occ::addBox(-width/2, -height/2, -depth/2, width, height, depth);
    
    gmsh::model::occ::synchronize();
    gmsh::model::mesh::generate(3);

    // Output vectors
    vector<size_t> nodes;
    vector<double> nodeCoords;

    // Unused output parameters required by Gmsh API
    vector<size_t> unused_st;
    vector<double> unused_d;

    // Retrieve mesh data
    gmsh::model::mesh::getElementsByType(4, unused_st, nodes);
    gmsh::model::mesh::getNodes(unused_st, nodeCoords, unused_d);
    
    // Surface triangles (element type 2) for rendering
    vector<size_t> surfaceNodes;
    gmsh::model::mesh::getElementsByType(2, unused_st, surfaceNodes);
    
    // Get nodes on boundaries for Dirichlet
    vector<size_t> topBoundaryNodes;
    vector<size_t> rightBoundaryNodes;
    vector<size_t> leftBoundaryNodes;
    vector<size_t> bottomBoundaryNodes;
    vector<size_t> frontBoundaryNodes;
    vector<size_t> backBoundaryNodes;
    
    gmsh::model::mesh::getNodes(leftBoundaryNodes, unused_d, unused_d, 2, 1, true);
    gmsh::model::mesh::getNodes(rightBoundaryNodes, unused_d, unused_d, 2, 2, true);
    gmsh::model::mesh::getNodes(bottomBoundaryNodes, unused_d, unused_d, 2, 3, true);
    gmsh::model::mesh::getNodes(topBoundaryNodes, unused_d, unused_d, 2, 4, true);
    gmsh::model::mesh::getNodes(frontBoundaryNodes, unused_d, unused_d, 2, 5, true);
    gmsh::model::mesh::getNodes(backBoundaryNodes, unused_d, unused_d, 2, 6, true);
    // Get elements and node connectivity on boundaries for Robin
    vector<size_t> bottomBoundaryElementTags, bottomBoundaryElementNodes;
    vector<size_t> rightBoundaryElementTags, rightBoundaryElementNodes;
    vector<size_t> topBoundaryElementTags, topBoundaryElementNodes;
    vector<size_t> leftBoundaryElementTags, leftBoundaryElementNodes;
    vector<size_t> frontBoundaryElementTags, frontBoundaryElementNodes;
    vector<size_t> backBoundaryElementTags, backBoundaryElementNodes;
    
    gmsh::model::mesh::getElementsByType(2, leftBoundaryElementTags, leftBoundaryElementNodes, 1);
    gmsh::model::mesh::getElementsByType(2, rightBoundaryElementTags, rightBoundaryElementNodes, 2);
    gmsh::model::mesh::getElementsByType(2, bottomBoundaryElementTags, bottomBoundaryElementNodes, 3);
    gmsh::model::mesh::getElementsByType(2, topBoundaryElementTags, topBoundaryElementNodes, 4);
    gmsh::model::mesh::getElementsByType(2, frontBoundaryElementTags, frontBoundaryElementNodes, 5);
    gmsh::model::mesh::getElementsByType(2, backBoundaryElementTags, backBoundaryElementNodes, 6);

    // Pack result
    CubeData data;
    data.nodes = nodes;
    data.surfaceNodes = surfaceNodes;
    data.nodeCoords = nodeCoords;
    

    
    data.leftBoundaryNodes = leftBoundaryNodes;
    data.leftBoundaryElementTags = leftBoundaryElementTags;
    data.leftBoundaryElementNodes = leftBoundaryElementNodes;
    
    data.rightBoundaryNodes = rightBoundaryNodes;
    data.rightBoundaryElementTags = rightBoundaryElementTags;
    data.rightBoundaryElementNodes = rightBoundaryElementNodes;
    
    data.frontBoundaryNodes = frontBoundaryNodes;
    data.frontBoundaryElementTags = frontBoundaryElementTags;
    data.frontBoundaryElementNodes = frontBoundaryElementNodes;
    
    data.backBoundaryNodes = backBoundaryNodes;
    data.backBoundaryElementTags = backBoundaryElementTags;
    data.backBoundaryElementNodes = backBoundaryElementNodes;
    
    data.bottomBoundaryNodes = bottomBoundaryNodes;
    data.bottomBoundaryElementTags = bottomBoundaryElementTags;
    data.bottomBoundaryElementNodes = bottomBoundaryElementNodes;

    data.topBoundaryNodes = topBoundaryNodes;
    data.topBoundaryElementTags = topBoundaryElementTags;
    data.topBoundaryElementNodes = topBoundaryElementNodes;
    
    gmsh::finalize();

    return data;
}
