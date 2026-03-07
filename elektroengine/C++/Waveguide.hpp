//
//  Waveguide.hpp
//  elektroengine
//
//  Created by Edvin Berling on 2026-03-06.
//

#ifndef Waveguide_hpp
#define Waveguide_hpp



#include <gmsh.h>
using namespace std;
struct WaveguideMeshData {
    // All nodes
    
    std::vector<std::array<double, 3>> allNodeCoords;

    // All triangle elements (connectivity)
    std::vector<std::size_t> allElementTags;
    std::vector<std::size_t> allElementNodes;

    // Dielectric region elements
    std::vector<std::size_t> dielectricElementTags;
    std::vector<std::size_t> dielectricElementNodes;

    // Boundary line elements (2-node lines) for Robin BC assembly
    std::vector<std::size_t> leftBoundaryElementTags;
    std::vector<std::size_t> leftBoundaryElementNodes;
    std::vector<std::size_t> rightBoundaryElementTags;
    std::vector<std::size_t> rightBoundaryElementNodes;
};
WaveguideMeshData createWaveguide();
#endif /* Waveguide_hpp */
