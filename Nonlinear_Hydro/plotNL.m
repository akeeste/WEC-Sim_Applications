% Plot NL hydro with fixed time-step and variable

clear all; close all; clc;
cases = 0:2;
lin={'-','-','-'};
lin2={'--','--','--'};
col = {'b','k','r'};

figure()
for i=1:length(cases)
    cd(['./nlHydro_',num2str(i-1,'%2g'),'/output'])
    load ellipsoid_matlabWorkspace.mat

    subplot(2,1,1)
    plot(output.bodies.time,output.bodies.position(:,3),[lin{i} col{i}])
    hold on
    title({'Nonlinear Hydro Comparison:','Ellipsoid in Heave'});
    ylabel('Displacement (m)');
%     xlabel('Time (s)');
    xlim([150 165]);
    
    subplot(2,1,2)
    plot(output.bodies.time,output.bodies.forceTotal(:,3),[lin{i} col{i}],...
        output.bodies.time,output.bodies.forceExcitation(:,3),[lin2{i} col{i}]);
    hold on
    ylabel('Force (N)');
    xlabel('Time (s)');
    xlim([150 165]);
    
    cd ../..
end

subplot(2,1,1)
legend('nlHydro=0',...
    'nlHydro=1',...
    'nlHydro=2');

subplot(2,1,2)
legend('nlHydro=0 Total Force',...
    'nlHydro=0 Excitation Force',...
    'nlHydro=1 Total Force',...
    'nlHydro=1 Excitation Force',...
    'nlHydro=2 Total Force',...
    'nlHydro=2 Excitation Force');
hold off

notes0 = ['nlHydro = 0 This option does not integrate pressure on '...
    'the body. The Froude-Krylov force from the BEM data is used.'];
notes1 = ['nlHydro = 1 This option integrates the pressure due to '...
    'the mean wave elevation and the instantaneous body position.'];
notes2 = ['nlHydro = 2 This option integrates the pressure due to '...
    'the instantaneous wave elevation and the instantaneous body position. '...
    'This option is recommended if nonlinear effects need to be considered.'];

disp(notes0);
disp(notes1);
disp(notes2);


