#include "meshing.hpp"


CylinderMeshData createChargeCylinder() {
    float width = 10;
    float height = 10;
    float factor = 50;
    gmsh::initialize();
    gmsh::option::setNumber("General.Terminal", 0);

    gmsh::model::occ::addRectangle(-width/2, -height/2, 0, width, height);
    gmsh::model::occ::addDisk(0, 0, 0, width/10, height/10);

    // We apply a boolean difference to create the "cube minus one eighth" shape:
    vector<pair<int, int> > ov;
    vector<vector<pair<int, int> > > ovv;

    gmsh::model::occ::fragment({{2, 1}}, {{2, 2}}, ov, ovv);
    gmsh::model::occ::synchronize();

    // ovv[0] = what the rectangle became (includes both the airbox piece and the shared disk piece)
    // ovv[1] = what the disk became (the cylinder surface)
    int cylinderSurface = ovv[1][0].second;

    int airboxSurface = -1;
    for (auto& s : ovv[0]) {
        if (s.second != cylinderSurface) {
            airboxSurface = s.second;
            break;
        }
    }

    // Outer boundary curves: airbox boundary minus curves shared with cylinder
    vector<pair<int, int>> abBnd, cyBnd;
    gmsh::model::getBoundary({{2, airboxSurface}}, abBnd, false, false, false);
    gmsh::model::getBoundary({{2, cylinderSurface}}, cyBnd, false, false, false);

    vector<int> outerBoundaryCurves;
    for (auto& c : abBnd) {
        int cTag = abs(c.second);
        bool shared = false;
        for (auto& cc : cyBnd) {
            if (abs(cc.second) == cTag) { shared = true; break; }
        }
        if (!shared) outerBoundaryCurves.push_back(cTag);
    }

    int boundaryGroupTag = 102;
    gmsh::model::addPhysicalGroup(1, outerBoundaryCurves, boundaryGroupTag);

    gmsh::option::setNumber("Mesh.SaveAll", 1);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMin", width/factor);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMax", width/factor);

    gmsh::model::mesh::generate(2);

    CylinderMeshData data;

    // All nodes and coordinates
    vector<size_t> nodeTags;
    vector<double> coords, parametricCoords;
    gmsh::model::mesh::getNodes(nodeTags, coords, parametricCoords);
    data.allNodeTags = nodeTags;
    for (size_t i = 0; i < coords.size(); i += 3) {
        data.allNodeCoords.push_back({coords[i], coords[i+1], coords[i+2]});
    }

    // All triangle elements
    gmsh::model::mesh::getElementsByType(2, data.allElementTags, data.allNodeTags);

    // Disk elements: pass cylinderSurface as the entity tag

    gmsh::model::mesh::getElementsByType(2, data.cylinderElementTags, data.cylinderElementNodes, cylinderSurface);

    // Airbox elements: pass airboxSurface as the entity tag

    gmsh::model::mesh::getElementsByType(2, data.airboxElementTags, data.airboxElementNodes, airboxSurface);

    // Boundary nodes on the outer rectangle edges
    vector<double> boundaryCoords;
    gmsh::model::mesh::getNodesForPhysicalGroup(1, boundaryGroupTag, data.boundaryNodes, boundaryCoords);



    
    gmsh::finalize();
    return data;
}


