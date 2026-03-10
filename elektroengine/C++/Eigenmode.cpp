#include "Eigenmode.hpp"

EigenmodeData getEigenmode() {
    // Geometry
    float width = 14;
    float height = 6;
    float meshSize = width / 100;

    // Gmsh setup
    gmsh::initialize();
    gmsh::option::setNumber("General.Terminal", 0);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMin", meshSize);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMax", meshSize);

    gmsh::model::occ::addRectangle(-width/2, -height/2, 0, width, height);
    
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
    // Pack result
    EigenmodeData data;
    data.nodes = nodes;
    data.nodeCoords = nodeCoords;
    data.boundaryNodes = boundaryNodes;

    return data;
}
