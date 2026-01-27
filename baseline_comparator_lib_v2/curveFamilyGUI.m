function curveFamilyGUI(curveFamilies, indexorName, plotTitle,Xtitle,Ytitle,plotPosition)
% CURVEFAMILYGUI - Interactive GUI to compare families of curves with custom indices
%
% Usage: 
%   curveFamilyGUI(curveFamilies, familyNames)
%
% Inputs:
%   curveFamilies       - struct array containing the name, curves, and indexor
%                   vector
%   indexorName         - strings for the name of the indexor
%   displayMarkerLabel  - boolean for showing frequency markers on the EIS
%   data
%
% Example:
%   % Generate sample data with custom indices
%   x = linspace(0, 2*pi, 100);
%   
%   % Family 1: curves at indices [10, 15, 22.5, 30]
%   curves1 = cell(4,1);
%   indices1 = [10, 15, 22.5, 30];
%   for i = 1:4
%       curves1{i} = [x', sin(indices1(i)/5 * x')];
%   end
%   family1 = {curves1, indices1};
%   
%   % Family 2: curves at indices [12, 18, 25, 28.7]  
%   curves2 = cell(4,1);
%   indices2 = [12, 18, 25, 28.7];
%   for i = 1:4
%       curves2{i} = [x', cos(indices2(i)/8 * x')];
%   end
%   family2 = {curves2, indices2};
%   
%   curveFamilyGUI({family1, family2}, {'Sine Family', 'Cosine Family'});

% Validate inputs
numFamilies = length(curveFamilies);
if numFamilies == 0
    error('At least one curve family must be provided');
end

% Validate family structure and extract all indices
allIndices = [];
for i = 1:numFamilies
    
    curves = curveFamilies(i).curves;
    indices = curveFamilies(i).indexor;
    
    if length(curves) ~= length(indices)
        error('Number of curves must match number of indices in family %d', i);
    end
    
    % Check that indices are monotonically increasing
    if any(diff(indices) <= 0)
        error('Indices must be strictly increasing in family %d', i);
    end
    
    allIndices = [allIndices; indices(:)];
end

% Determine slider range
minIndex = min(allIndices);
maxIndex = max(allIndices);
uniqueIndices = sort(unique(allIndices));

% Create main figure
fig = uifigure('Name', 'Curve Family Comparison (Custom Indices)', 'Position', plotPosition);

% Create UI components
% Main axes for plotting
ax = uiaxes(fig, 'Position', [50 150 500 400]);
title(ax, 'Curve Family Comparison');
xlabel(ax, Xtitle);
ylabel(ax, Ytitle);
grid(ax, 'on');

% Slider for curve index selection
sliderLabel = uilabel(fig, 'Position', [570 520 120 22], 'Text', indexorName);
slider = uislider(fig, 'Position', [570 500 200 3], ...
    'Limits', [minIndex maxIndex], 'Value', uniqueIndices(1), ...
    'MajorTicks', round(uniqueIndices(1:max(1,floor(length(uniqueIndices)/10)):end),2,'significant'), ...
    'ValueChangedFcn', @updatePlot);

sliderValueLabel = uilabel(fig, 'Position', [680 520 80 22], 'Text', sprintf('%.2f', uniqueIndices(1)));

% Index navigation buttons
prevBtn = uibutton(fig, 'Position', [570 450 45 25], ...
    'Text', '◀', 'ButtonPushedFcn', @prevIndex);
nextBtn = uibutton(fig, 'Position', [620 450 45 25], ...
    'Text', '▶', 'ButtonPushedFcn', @nextIndex);
exactBtn = uibutton(fig, 'Position', [670 450 100 25], ...
    'Text', 'Exact Indices', 'ButtonPushedFcn', @snapToExact);

% Checkboxes for family selection
checkboxPanel = uipanel(fig, 'Position', [570 150 200 260], 'Title', 'Select Families');

checkboxes = cell(numFamilies, 1);
colors = lines(numFamilies); % Generate distinct colors

for i = 1:numFamilies
    yPos = 220 - i * 30;
    checkboxes{i} = uicheckbox(checkboxPanel, ...
        'Position', [10 yPos 180 22], ...
        'Text', curveFamilies(i).name, ...
        'Value', true, ...
        'ValueChangedFcn', @updatePlot);
end

% Control buttons
clearBtn = uibutton(fig, 'Position', [570 100 80 30], ...
    'Text', 'Clear All', 'ButtonPushedFcn', @clearAll);

selectAllBtn = uibutton(fig, 'Position', [660 100 80 30], ...
    'Text', 'Select All', 'ButtonPushedFcn', @selectAll);

% Legend toggle
legendBtn = uibutton(fig, 'Position', [570 60 170 30], ...
    'Text', 'Toggle Legend', 'ButtonPushedFcn', @toggleLegend);

frequBtn = uibutton(fig, 'Position', [570 20 170 30], ...
    'Text', 'Toggle Frequency Markers', 'ButtonPushedFcn', @toggleMarkers);

% Store data in figure UserData
figData.curveFamilies = curveFamilies;
figData.colors = colors;
figData.showLegend = true;
figData.showMarkers = true;
figData.uniqueIndices = uniqueIndices;
fig.UserData = figData;

% Initial plot
updatePlot();

    function updatePlot(~, ~)
        % Get current slider value
        currentIndex = slider.Value;
        sliderValueLabel.Text = sprintf('%.2f', currentIndex);
        
        % Clear axes
        cla(ax);
        hold(ax, 'on');
        n_markers = 1;
        % Get figure data
        data = fig.UserData;
        
        % Calculate axis limits for all selected families
        [xlims, ylims] = calculateAxisLimits(data);
        [xlims, ylims] = nice_axis_limits(xlims, ylims);
        
        % Plot selected families
        legendEntries = {};
        legendHandles = [];
        
        for fam = 1:numFamilies
            if checkboxes{fam}.Value
                % Find closest curve index in this family
                familyCurves = data.curveFamilies(fam).curves;
                familyIndices = data.curveFamilies(fam).indexor;
                
                % Find the curve with index closest to current slider value
                [~, closestIdx] = min(abs(familyIndices - currentIndex));
                
                % Only plot if the closest index is reasonably close (within 10% of range)
                indexRange = max(familyIndices) - min(familyIndices);
                tolerance = indexRange * 0.1;
                
                if abs(familyIndices(closestIdx) - currentIndex) <= tolerance ||...
                        isscalar(familyIndices)
                    curveData = familyCurves{closestIdx};
                    actualIndex = familyIndices(closestIdx);
                    
                    h = plot(ax, curveData(:,2), curveData(:,3),'+-', ...
                        'Color', data.colors(fam,:),'LineWidth', 1);
                    
                    if data.showMarkers
                        for j = 1:n_markers:length(curveData)
                            text(ax,curveData(j,2),...
                                curveData(j,3),sprintf('%.2f Hz',...
                                curveData(j,1)),"FontSize",10);
                        end
                    end

                    legendHandles(end+1) = h;
                    legendEntries{end+1} = sprintf('%s (%s: %.2f)',...
                        data.curveFamilies(fam).name, indexorName, actualIndex);
                end
            end
        end
        
        % Set consistent axis limits
        if ~isempty(xlims) && ~isempty(ylims)
            xlim(ax, xlims);
            ylim(ax, ylims);
        end
        
        % Add legend if requested and there are curves to show
        if data.showLegend && ~isempty(legendHandles)
            legend(ax, legendHandles, legendEntries, 'Location', 'East');
        else
            legend(ax,'off');
        end
        
        hold(ax, 'off');
        grid(ax, 'on');
        box(ax,'on')
        set(ax, 'YDir','reverse')
        title(ax, plotTitle);
        drawnow
        pause(0.01)
    end

    function [xlims, ylims] = calculateAxisLimits(data)
        % Calculate optimal axis limits for all selected families
        all_x = [];
        all_y = [];
        if numFamilies>0
        % Collect all x and y values from selected families
        for fam = 1:numFamilies
            if checkboxes{fam}.Value
                familyCurves = data.curveFamilies(fam).curves;
                
                for curveIdx = 1:length(familyCurves)
                    curveData = familyCurves{curveIdx};
                    
                    all_x = [all_x; curveData(:,2)];
                    all_y = [all_y; curveData(:,3)];
                end
            end
        end
        end
        
        % Calculate limits with padding
        if ~isempty(all_x) && ~isempty(all_y)
            x_range = max(all_x) - min(all_x);
            y_range = max(all_y) - min(all_y);
            
            % Add 5% padding on each side to avoid awkward cropping
            x_padding = x_range * 0.05;
            y_padding = y_range * 0.05;
            
            xlims = [min(all_x) - x_padding, max(all_x) + x_padding];
            ylims = [min(all_y) - y_padding, max(all_y) + y_padding];
            
            % Handle edge cases where range is zero
            if x_range == 0
                xlims = [min(all_x) - 0.5, max(all_x) + 0.5];
            end
            if y_range == 0
                ylims = [min(all_y) - 0.5, max(all_y) + 0.5];
            end
        else
            xlims = [];
            ylims = [];
        end
    end

    function prevIndex(~, ~)
        data = fig.UserData;
        currentIndex = slider.Value;
        
        % Find previous unique index
        validIndices = data.uniqueIndices(data.uniqueIndices < currentIndex);
        if ~isempty(validIndices)
            slider.Value = max(validIndices);
            updatePlot();
        end
    end

    function nextIndex(~, ~)
        data = fig.UserData;
        currentIndex = slider.Value;
        
        % Find next unique index
        validIndices = data.uniqueIndices(data.uniqueIndices > currentIndex);
        if ~isempty(validIndices)
            slider.Value = min(validIndices);
            updatePlot();
        end
    end

    function snapToExact(~, ~)
        data = fig.UserData;
        currentIndex = slider.Value;
        
        % Snap to nearest exact index
        [~, nearestIdx] = min(abs(data.uniqueIndices - currentIndex));
        slider.Value = data.uniqueIndices(nearestIdx);
        updatePlot();
    end

    function clearAll(~, ~)
        for i = 1:numFamilies
            checkboxes{i}.Value = false;
        end
        updatePlot();
    end

    function selectAll(~, ~)
        for i = 1:numFamilies
            checkboxes{i}.Value = true;
        end
        updatePlot();
    end

    function toggleLegend(~, ~)
        data = fig.UserData;
        data.showLegend = ~data.showLegend;
        fig.UserData = data;
        updatePlot();
    end

    function toggleMarkers(~, ~)
        data = fig.UserData;
        data.showMarkers = ~data.showMarkers;
        fig.UserData = data;
        updatePlot();
    end

end