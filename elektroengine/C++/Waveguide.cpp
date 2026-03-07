//
//  Waveguide.cpp
//  elektroengine
//
//  Created by Edvin Berling on 2026-03-06.
//

#include "Waveguide.hpp"
#include <cmath>

WaveguideMeshData createWaveguide() {
    float width = 20;
    float height = 3.5;
    float dielectricWidth = 5;
    float dielectricHeight = 1.75;
    float factor = 100;

    gmsh::initialize();
    gmsh::option::setNumber("General.Terminal", 0);

    // Create outer waveguide rectangle and inner dielectric rectangle
    gmsh::model::occ::addRectangle(-width / 2, 0, 0, width, height);
    gmsh::model::occ::addRectangle(-dielectricWidth / 2, 0, 0,
                                   dielectricWidth, dielectricHeight);

    // Fragment so the dielectric region is a separate surface sharing edges
    std::vector<std::pair<int, int>> ov;
    std::vector<std::vector<std::pair<int, int>>> ovv;
    gmsh::model::occ::fragment({{2, 1}}, {{2, 2}}, ov, ovv);
    gmsh::model::occ::synchronize();

    // ovv[0] = fragments of the first input  (outer rect → airbox piece + shared piece)
    // ovv[1] = fragments of the second input (inner rect → the dielectric surface)
    int dielectricSurface = ovv[1][0].second;

    // Find left and right boundary curves of the outer waveguide rectangle
    // Left boundary: x = -width/2, Right boundary: x = width/2
    std::vector<int> leftCurves, rightCurves;
    std::vector<std::pair<int, int>> allCurves;
    gmsh::model::getEntities(allCurves, 1);
    for (auto& [dim, tag] : allCurves) {
        double xmin, ymin, zmin, xmax, ymax, zmax;
        gmsh::model::getBoundingBox(dim, tag, xmin, ymin, zmin, xmax, ymax, zmax);
        // Vertical curve on the left edge
        if (std::abs(xmin - (-width / 2)) < 1e-6 && std::abs(xmax - (-width / 2)) < 1e-6) {
            leftCurves.push_back(tag);
        }
        // Vertical curve on the right edge
        if (std::abs(xmin - (width / 2)) < 1e-6 && std::abs(xmax - (width / 2)) < 1e-6) {
            rightCurves.push_back(tag);
        }
    }


    // Mesh settings
    gmsh::option::setNumber("Mesh.SaveAll", 1);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMin", width / factor);
    gmsh::option::setNumber("Mesh.CharacteristicLengthMax", width / factor);
    gmsh::model::mesh::generate(2);

    // --- Extract mesh data ---
    WaveguideMeshData data;

    // All nodes and coordinates
    std::vector<std::size_t> nodeTags;
    std::vector<double> coords, parametricCoords;
    gmsh::model::mesh::getNodes(nodeTags, coords, parametricCoords);

    for (std::size_t i = 0; i < coords.size(); i += 3) {
        data.allNodeCoords.push_back({coords[i], coords[i + 1], coords[i + 2]});
    }

    // All triangle elements
    gmsh::model::mesh::getElementsByType(2, data.allElementTags, data.allElementNodes);

    // Dielectric elements
    gmsh::model::mesh::getElementsByType(2, data.dielectricElementTags,
                                         data.dielectricElementNodes, dielectricSurface);

    

    // Left boundary line elements (type 1 = 2-node line) from each curve entity
    for (int cTag : leftCurves) {
        std::vector<std::size_t> eTags, eNodes;
        gmsh::model::mesh::getElementsByType(1, eTags, eNodes, cTag);
        data.leftBoundaryElementTags.insert(data.leftBoundaryElementTags.end(),
                                            eTags.begin(), eTags.end());
        data.leftBoundaryElementNodes.insert(data.leftBoundaryElementNodes.end(),
                                             eNodes.begin(), eNodes.end());
    }

    // Right boundary line elements
    for (int cTag : rightCurves) {
        std::vector<std::size_t> eTags, eNodes;
        gmsh::model::mesh::getElementsByType(1, eTags, eNodes, cTag);
        data.rightBoundaryElementTags.insert(data.rightBoundaryElementTags.end(),
                                             eTags.begin(), eTags.end());
        data.rightBoundaryElementNodes.insert(data.rightBoundaryElementNodes.end(),
                                              eNodes.begin(), eNodes.end());
    }

    gmsh::finalize();
    return data;
}
