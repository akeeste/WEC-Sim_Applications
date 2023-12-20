function [F_ExcitationNew, F_RadiationDampingNew, F_AddedMassNew] = hydrodynamicVariation(time, heaveVelocity, acceleration, mass, inertia, inertiaProducts, storedMass, storedInertia, storedInertiaProducts, F_Excitation, F_RadiationDamping, F_AddedMass)
% This function is called from Simulink at every time step.
% The device is nominally a fully submerged, hollow, open-top cube. The
% base of the cube is initially "closed" but may become "open" during
% simulation, changing the hydrodynamics.
% 
% If the cube is moving downwards and the base opens, this function can scale
% linear hydrodynamic forces accordingly.
% 
% In this example (excitation, radiation damping, added mass) are scaled
% based on a pre-determined ratio between the closed cube's and the
% open cube's respective BEM coefficients.
%    i.e. if V_z < 0
%            openForce = closedForce * openCoefficient/closedCoefficient
% 
% When a transition is detected, a cosinusoidal ramp is applied between the
% start and of the transition (e.g. starting at the closed cube and
% ending at the open cube)
% 
persistent prevVelocity prevChangeTime

% Initialize variables
F_ExcitationNew = zeros(6,1);
F_RadiationDampingNew = zeros(6,1);
F_AddedMassNew = zeros(6,1);
rampTime = 0.5; % Time it takes for the geometry to change shape

if isempty(prevVelocity)
    % Initialize persistent variables. Assume that the cube starts as half
    % open (time >> prevChangeTime)
    prevVelocity = +1;
    prevChangeTime = -rampTime*2;
end

%% Boolean checks
velocityUp = heaveVelocity >= 0;

% Simplifies the transition logic by lumping 0 velocities with positive
% velocities (treat sign(0) as +1)
signPrevVelocity = sign(prevVelocity) + ~prevVelocity;
signVelocity = sign(heaveVelocity) + ~heaveVelocity;

% Check if velocity changes sign this time step
if signPrevVelocity ~= signVelocity
    prevChangeTime = time;
end

%% Define force ratios based on the logic
% Define pre-determined ratios which will scale the forces.
closedRatio = [1 1 1 1 1 1];

% Ratios from BEM comparison. Calculated by comparing BEM coefficients for
% the ballast of the closed cube and the open cube in each DOF.
% excitationOpenRatio = [0.9  0.0  0.06  0.0  1.0  0];
% radiationOpenRatio  = [0.8  0.8  0.00  1.0  1.0  0];
% addedMassOpenRatio  = [0.9  0.9  0.01  0.9  0.9  0];

% % Simplified ratios:
excitationOpenRatio = [1 1 0 1 1 1];
radiationOpenRatio  = [1 1 0 1 1 1];
addedMassOpenRatio  = [1 1 0 1 1 1];

% 4 cases to consider:
% - Velocity upwards and has not recently changed sign (cube closed)
% - Velocity downwards and has not recently changed sign (cube open)
% - Velocity upwards and has recently changed sign (cube closing)
% - Velocity downwards and has recently changed sign (cube opening)
% 
% The ramp function =1 for time>rampTime, automatically handling whether a
% change is recent or not.
% 
% NOTE: This logic cannot capture if the cube's base has a new transition
% before completely closing or opening. This function
% assumes that the cube only opens/closes from a fully closed/opened state.
% This will not be a problem if transition time << wave period.
dt = time-prevChangeTime;
rampFunction = (1 + cos(pi+pi*dt/rampTime))/2;
rampFunction(dt >= rampTime) = 1;
rampFunction = rampFunction*ones(1,6);

% Optional: uncomment these two lines to turn this function 'off' without changing simulink
% velocityUp = true; % Cube always closed
% rampFunction = ones(1,6); % ramp always = 1

% Ramp function works like this:
% state = previousState + (newState-previousState)*rampFunction
% As dt >> rampTime, ramp --> 1 and state --> newState
% As dt << rampTime, ramp --> 0 and state --> previousState
if velocityUp
    % Velocity upwards (cube closing or closed)
    excitationRatio = excitationOpenRatio + (closedRatio-excitationOpenRatio).*rampFunction;
    radiationRatio =  radiationOpenRatio  + (closedRatio-radiationOpenRatio).*rampFunction;
    addedMassRatio =  addedMassOpenRatio  + (closedRatio-addedMassOpenRatio).*rampFunction;
elseif ~velocityUp
    % Velocity downwards (cube opening or open)
    excitationRatio = closedRatio + (excitationOpenRatio-closedRatio).*rampFunction;
    radiationRatio =  closedRatio + (radiationOpenRatio-closedRatio).*rampFunction;
    addedMassRatio =  closedRatio + (addedMassOpenRatio-closedRatio).*rampFunction;
else
    error('Error in hydrodynamicVariation: velocity logic check not working');
end

%% Adjust fAddedMass to account for added mass lumped into the mass matrix
% Get the special added mass components by defining the difference between
% the body's current mass matrix and the actual (stored) mass matrix
% NOTE: if using this method AFTER post-processing is complete, dMass has
% the negative of its definition here. 
dMass = zeros(6,6);
dMass(1,1) = mass - storedMass;
dMass(2,2) = mass - storedMass;
dMass(3,3) = mass - storedMass;
dMass(4,4) = inertia(1) - storedInertia(1);
dMass(5,5) = inertia(2) - storedInertia(2);
dMass(6,6) = inertia(3) - storedInertia(3);
dMass(4,5) = inertiaProducts(1) - storedInertiaProducts(1);
dMass(4,6) = inertiaProducts(2) - storedInertiaProducts(2);
dMass(5,6) = inertiaProducts(3) - storedInertiaProducts(3);
dMass(5,4) = -dMass(4,5);
dMass(6,4) = -dMass(4,6);
dMass(6,5) = -dMass(5,6);

F_AddedMass = F_AddedMass + ((acceleration')*dMass)';

%% Scale forces using the ratios
F_ExcitationNew = F_Excitation.*excitationRatio(:);
F_RadiationDampingNew = F_RadiationDamping.*radiationRatio(:);
F_AddedMassNew = F_AddedMass.*addedMassRatio(:);

% Move added mass back into the body mass as WEC-Sim intends during simulation
F_AddedMassNew = F_AddedMassNew - ((acceleration')*dMass)';

%% Assign a new value to previous velocity
prevVelocity = heaveVelocity;

end
