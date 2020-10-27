% Run and Plot NL hydro with fixed time-step and variable

clear all; close all; clc;

cd(['./nlHydro_0'])
wecSim

cd(['../nlHydro_1'])
wecSim

cd(['../nlHydro_2'])
wecSim

cd ..

plotNL