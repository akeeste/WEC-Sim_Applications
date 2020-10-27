% Plot NL hydro with fixed time-step and variable

clear all; close all; clc;

cd(['./nlHydro_0/output'])
    load ellipsoid_matlabWorkspace.mat
    nl_0.time = output.bodies.time;
    nl_0.pos = output.bodies.position(:,3);

cd(['../../nlHydro_1/output'])
    load ellipsoid_matlabWorkspace.mat
    nl_1.time = output.bodies.time;
    nl_1.pos = output.bodies.position(:,3);

cd(['../../nlHydro_2/output'])
    load ellipsoid_matlabWorkspace.mat
    nl_2.time = output.bodies.time;
    nl_2.pos = output.bodies.position(:,3);

cd ../..

figure
    f = gcf;
    f.Position = [1 38.3333 1280 610];
    lin={'-','-','-'};
    col = {'b','k','r'};
    
    plot(nl_0.time,nl_0.pos,...
        'linestyle',lin{1},'color',col{1})
    hold on
    
    plot(nl_1.time,nl_1.pos,...
        'linestyle',lin{2},'color',col{2})
    hold on
    
    plot(nl_2.time,nl_2.pos,...
        'linestyle',lin{3},'color',col{3})
    hold on
    
    title('Ellipsoid Heave Displacement')
    ylabel('displacement (m)')    
    legend('Linear hydrodynamic body (simu.nlHydro=0)',...
        'Nonlinear hydrodynamic body (simu.nlHydro=1)',...
        'Nonlinear hydrodynamic body (simu.nlHydro=2)',...
        'Location','northeast','Orientation','horizontal')        
     