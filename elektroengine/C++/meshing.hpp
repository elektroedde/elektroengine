#ifndef meshing_h
#define meshing_h


#include <gmsh.h>

#import "Waveguide.hpp"
#import "Eigenmode.hpp"
#import "Rectangle.hpp"
using namespace std;

struct MeshData {
    vector<size_t> nodes;
    vector<vector<double>> nodeCoords;
    vector<size_t> physicalGroup1_nodes;
    vector<double> physicalGroup1_coords;

    vector<size_t> physicalGroup2_nodes;
    vector<double> physicalGroup2_coords;
    vector<size_t> oneDimElements;
    vector<size_t> oneDimNodeTags;
};

struct CylinderMeshData {
    vector<size_t> allNodeTags;
    vector<size_t> allElementTags;
    vector<vector<double>> allNodeCoords;
    vector<size_t> airboxElementNodes;    // triangle node tags for the airbox region
    vector<size_t> airboxElementTags;
    vector<size_t> cylinderElementNodes;  // triangle node tags for the cylinder region
    vector<size_t> cylinderElementTags;
    vector<size_t> boundaryNodes;         // nodes on the outer rectangle boundary
};


CylinderMeshData createChargeCylinder();


#endif /* meshing_h */
