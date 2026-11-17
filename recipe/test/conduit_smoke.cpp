// Smoke test: Conduit nodes, a Blueprint example mesh, and an HDF5 round
// trip through Relay.
#include <conduit.hpp>
#include <conduit_blueprint.hpp>
#include <conduit_relay.hpp>

#include <iostream>

int main()
{
    conduit::Node mesh;
    conduit::blueprint::mesh::examples::braid("hexs", 3, 3, 3, mesh);

    conduit::Node info;
    if(!conduit::blueprint::mesh::verify(mesh, info))
    {
        info.print();
        return 1;
    }

    conduit::relay::io::save(mesh, "conduit_smoke.hdf5", "hdf5");
    conduit::Node loaded;
    conduit::relay::io::load("conduit_smoke.hdf5", "hdf5", loaded);
    if(mesh.diff(loaded, info))
    {
        info.print();
        return 1;
    }

    std::cout << "conduit " << CONDUIT_VERSION << " smoke test passed" << std::endl;
    return 0;
}
