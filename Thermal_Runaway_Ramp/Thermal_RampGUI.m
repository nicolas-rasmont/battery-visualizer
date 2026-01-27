function Thermal_RampGUI(thermalData, plotTitle,xaxisTitle,plotPosition)
% CHARGEGUI - Interactive GUI to compare charge/discharge curves
%
% Usage: 
%   chargeGUI(thermalData, plotTitle)
%
% Inputs:
%   thermalData - struct array containing charge data with fields:
%                .name - string name for the charge
%                .charge - struct with fields Time_s, Voltage_V, Current_A
%   plotTitle  - string for plot title

% Validate inputs
numCharges = length(thermalData);
if numCharges == 0
    error('At least one thermal dataset must be provided');
end

% Create main figure
fig = uifigure('Name', 'Thermal Ramp Comparison', 'Position', plotPosition);

% Create UI components
% Main axes for plotting
ax = uiaxes(fig, 'Position', [50 150 500 400]);
title(ax, 'Thermal Ramp Comparison');
grid(ax, 'on');

% Checkboxes for family selection
checkboxPanel = uipanel(fig, 'Position',[570 150 200 260], 'Title', 'Select Datasets');

checkboxes = cell(numCharges, 1);
colors = lines(numCharges); % Generate distinct colors

for jCharge = 1:numCharges
    yPos = 220 - jCharge * 30;
    checkboxes{jCharge} = uicheckbox(checkboxPanel, ...
        'Position', [10 yPos 180 22], ...
        'Text', thermalData(jCharge).name, ...
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

% Store data in figure UserData
figData.ThermalData = thermalData;
figData.colors = colors;
figData.showLegend = true;
figData.showMarkers = true;
fig.UserData = figData;

% Initial plot
updatePlot();

    function updatePlot(~, ~)
        % Clear axes
        cla(ax);
        
        % Get figure data
        data = fig.UserData;
        curveData = data.ThermalData;

        
        % Plot selected families
        legendEntries = {};
        legendHandles = [];
        
        % Check if any datasets are selected
        anySelected = any(cellfun(@(cb) cb.Value, checkboxes));

        % Clear the axe properly
        cla(ax);

        if ~anySelected
            % Clear plot if nothing selected
            title(ax, plotTitle);
            xlabel(ax, xaxisTitle);
            ylabel(ax, '');
            return;
        end
        


        % Calculate axis limits for all selected datasets
        [x_lims, y_lims] = calculateAxisLimits(data);
        [~, y_lims] = nice_axis_limits(x_lims, y_lims);
        x_lims(1) = 0;

        % plot temperature data
        hold(ax, 'on');
        ylabel(ax, 'Temperature (C)');
        
        temp_real_Handles = [];
        temp_real_Entries = {};
        temp_setpoint_Handles = [];
        temp_setpoint_Entries = {};
        
        for iCharge = 1:numCharges 
            if checkboxes{iCharge}.Value
                h = plot(ax, getfield(curveData(iCharge).temperature_profile,...
                    data.ThermalData(iCharge).xaxis), ...
                    curveData(iCharge).temperature_profile.DTB_Avg_C, '.', ...
                    'Color', data.colors(iCharge,:), 'LineWidth', 1.5);
                g = plot(ax, getfield(curveData(iCharge).temperature_profile,...
                    data.ThermalData(iCharge).xaxis), ...
                    curveData(iCharge).temperature_profile.DTB_Setpoint_C, '+', ...
                    'Color', data.colors(iCharge,:), 'LineWidth', 1.5);
                
                temp_real_Handles(end+1) = h;
                temp_setpoint_Handles(end+1) = g;
                temp_real_Entries{end+1} = sprintf('%s actual temp (C)', curveData(iCharge).name);
                temp_setpoint_Entries{end+1} = sprintf('%s setpoint temp (C)', curveData(iCharge).name);
            end
        end

        ylim(ax, y_lims);
        
        hold(ax, 'off');
        
        % Set x-axis limits
        if ~isempty(x_lims)
            xlim(ax, x_lims);
        end
        
        % Combine handles and entries for legend
        legendHandles = [temp_real_Handles, temp_setpoint_Handles];
        legendEntries = [temp_real_Entries, temp_setpoint_Entries];
        
        % Add legend if requested and there are curves to show
        if data.showLegend && ~isempty(legendHandles)
            legend(ax, legendHandles, legendEntries, 'Location', 'south');
        else
            legend(ax, 'off');
        end
        
        grid(ax, 'on');
        box(ax, 'on');
        title(ax, plotTitle);
        xlabel(ax, xaxisTitle);
        drawnow
        pause(0.01)
    end

    function [x_lims, y_lims] = calculateAxisLimits(data)
        % Calculate optimal axis limits for all selected charge datasets
        all_time = [];
        all_temp = [];
        
        % Collect all time and temp values from selected datasets
        for iCharge = 1:numCharges
            if checkboxes{iCharge}.Value
                thermalData = data.ThermalData(iCharge).temperature_profile;
                
                all_time = [all_time; getfield(data.ThermalData(iCharge).temperature_profile,...
                    data.ThermalData(iCharge).xaxis)];
                all_temp = [all_temp; thermalData.DTB_Avg_C; thermalData.DTB_Setpoint_C];
            end
        end
        
        % Calculate limits with padding
        if ~isempty(all_time)
            % Time limits (x-axis)
            time_range = max(all_time) - min(all_time);
            time_padding = time_range * 0.05;
            x_lims = [min(all_time) - time_padding, max(all_time) + time_padding];
            
            % Handle edge case where time range is zero
            if time_range == 0
                x_lims = [min(all_time) - 0.5, max(all_time) + 0.5];
            end
            
            % Voltage limits (left y-axis)
            if ~isempty(all_temp)
                temp_range = max(all_temp) - min(all_temp);
                temp_padding = temp_range * 0.05;
                y_lims = [min(all_temp) - temp_padding, max(all_temp) + temp_padding];
                
                if temp_range == 0
                    y_lims = [min(all_temp) - 0.5, max(all_temp) + 0.5];
                end
            else
                y_lims = [];
            end
            
        else
            x_lims = [];
            y_lims = [];
        end
    end

    function clearAll(~, ~)
        for i = 1:numCharges
            checkboxes{i}.Value = false;
        end
        updatePlot();
    end

    function selectAll(~, ~)
        for i = 1:numCharges
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

end