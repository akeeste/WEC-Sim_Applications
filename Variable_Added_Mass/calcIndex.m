function body2_hydroForceIndex = calcIndex(heaveVelocity, time, louverAngles)
% This function is called from Simulink at every time step 
% Depending on the velocity of the cube, the index for the hydrodynamics
% is determined

persistent prevVelocity prevChangeTime
transitionTime = 1; % (s), time for the flaps to open

if isempty(prevVelocity)
    % Initialize persistent variables. Assume that the ballast starts with
    % the louvers fully closed (time >> prevChangeTime)
    prevVelocity = +1;
    prevChangeTime = -transitionTime*2;
end

%% Boolean checks
velocityUp = heaveVelocity >= 0;

% This prevents a sign of '0' from needing consideration in the logic,
% treats 0 as a sign of +1
signPrevVelocity = sign(prevVelocity) + ~prevVelocity;
signVelocity = sign(heaveVelocity) + ~heaveVelocity;

% Check if velocity changes sign this time step
if signPrevVelocity ~= signVelocity
    prevChangeTime = time;
end

dt = time - prevChangeTime;

%% Define force ratios based on the logic
% 4 cases to consider:
% - Velocity upwards and has not recently changed sign (louvers closed)
% - Velocity downwards and has not recently changed sign (louvers open)
% - Velocity upwards and has recently changed sign (louvers closing)
% - Velocity downwards and has recently changed sign (louvers opening)
% 
% dtheta is the change in louver angle during a transition. It varies
% from 0 to 90 degrees over the transition time. For dt > transition time,
% dtheta maxes at 90.
% 
% NOTE: this transition won't capture the louvers if they start to close
% while still opening, or start to open while still closing. It assumes
% that the louvers only open/close from a fully closed/opened state. It is
% assumed that this is not a problem since transition time << wave period.
% 

% Select how the angle changes over the transition (linear or cosine)
% dtheta = dt/transitionTime * 90; % linear
dtheta = 90/2 * (1 + cos(pi + pi*dt/transitionTime)); % cosine
dtheta(dt >= transitionTime) = 90; % maximum change in angle of 90 degrees

% Calculate instantaneous louver angle
if velocityUp
    % Velocity upwards (louvers closing or closed)
    theta = 90 - dtheta;
elseif ~velocityUp
    % Velocity downwards (louvers opening or open)
    theta = 0 + dtheta;
else
    error('calcIndex: Error in velocity logic');
    theta = NaN;
end

% Convert angle to hydrodata index
[~, body2_hydroForceIndex] = min(abs(theta - louverAngles));

% Optional for debugging: uncomment this line to turn this function 'off' without changing simulink
% body2_hydroForceIndex = 1; % (theta = 0) louvers always closed

%% Assign a new value to previous velocity
prevVelocity = heaveVelocity;

end
