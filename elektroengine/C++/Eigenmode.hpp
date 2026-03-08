#ifndef Eigenmode_hpp
#define Eigenmode_hpp

#include <gmsh.h>
using namespace std;
struct EigenmodeData {
    vector<size_t> nodes;
    vector<double> nodeCoords;
    vector<size_t> boundaryNodes;
};

EigenmodeData getEigenmode();
#endif /* Eigenmode_hpp */
