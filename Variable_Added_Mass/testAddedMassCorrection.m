% Test the force manipulation offline. Run a WEC-Sim case without
% any custom added mass changes. 
% Run this script to view:
%    - the actual applied added mass force
%    - the intended ('goal') added mass force (f_{am} * a)
%    - the intend force calculated using the actual applied force (calculated)

forceApplied = -body(3).hydroForce.storage.output_forceAddedMass(:,3);
forceGoal = -output.bodies(3).forceAddedMass(:,3);
time = output.bodies(3).time;

dMass = zeros(6,6);
dMass(1,1) = body(3).mass - body(3).hydroForce.storage.mass;
dMass(2,2) = body(3).mass - body(3).hydroForce.storage.mass;
dMass(3,3) = body(3).mass - body(3).hydroForce.storage.mass;
dMass(4,4) = body(3).inertia(1) - body(3).hydroForce.storage.inertia(1);
dMass(5,5) = body(3).inertia(2) - body(3).hydroForce.storage.inertia(2);
dMass(6,6) = body(3).inertia(3) - body(3).hydroForce.storage.inertia(3);
dMass(4,5) = body(3).inertiaProducts(1) - body(3).hydroForce.storage.inertiaProducts(1);
dMass(4,6) = body(3).inertiaProducts(2) - body(3).hydroForce.storage.inertiaProducts(2);
dMass(5,6) = body(3).inertiaProducts(3) - body(3).hydroForce.storage.inertiaProducts(3);
dMass = -dMass;
newComponent = -output.bodies(3).acceleration*dMass;
forceCalculated = forceApplied + newComponent(:,3);

figure()
plot(time,forceGoal,time,forceApplied,time,forceCalculated,'--');
xlabel('Time (s)');
ylabel('Force (N)');
legend('f_{am}*a [goal]','applied','manipulated applied force');
title('Added mass heave force comparison');
