function scatterErrorBarPlot(A,errorType,cmap,marker_size,marker_order,cmap_edge)
% USAGE: scatterErrorBarPlot(A,errorType,cmap,marker_size,marker_order,cmap_edge)
%
% REQUIRED INPUT:
% A             m x n matrix.  Will plot n bars with m scattered data points
%
% OPTIONAL INPUTS:
% errorType     Type of displayed error bars. Default is 95% confidence intervals.
%               Choices: 'STD' (standard deviation),'SEM' (standard error
%               of the mean), '95CI' (95% confidence intervals), and
%               'STDratio', 'SEMratio','95CIratio' (log corrected error bars).
%               Important note: these are independent, not joint, 95%
%               confidence intervals.
% cmap          b x 3 matrix of rgb colors (values between 0 and 1) for bars.
%               Defaults to color blind friendly colormap.  Colormap
%               repeats if b < n.
% marker_size   Size of plotted markers. Default  10.
% marker_order  Symbols to use for markers.
%               Default repeats the sequence {'o','s','^','v','d'}.
% cmap_edge     b x 3 matrix of rgb colors for bar edges. Default = cmap;

%%%%%%%
% Change Log
% 2016/07/19 RML - created function
% 2016/07/20 RML - more flexibility with different sized matrices and pairs colors
% 2016/08/03 RML - choose color
% 2016/09/08 RML - use nanmean, nanstd
% 2017/01/13 RML - choose between paired colors or unique colors
% 2018/02/28 RML - edges can be different than bar center, thicker linewidth
% 2018/07/20 RML - show error bars even if not paired
% 2019/11/15 RML - can handle NaN columns now
% 2020/05/29 RML - no longer requires dependent functions
% 2020/07/02 RML - add flexibility in choosing error bar types, remove
%                  paired colors (now covered by colormap options)
% 2020/07/26 RML - convert from nanmean/nanstd to 'omitnan' to remove
%                  statistical toolbox dependency.
% 2020/08/01 RML - make ratio error bars work with NaNs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%% Load default parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Data Points
jitter = 0.3; % Hard coded parameter for scatter in data points
% Marker Size
if ~exist('marker_size','var') || isempty(marker_size)
    marker_size = 10;
end
% Marker Order
if ~exist('marker_order','var') || isempty(marker_order)
    marker_order = repmat({'o','s','^','v','d'},[1 ceil(size(A,2)/5)]);
elseif length(marker_order) < size(A,2)
    marker_order = repmat(marker_order,[1 ceil(size(A,2)/length(marker_order))]);
end

%%% Bar Plot Colormaps
% Main Colormap
if ~exist('cmap','var') || isempty(cmap)
    % This color map is based on a Nature Methods paper:
    % doi:10.1038/nmeth.1618 (See Figure 2)
    cmap = [0.6       0.6       0.6
            0.9020    0.6235    0
            0.3373    0.7059    0.9137
            0         0.6196    0.4510
            0.9412    0.8941    0.2588
            0         0.4471    0.6980
            0.8353    0.3686    0
            0.8000    0.4745    0.6549];
end
if length(cmap) < size(A,2)
    warning('Color map will repeat to accomodate data')
    repnum = ceil(size(A,2)/size(cmap,1));
    cmap = repmat(cmap,[repnum, 1]);
end
% Bar Edges
if ~exist('cmap_edge','var') || isempty(cmap_edge)
    cmap_edge = cmap;
end
if length(cmap_edge) < size(A,2)
    warning('Edge color map will repeat to accomodate data')
    repnum = ceil(size(A,2)/size(cmap_edge,1));
    cmap_edge = repmat(cmap_edge,[repnum, 1]);
end

%%% Errorbars
if ~exist('errorType','var') || isempty(errorType)
    errorType = '95CI';
end
typeCheck = strcmp(errorType,{'95CI','STD','SEM','95CIratio','STDratio','SEMratio'});
if sum(typeCheck) == 0
    error('Please enter a valid error bar type: ''95CI'',''STD'',''SEM'',''95CIratio'',''STDratio'',''SEMratio''')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Make the bars
for kk = 1:size(A,2)

    slice = A(:,kk);
    bar(kk,mean(slice,'omitnan'),'FaceColor',cmap(kk,:),'EdgeColor',cmap_edge(kk,:),'linewidth',2)
    
    if kk == 1
        hold on
    end

end

%%%%%% Plot the data points
for kk = 1:size(A,2)
    
    xslice = repmat(kk,[size(A,1) 1]);
    yslice = A(:,kk);
    
    J = (rand(size(xslice))-0.5)*jitter;
    
    plot(xslice+J,yslice,'k',...
        'Marker',marker_order{kk},'LineStyle','none',...
        'MarkerFaceColor','k',...
        'MarkerSize',marker_size)
    
end

%%%%%% Add the errorbars
if strcmp(errorType,'STD') % Standard Deviation Error Bars
    
    for kk = 1:size(A,2) 

        slice = A(:,kk);
        barVal = std(slice,'omitnan');        
        errorbar([kk -8],[mean(slice,'omitnan') 0],[barVal 0],'.k','LineWidth',2,'Marker','none') % The value at -8 is a silly way to get wider error bars

    end
    
elseif strcmp(errorType,'SEM') % Standard Error of the Mean Error Bars
    
    for kk = 1:size(A,2) 

        slice = A(:,kk);
        N = numel(find(~isnan(slice)));
        barVal = std(slice,'omitnan')/sqrt(N);        
        errorbar([kk -8],[mean(slice,'omitnan') 0],[barVal 0],'.k','LineWidth',2,'Marker','none') % The value at -8 is a silly way to get wider error bars

    end
    
elseif strcmp(errorType,'95CI') % 95% CI Error Bars
    
    for kk = 1:size(A,2) 

        slice = A(:,kk);
        N = numel(find(~isnan(slice)));
        t_star = tinv(1-0.05/2,N-1);
        barVal = t_star*std(slice,'omitnan')/sqrt(N);        
        errorbar([kk -8],[mean(slice,'omitnan') 0],[barVal 0],'.k','LineWidth',2,'Marker','none') % The value at -8 is a silly way to get wider error bars

    end
    
elseif strcmp(errorType,'STDratio') % STD Error Bars for Ratio Values
    
    for kk = 1:size(A,2) 

        slice = A(:,kk);
        slice(isnan(slice)) = [];
        if sum(slice==0)
            warning('log(0) = -Inf. Error bars will not display')
        end
        
        sliceLog = log(slice);
        stdLog = std(sliceLog);
        meanLog = mean(sliceLog);
        upLog = meanLog + stdLog;
        lowLog = meanLog - stdLog;
        upperB = exp(upLog) - mean(slice,'omitnan');
        lowerB = exp(lowLog) - mean(slice,'omitnan');        
        
        errorbar([kk -8],[mean(slice,'omitnan') 0],[lowerB 0],[upperB 0],'.k','LineWidth',2,'Marker','none') % The value at -8 is a silly way to get wider error bars

    end
    
elseif strcmp(errorType,'SEMratio') % SEM Error Bars for Ratio Values
    
    for kk = 1:size(A,2) 

        slice = A(:,kk);
        slice(isnan(slice)) = [];
        if sum(slice==0)
            warning('log(0) = -Inf. Error bars will not display')
        end
        
        sliceLog = log(slice);
        N = numel(find(~isnan(slice)));
        
        stdLog = std(sliceLog);        
        meanLog = mean(sliceLog);
        
        upLog = meanLog + stdLog/sqrt(N);
        lowLog = meanLog - stdLog/sqrt(N);
        
        upperB = exp(upLog) - mean(slice,'omitnan');
        lowerB = exp(lowLog) - mean(slice,'omitnan');        
        
        errorbar([kk -8],[mean(slice,'omitnan') 0],[lowerB 0],[upperB 0],'.k','LineWidth',2,'Marker','none') % The value at -8 is a silly way to get wider error bars

    end
    
elseif strcmp(errorType,'95CIratio') % 95% CI Error Bars for Ratio Values
    
    for kk = 1:size(A,2) 

        slice = A(:,kk);
        slice(isnan(slice)) = [];
        if sum(slice==0)
            warning('log(0) = -Inf. Error bars will not display')
        end
        
        sliceLog = log(slice);
        N = numel(find(~isnan(slice)));
        t_star = tinv(1-0.05/2,N-1);
        
        stdLog = std(sliceLog);
        meanLog = mean(sliceLog);
        
        upLog = meanLog + stdLog/sqrt(N)*t_star;
        lowLog = meanLog - stdLog/sqrt(N)*t_star;
        
        upperB = exp(upLog) - mean(slice,'omitnan');
        lowerB = exp(lowLog) - mean(slice,'omitnan');        
        
        errorbar([kk -8],[mean(slice,'omitnan') 0],[lowerB 0],[upperB 0],'.k','LineWidth',2,'Marker','none') % The value at -8 is a silly way to get wider error bars

    end
    
end

hold off

%%%%%% Set the x-axis limits
a = size(A,2);
xlim([0 a]+.5)
box off