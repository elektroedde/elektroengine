//
//  Hello.hpp
//  Simple C++ header file
//

#ifndef meshing_h
#define meshing_h


#include <gmsh.h>

// Struct to hold mesh data
struct MeshData {
    std::vector<std::vector<double>> points; // n x 3 array (each row is [x, y, z])
    size_t numPoints;
    std::vector<std::size_t> tags;
    std::vector<std::size_t> eTags;
    std::vector<std::size_t> nTags;
    std::vector<double> p_coord;
    std::vector<std::size_t> n_tag; // n x 3 array (each row is [x, y, z])
    std::vector<double> n_coord; // n x 3 array (each row is [x, y, z])

    std::vector<std::vector<double>> n_cord; // n x 3 array (each row is [x, y, z])

    std::vector<std::size_t> physicalGroup1_nodes;
    std::vector<double> physicalGroup1_coords;

    std::vector<std::size_t> physicalGroup2_nodes;
    std::vector<double> physicalGroup2_coords;




};

// Function declarations
std::vector<double> printHello();
MeshData getMeshPoints(); // New function that returns structured data
void createRectangle();



#endif /* meshing_h */
