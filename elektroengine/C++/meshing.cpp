//
//  Hello.cpp
//  Simple C++ example file
//

#include "meshing.hpp"


void createRectangle() {
    gmsh::initialize();

    gmsh::model::occ::addRectangle(0, 0, 0, 3, 3);

    gmsh::model::occ::synchronize();

    gmsh::model::mesh::generate(2);

    gmsh::finalize();


}
std::vector<double> printHello() {
    gmsh::initialize();

    gmsh::model::add("t1");

    double lc = 1e-2;
    gmsh::model::geo::addPoint(0, 0, 0, lc, 1);


    gmsh::model::geo::addPoint(.1, 0, 0, lc, 2);
    gmsh::model::geo::addPoint(.1, .3, 0, lc, 3);


    int p4 = gmsh::model::geo::addPoint(0, .3, 0, lc);


    gmsh::model::geo::addLine(1, 2, 1);
    gmsh::model::geo::addLine(3, 2, 2);
    gmsh::model::geo::addLine(3, p4, 3);
    gmsh::model::geo::addLine(4, 1, p4);


    gmsh::model::geo::addCurveLoop({4, 1, -2, 3}, 1);


    gmsh::model::geo::addPlaneSurface({1}, 1);


    gmsh::model::geo::synchronize();


    gmsh::model::addPhysicalGroup(1, {1, 2, 4}, 5);
    gmsh::model::addPhysicalGroup(2, {1}, 6, "My surface");


    gmsh::model::mesh::generate(2);


    gmsh::write("t1.msh");



    std::vector<std::size_t> nodeTags;
    std::vector<double> coord;
    
    gmsh::model::mesh::getNodesForPhysicalGroup(2, 6, nodeTags, coord);

    // Reshape into n x 3 array (each row is [x, y, z])
    std::vector<std::vector<double>> points;
    for (size_t i = 0; i < coord.size(); i += 3) {
        points.push_back({coord[i], coord[i+1], coord[i+2]});
    }

    gmsh::finalize();

    // For now, return flattened coord - you'll need to update the header
    return coord;

}
MeshData getMeshPoints() {
    gmsh::initialize();
    gmsh::model::add("t1");

    double lc = 5e-1;
    gmsh::model::geo::addPoint(0, 0, 0, lc, 1);
    gmsh::model::geo::addPoint(10, 0, 0, lc, 2);
    gmsh::model::geo::addPoint(10, 10, 0, lc, 3);

    int p4 = gmsh::model::geo::addPoint(0, 10, 0, lc);

    gmsh::model::geo::addLine(1, 2, 1);
    gmsh::model::geo::addLine(3, 2, 2);
    gmsh::model::geo::addLine(3, p4, 3);
    gmsh::model::geo::addLine(4, 1, p4);

    gmsh::model::geo::addCurveLoop({4, 1, -2, 3}, 1);
    gmsh::model::geo::addPlaneSurface({1}, 1);
    gmsh::model::geo::synchronize();



    // Add physical group for top and bottom lines
    gmsh::model::addPhysicalGroup(1, {1}, 10);
    gmsh::model::addPhysicalGroup(1, {3}, 11);


    gmsh::option::setNumber("Mesh.SaveAll", 1);
    gmsh::model::mesh::generate(2);
    gmsh::write("t1.msh");



    std::vector<std::size_t> eTags;
    std::vector<std::size_t> nTags;


    gmsh::model::mesh::getElementsByType(2, eTags, nTags);

    std::vector<std::size_t> n_tag;
    std::vector<double> n_coord;
    std::vector<double> p_coord;

    gmsh::model::mesh::getNodes(n_tag, n_coord, p_coord);

    std::vector<std::size_t> physicalGroup1_nodes;
    std::vector<double> physicalGroup1_coords;


    gmsh::model::mesh::getNodesForPhysicalGroup(1, 10, physicalGroup1_nodes, physicalGroup1_coords);

    std::vector<std::size_t> physicalGroup2_nodes;
    std::vector<double> physicalGroup2_coords;
    gmsh::model::mesh::getNodesForPhysicalGroup(1, 11, physicalGroup2_nodes, physicalGroup2_coords);


    std::vector<std::vector<double>> n_cord;
    for (size_t i = 0; i < n_coord.size(); i += 3) {
        n_cord.push_back({n_coord[i], n_coord[i+1], n_coord[i+2]});
    }



    gmsh::finalize();

    MeshData data;
    data.eTags = eTags;
    data.nTags = nTags; //and this

    data.n_tag = n_tag;
    data.n_coord = n_coord;
    data.p_coord = p_coord;
    data.n_cord = n_cord; // Im using this

    data.physicalGroup1_nodes = physicalGroup1_nodes;
    data.physicalGroup1_coords = physicalGroup1_coords;
    data.physicalGroup2_nodes = physicalGroup2_nodes;
    data.physicalGroup2_coords = physicalGroup2_coords;
    return data;
}


