% BEMIO script to process and compare data for the half-open and fully-open cubes
% Fully open cube (top and bottom open and submerged)
hydro_full = struct();
hydro_full = readWAMIT(hydro_full, 'fully_open_cube/fully_open_cube.out',[]);
hydro_full = radiationIRF(hydro_full, 20, [], [], [], 20);
hydro_full = excitationIRF(hydro_full, [], [], [], [], 20);
writeBEMIOH5(hydro_full);

% Use the BEMIO fix function to prevent issues with the heave radiation
% damping in this simplified case. This should not be typical practice, but
% is used here so that the variable hydrodynamics can be showcased effectively
hydro_half = badBemioFix_fcn({'half_open_cube/half_open_cube.out'},'WAMIT',[],[1 1; 3 3; 5 5]);

% hydro_half = struct();
% hydro_half = readWAMIT(hydro_half, 'half_open_cube/half_open_cube.out',[]);
% hydro_half = radiationIRF(hydro_half, 20, [], [], [], 20);
% hydro_half = excitationIRF(hydro_half, [], [], [], [], 20);
% writeBEMIOH5(hydro_half);

% Compare the cases together
plotBEMIO(hydro_half,hydro_full);

%% Calculate ratio of the hydrodata
ratio.A = diag(mean(hydro_full.A./hydro_half.A,3));
ratio.B = diag(mean(hydro_full.B./hydro_half.B,3));
ratio.ex_ma = mean(hydro_full.ex_ma./hydro_half.ex_ma,3);


