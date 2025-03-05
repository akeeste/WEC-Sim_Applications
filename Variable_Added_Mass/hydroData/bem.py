import numpy as np
import xarray as xr
import capytaine as cpt
import os as os


def umd(identifier, ballast_mesh_filename, directory):
    """
    University of Masschusetts Dartmouth RFTS 10.
    Task 3

    This function takes in ballast louver angle, loads meshes from CUBIT,
    and runs Capytaine for UMD's full 2-body case. Use iterative calls to
    this function to conduct a mesh resolution study, iterate over geometry
    parameters, or run a single case.

    Saves the Capytaine output and hydrostatic information to the specified
    directory

    Parameters
    ----------
    identifier: numeric
        Angle of louvers from 0 (closed) to 90 (completely open) [deg] or
        Percentage of the base's radius at which it is cut from 0 (closed) to 100 (completely open) [%]
    ballast_mesh_filename: string
        Identifies where to look for ballast meshes, corresponding to whether the identifier is an angle or percentage
    directory: string
        Path to the directory where the results and hydrostatic information are saved

    Returns
    -------
    dataset: xarray.Dataset
        Capytaine output

    """
    if not os.path.isdir(directory):
        os.mkdir(directory)

    # ####################################### MASS PROPERTIES #######################################
    # buoy_cg = np.asarray([0., 0., 0]) # TODO - Double check since used cg for analysis in Task 1.1 -0.195
    # buoy_mass = 390 # TODO - Buoy device mass for 1 m diameter 0.5 m draft buoy from Task 1.1

    pto_cg = np.asarray([0.0, 0.0, -30])  # Rounding from RFTS 6 award (was -53.007) -50
    pto_mass = 111.13  # from RFTS 6 award

    ballast_cg = np.asarray(
        [0.0, 0.0, -50]
    )  # Rounding from RFTS 6 award (was -83.5096)
    ballast_mass = 320  # Approximate

    pto_ballast_cg = (pto_cg * pto_mass + ballast_cg * ballast_mass) / (
        pto_mass + ballast_mass
    )

    # # ####################################### BUOY #######################################
    # # Create buoy symmetric meshes, cut at SWL.
    # # Capytaine wasn't clipping the SWL panels consistently without moving the
    # # top of the cylinder slightly above the SWL (+1e-10 m)
    # draft = 0.5 # m
    # diameter = 1.0 # m

    # buoy_mesh = cpt.mesh_vertical_cylinder(length=draft,
    #                                        radius=diameter/2.0,
    #                                        center=(0., 0., -draft/2.0+1e-10),
    #                                        resolution=(20, 40, 40),
    #                                        name="buoy")
    # buoy_mesh.keep_immersed_part(inplace=True)
    # buoy_mesh.clip(cpt.xOz_Plane, inplace=True)
    # buoy_mesh.clip(cpt.yOz_Plane, inplace=True)

    # # Create a symmetric mesh from 1/4 of the buoy
    # buoy_mesh = cpt.meshes.symmetric.ReflectionSymmetricMesh(buoy_mesh, cpt.xOz_Plane)
    # buoy_mesh = cpt.meshes.symmetric.ReflectionSymmetricMesh(buoy_mesh, cpt.yOz_Plane)

    # # Create the buoy from its mesh
    # buoy = cpt.FloatingBody(mesh=buoy_mesh,
    #                         center_of_mass=(0., 0., -0.195),
    #                         name="buoy")
    # buoy.rotation_center = buoy.center_of_mass # define for hydrostatics
    # buoy.add_translation_dof(name="Heave")

    # # buoy_mesh = cpt.io.mesh_loaders.load_mesh('../meshing/buoy.gdf',
    # #                                              file_format='gdf',
    # #                                              name='ballast')
    # # buoy_mesh.translate_z(buoy_cg[2]) # move mesh origin from CG to global origin (WAMIT convention to Capytaine convention)
    # # buoy_mesh.keep_immersed_part(inplace=True)

    # # # Create the buoy from its mesh
    # # buoy = cpt.FloatingBody(mesh=buoy_mesh,
    # #                         center_of_mass=buoy_cg,
    # #                         name="buoy")
    # # buoy.rotation_center = buoy.center_of_mass # define for hydrostatics
    # # buoy.add_translation_dof(name="Heave")

    # # Compute hydrostatics and write the output for BEMIO
    # buoy_hs = buoy.compute_hydrostatics(rho=1023, g=9.81)
    # write_hydrostatics(directory,
    #                    2,
    #                    0,
    #                    buoy_hs['hydrostatic_stiffness'],
    #                    buoy_hs['center_of_mass'],
    #                    buoy_hs['center_of_buoyancy'],
    #                    buoy_hs['disp_volume'])

    # ####################################### PTO/BALLAST #######################################
    pto_mesh = cpt.io.mesh_loaders.load_mesh(
        "../meshing/pto.gdf", file_format="gdf", name="pto"
    )
    pto_mesh.translate_z(
        pto_cg[2]
    )  # move mesh origin from CG to global origin (WAMIT convention to Capytaine convention)
    pto_mesh.keep_immersed_part(inplace=True)

    ballast_mesh = cpt.io.mesh_loaders.load_mesh(
        ballast_mesh_filename, file_format="gdf", name="ballast"
    )
    ballast_mesh.translate_z(
        ballast_cg[2]
    )  # move mesh origin from CG to global origin (WAMIT convention to Capytaine convention)
    ballast_mesh.keep_immersed_part(inplace=True)

    pto_ballast_mesh = pto_mesh[0][0] + ballast_mesh[0][0]

    pto_ballast_mesh = cpt.meshes.symmetric.ReflectionSymmetricMesh(
        pto_ballast_mesh, cpt.yOz_Plane
    )
    pto_ballast_mesh = cpt.meshes.symmetric.ReflectionSymmetricMesh(
        pto_ballast_mesh, cpt.xOz_Plane
    )

    # everything_mesh = pto_ballast_mesh[0][0] + buoy_mesh[0][0]
    # everything_mesh.show()

    pto_ballast = cpt.FloatingBody(
        mesh=pto_ballast_mesh, center_of_mass=pto_ballast_cg, name="pto_ballast"
    )
    pto_ballast.rotation_center = pto_ballast.center_of_mass  # define for hydrostatics
    pto_ballast.add_translation_dof(name="Heave")

    # Compute hydrostatics and write the output for BEMIO
    pto_ballast_hs = pto_ballast.compute_hydrostatics(rho=1023, g=9.81)
    write_hydrostatics(
        directory,
        1,
        0,
        pto_ballast_hs["hydrostatic_stiffness"],
        pto_ballast_hs["center_of_mass"],
        pto_ballast_hs["center_of_buoyancy"],
        pto_ballast_hs["disp_volume"],
    )

    # body_system = buoy + pto_ballast

    # ####################################### SIMULATION #######################################
    # # optionally uncomment to only visualize the mesh
    # pto_ballast.show()
    # return 0

    # Set-up hydrodynamic problems and solve
    problems = xr.Dataset(
        coords={
            "omega": np.linspace(0.05, 10, 200),
            "wave_direction": [0.0],
            "radiating_dof": list(pto_ballast.dofs),
            "water_depth": [np.infty],
        }
    )
    solver = cpt.BEMSolver()
    dataset = solver.fill_dataset(problems, pto_ballast)

    # add extras to the dataset
    dataset["center_of_mass"] = (
        ["rigid_body_component", "point_coordinates"],
        [body.center_of_mass for body in [pto_ballast]],
    )
    dataset["center_of_buoyancy"] = (
        ["rigid_body_component", "point_coordinates"],
        [body.center_of_buoyancy for body in [pto_ballast]],
    )
    dataset["volume"] = (
        ["rigid_body_component"],
        [body.volume for body in [pto_ballast]],
    )

    # Save dataset to .nc
    cpt.io.xarray.separate_complex_values(dataset).to_netcdf(
        directory + "/results.nc",
        encoding={"radiating_dof": {"dtype": "U"}, "influenced_dof": {"dtype": "U"}},
    )

    return dataset


def write_hydrostatics(directory, total_bodies, body_number, Khs_heave, cg, cb, volume):
    # Function adapted from WEC-Sim/examples/BEMIO/Capytaine/call_capytaine.py
    # This function takes in hydrostatic data and writes it in Nemoh's KH_1.dat
    # and Hydrostatics_1.dat format. Capytaine currently does not have the
    # ability to write hydrostatics to its output file
    #
    # NOTE: this function has been updated to assume that the input is heave only.
    # If 6x6 stiffness is input, remove lines 103-104 and set Khs=Khs_heave

    if total_bodies == 1:
        filename1 = directory + "/KH.dat"
        filename2 = directory + "/Hydrostatics.dat"
    else:
        filename1 = directory + f"/KH_{body_number}.dat"
        filename2 = directory + f"/Hydrostatics_{body_number}.dat"

    # Write hydrostatic stiffness to KH.dat file
    Khs = np.zeros([6, 6])
    # Khs[2][2] += Khs_heave # set khs[2,2] = 0
    np.savetxt(filename1, Khs)

    # Write the other hydrostatics data to Hydrostatics.dat file
    f = open(filename2, "w")
    for j in [0, 1, 2]:
        line = f"XF = {cb[j]:7.3f} - XG = {cg[j]:7.3f} \n"
        f.write(line)
    line = f"Displacement = {volume:E}"
    f.write(line)
    f.close()
