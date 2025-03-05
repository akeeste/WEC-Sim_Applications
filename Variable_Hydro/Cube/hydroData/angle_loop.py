import umd as umd
import numpy as np

##### Loop through geometries with angled louvers #####
angles = np.linspace(0, 90, 7, dtype='int')
# angles = [0]

for angle in angles:
    directory = f"angleBP={angle}"
    meshFile = f"../meshing/ballast_angled/ballast_angled{angle}.gdf"
    dataset = umd.umd(angle,
                      meshFile,
                      directory,
                      )a