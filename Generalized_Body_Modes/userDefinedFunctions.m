%Example of user input MATLAB file for post processing

%Plot waves
waves.plotEta(simu.rampTime);
try 
waves.plotSpectrum();
catch
end

%Plot surge response for body 1
output.plotResponse(1,1);

%Plot heave response for body 1
output.plotResponse(1,3);

%Plot heave forces for body 1
output.plotForces(1,3);

% GBM response
% Flex_out.signals.values(t/dt,40): 
% pos x 4, vel x 4, acc x 4, ftotal x 4, fex x 4, 
% frd x 4, fam x 4, fhs x 4, fdrag  x 4, fld x 4,
for i=1:4
    figure()
    plot(Flex_out.time, Flex_out.signals.values(:,i),'r',...
        Flex_out.time, Flex_out.signals.values(:,4+i),'b',...
        Flex_out.time, Flex_out.signals.values(:,8+i),'k');
    legend({'position','velocity','acceleration'});
    xlabel('Time (s)');
    ylabel('Response in (m) or (radians)');
    title(['body1(barge) GBM dof ' int2str(i) ' Response']);
end

figure()
i = 1;
plot(Flex_out.time, Flex_out.signals.values(:,12+i),...
    Flex_out.time, Flex_out.signals.values(:,16+i),...
    Flex_out.time, -Flex_out.signals.values(:,20+i),...
    Flex_out.time, -Flex_out.signals.values(:,24+i),...
    Flex_out.time, -Flex_out.signals.values(:,28+i),...
    Flex_out.time, -Flex_out.signals.values(:,32+i),...
    Flex_out.time, -Flex_out.signals.values(:,36+i));
legend('forceTotal','forceExcitation','forceRadiationDamping','forceAddedMass','forceRestoring','forceViscous','forceLinearDamping')
xlabel('Time (s)')
ylabel('Force (N) or Torque (N*m)')
    title(['body1(barge) GBM dof ' int2str(i) ' Forces']);

