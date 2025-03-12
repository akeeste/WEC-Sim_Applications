%% Simulation Data
simu = simulationClass();               % Initialize Simulation Class
simu.simMechanicsFile = 'cube.slx';     % Specify Simulink Model File
simu.mode = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
simu.explorer = 'on';                   % Turn SimMechanics Explorer (on/off)
simu.startTime = 0;                     % Simulation Start Time [s]
simu.rampTime = 50;                     % Wave Ramp Time [s]
simu.endTime = 200;                     % Simulation End Time [s]
simu.solver = 'ode4';                   % simu.solver = 'ode4' for fixed step & simu.solver = 'ode45' for variable step 
simu.dt = 1e-3;                         % Simulation time-step [s]
simu.dtOut = 1e-2;
simu.cicEndTime = 20;
simu.cicDt = 1e-2;

%% Wave Information
% % noWave
% waves = waveClass('noWave');       % Initialize Wave Class and Specify Type  
% waves.period = 8;

% % noWaveCIC, no waves with radiation CIC
% waves = waveClass('noWaveCIC');       % Initialize Wave Class and Specify Type

% Regular Waves
waves = waveClass('regularCIC');           % Initialize Wave Class and Specify Type
waves.height = 2.5;                     % Wave Height [m]
waves.period = 8;                       % Wave Period [s]

% % Regular Waves with CIC
% waves = waveClass('regularCIC');          % Initialize Wave Class and Specify Type
% waves.height = 2.5;                       % Wave Height [m]
% waves.period = 8;                         % Wave Period [s]

% % Irregular Waves using PM Spectrum 
%  waves = waveClass('irregular');           % Initialize Wave Class and Specify Type
%  waves.height = 2.5;                       % Significant Wave Height [m]
%  waves.period = 8;                         % Peak Period [s]
%  waves.spectrumType = 'PM';                % Specify Wave Spectrum Type
%  waves.direction=[0];

% % Irregular Waves using JS Spectrum with Equal Energy and Seeded Phase
% waves = waveClass('irregular');           % Initialize Wave Class and Specify Type
% waves.height = 2.5;                       % Significant Wave Height [m]
% waves.period = 8;                         % Peak Period [s]
% waves.spectrumType = 'JS';                % Specify Wave Spectrum Type
% waves.bem.option = 'EqualEnergy';         % Uses 'EqualEnergy' bins (default) 
% waves.phaseSeed = 1;                      % Phase is seeded so eta is the same

% % Irregular Waves using PM Spectrum with Traditional and State Space 
% waves = waveClass('irregular');           % Initialize Wave Class and Specify Type
% waves.height = 2.5;                       % Significant Wave Height [m]
% waves.period = 8;                         % Peak Period [s]
% waves.spectrumType = 'PM';                % Specify Wave Spectrum Type
% simu.stateSpace = 1;                      % Turn on State Space
% waves.bem.option = 'Traditional';         % Uses 1000 frequnecies

waves.marker.location = [0 0]; % for visualization

%% Variable hydro
% 0 degrees = fully closed, 100 degrees = fully open
angles = 0:5:90;
hydroFiles = fullfile(strcat('hydroData/cube_', arrayfun(@num2str, angles, 'UniformOutput', 0), '.h5'));

%% Body Data
% Float
body(1) = bodyClass(hydroFiles); % Create the cube
body(1).geometryFile = 'geometry/cube.stl';         % Location of Geometry File
body(1).mass = 'equilibrium';                       % Body mass equal to the displaced water mass
body(1).inertia = [1e3 1e3 1e3];                    % Arbitrary approximation
body(1).variableHydro.option = 1;
body(1).variableHydro.hydroForceIndexInitial = 1;

% Viscous drag
cubeArea = pi/4*1^2;
cubeCd = 1.05;
for i = 1:length(angles)
    % Initialize drag arrays to the correct sizes
    body(1).quadDrag(i).drag = zeros(6);
    body(1).quadDrag(i).cd = zeros(1,6);
    body(1).quadDrag(i).area = zeros(1,6);

    % Define area and cd for each angle
    body(1).quadDrag(i).area = cubeArea * cosd(angles(i)) * [1 1 1 0 0 0];
    body(1).quadDrag(i).cd = cubeCd * [1 1 1 0 0 0];
end; clear i

%% PTO and Constraint Parameters
pto(1) = ptoClass('pto1');
pto(1).location = [0 0 -3];
pto(1).stiffness = 1e3;
pto(1).damping = 1e2;

% % Floating (3DOF) Joint
% constraint(1) = constraintClass('Constraint1');     % Initialize Constraint Class for Constraint1
% constraint(1).location = [0 0 0];                   % Constraint Location [m]
% 
% %% Mooring set-up
% mooring(1) = mooringClass('MooringMatrix1');
% mooring(1).matrix.stiffness(1, 1) = 1e4;
% mooring(1).matrix.stiffness(3, 3) = 1e4;
% mooring(1).matrix.stiffness(5, 5) = 1e5;
% mooring(1).matrix.damping(1, 1) = 1e2;
% mooring(1).matrix.damping(3, 3) = 1e2;
% mooring(1).matrix.damping(5, 5) = 1e3;


