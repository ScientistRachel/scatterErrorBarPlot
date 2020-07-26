% This script provides examples of using scatterErrorBarPlot

clc
clear
close all

% First, make up some data for the example.  User inputs:
dataMeans = [1 0.5 2 2.1]; % Means for your bars
N = 10; % Number of data points
noiseSize = 0.5; % This factor scales the noise added by rand
% Create noisy data:
toPlot = repmat(dataMeans,[N,1]) + noiseSize*rand(N,size(dataMeans,2));

%% (1) Plot using all the default options in the function

figure(1)
scatterErrorBarPlot(toPlot)
% Examples of labeling this plot
set(gca,'FontSize',20) % Large font sizes help your readers!
set(gca,'XTick',1:size(dataMeans,2),'XTickLabel',{'A','B','C','D'}) % Label each bar
ylabel('Measurements','FontSize',20) % Large font sizes still good!
box off % box off creates less cluttered overall figure and is generally preferable
title({'Default Options','(95% Confidence Interval Error Bars)'},'FontSize',16)

% Save the example plot
saveas(gcf,['examplePlots' filesep 'DefaultOptions.png'],'png')

%% (2) Plot changing the options provided in the function

% The function can handle NaN values, which can be exploited to group data:
toPlot2 = [toPlot(:,1:2) NaN*toPlot(:,1) toPlot(:,3:4)];
% To have the second set of two bars look the same as the first set, make
% sure to specific 3 colors, markers, etc (to include the skipped bar).

% Set the optional values for the function
errorType = 'STD';
cmap = [0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250]; % These are the colors MATLAB uses in default plots
marker_size = 5;
marker_order = {'o','d','.'};
cmap_edge = 0.5*cmap;

figure(2)
scatterErrorBarPlot(toPlot2,errorType,cmap,marker_size,marker_order,cmap_edge)
% Examples of labeling this plot
set(gca,'FontSize',20) % Large font sizes help your readers!
set(gca,'XTick',[1.5 4.5],'XTickLabel',{'Before','After'}) % Label each bar
ylabel('Measurements','FontSize',20) % Large font sizes still good!
box off % box off creates less cluttered overall figure and is generally preferable
legend('Type A','Type B','Location','Northwest')
legend boxoff % boxoff provides a less cluttered look
xlim([0 6]) % Add a little spacing to make the figure look nice
title({'Changing the Plotting Options','(Standard Deviation Error Bars)'},'FontSize',16)

% Save the example plot
saveas(gcf,['examplePlots' filesep 'PlottingOptions.png'],'png')
