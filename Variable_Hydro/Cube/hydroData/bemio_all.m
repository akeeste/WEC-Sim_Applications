% Pick the case to run
angles = 0:10:90;
nAngles0 = length(angles);
angleInds = 1:nAngles0;

d = dir("cube_*/*.out");
folders = {d.folder};
files = {d.name};

%% Read all BEM data
allHydro = struct();
for i = 1:length(angles)
    % Read buoy output
    filename = fullfile(folders{i}, files{i});
    hydro = readWAMIT(struct(), filename, []);

    % Apply the same displaced volume to all meshes. This makes up for the
    % meshes being infinitely thin dipoles and ensures there are no
    % numerical differences between bodies of identical volume.
    cubeVolume = 5 * 3*3*0.025; % approximating 2.5 cm thick walls for a cube with 5 faces 
    hydro.Vo = cubeVolume;

    hydro = radiationIRF(hydro, 30, [], [], [], []);
    hydro = excitationIRF(hydro, 30, [], [], [], []);

    hydro.plotDofs = [3 3];
    hydro.plotBodies = [1];
    writeBEMIOH5(hydro);
    % plotBEMIO(hydro); % plot a single case

    if i == 1
        allHydro = hydro;
    else
        allHydro(i) = hydro;
    end
end

% plot all BEM cases together
% nHydro = length(allHydro);
% tmp = mat2cell(allHydro, 1, ones(1,nHydro));
% plotBEMIO(tmp{:});

%% interpolate BEM data to greater resolution as the louvers open
% Define hydro variables that need to be interpolated
vars = {'fk_re', 'fk_im', 'fk_ma', 'fk_ph', ...
          'sc_re', 'sc_im', 'sc_ma', 'sc_ph', ...
          'ex_re', 'ex_im', 'ex_ma', 'ex_ph', ...
          'A', 'Ainf', 'B', 'Khs', 'ra_K', 'ex_K'};

% Define new angles
newAngles = [0:5:90]; % new angle discretization
newAngles = setdiff(newAngles, angles); % remove values repeated in original BEM runs
angles(end+1:end+length(newAngles)) = newAngles;

% Append the interpolated direction and hydro structue to theta and
% allHydro respectively.
for i = nAngles0+1 : length(angles)
    ind1 = angleInds(angles(i) > angles(1:nAngles0));
    ind1 = ind1(end);

    ind2 = angleInds(angles(i) < angles(1:nAngles0));
    ind2 = ind2(1);

    allHydro(i) = allHydro(1);
    refStr = ['cube_' num2str(angles(i))];
    allHydro(i).file = refStr;
    allHydro(i).body = {refStr};

    dAngle = (angles(i) - angles(ind1)) / (angles(ind2) - angles(ind1)); % factor to linearly interpolate between louver angles
    for iVar = 1:length(vars)
        allHydro(i).(vars{iVar}) = allHydro(ind1).(vars{iVar}) * (1-dAngle) + ...
                                     allHydro(ind2).(vars{iVar}) * dAngle;
    end
end

% Sort theta and allHydro into the correct order based on frequency
[anglesSorted,iSorted] = sort(angles);
hydro_sorted = allHydro(iSorted);

% plot all BEM and interpolated cases together
nHydro = length(hydro_sorted);
tmp = mat2cell(hydro_sorted, 1, ones(1,nHydro));
plotBEMIO(tmp{:});

%% Write all data to h5 files
for i = 1:length(hydro_sorted)
    % writeBEMIOH5 is slow. Skip files that have already been written
    if ~isfile([hydro_sorted(i).file '.h5'])
        writeBEMIOH5(hydro_sorted(i));
    end
end

%% Visualize the IRF Surface
radIrfSurf = nan(size(hydro_sorted(1).ra_K, 3), 6, 6, length(anglesSorted));
for i = 1:length(hydro_sorted)
    radIrfSurf(:,:,:,i) = permute(hydro_sorted(i).ra_K, [3 1 2])*1000;
end

dofTitle = {'Surge','Sway','Heave','Roll','Pitch','Yaw'};
for dof = 3
    radSurf = squeeze(radIrfSurf(:,dof,dof,:));
    
    figure()
    contourf(anglesSorted, hydro_sorted(i).ra_t, radSurf);
    xlabel('Flag angle (deg)');
    ylabel('CIC Time (s); increasing backwards in time');
    colorbar
    title(['Radiation Impulse Response Function in ' dofTitle{dof} ' across the varying state']);
end
