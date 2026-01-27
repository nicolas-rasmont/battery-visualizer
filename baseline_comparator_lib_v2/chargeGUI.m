function chargeGUI(chargeData, plotTitle,xaxisTitle,plotPosition)
% CHARGEGUI - Interactive GUI to compare charge/discharge curves
%
% Usage: 
%   chargeGUI(chargeData, plotTitle)
%
% Inputs:
%   chargeData - struct array containing charge data with fields:
%                .name - string name for the charge
%                .charge - struct with fields Time_s, Voltage_V, Current_A
%   plotTitle  - string for plot title

% Validate inputs
numCharges = length(chargeData);
if numCharges == 0
    error('At least one charge dataset must be provided');
end

% Create main figure
fig = uifigure('Name', 'Charge Data Comparison', 'Position', plotPosition);

% Create UI components
% Main axes for plotting
ax = uiaxes(fig, 'Position', [50 150 500 400]);
title(ax, 'Charge Data Comparison');
grid(ax, 'on');

% Checkboxes for family selection
checkboxPanel = uipanel(fig, 'Position',[570 150 200 260], 'Title', 'Select Datasets');

checkboxes = cell(numCharges, 1);
colors = lines(numCharges); % Generate distinct colors

for jCharge = 1:numCharges
    yPos = 220 - jCharge * 30;
    checkboxes{jCharge} = uicheckbox(checkboxPanel, ...
        'Position', [10 yPos 180 22], ...
        'Text', chargeData(jCharge).name, ...
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
figData.ChargeData = chargeData;
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
        curveData = data.ChargeData;

        
        % Plot selected families
        legendEntries = {};
        legendHandles = [];
        
        % Check if any datasets are selected
        anySelected = any(cellfun(@(cb) cb.Value, checkboxes));

        % Clear both axes properly
        yyaxis(ax, 'left');
        cla(ax);
        yyaxis(ax, 'right'); 
        cla(ax);
        
        if ~anySelected
            % Clear plot if nothing selected
            title(ax, plotTitle);
            xlabel(ax, xaxisTitle);
            ylabel(ax, '');
            return;
        end
        


        % Calculate axis limits for all selected datasets
        [xlims, ylims_left, ylims_right] = calculateAxisLimits(data);
        [~, ylims_left] = nice_axis_limits(xlims, ylims_left);
        [~, ylims_right] = nice_axis_limits(xlims, ylims_right);
        xlims(1) = 0;

        % First pass: plot voltage data (left y-axis)
        yyaxis(ax, 'left');
        hold(ax, 'on');
        ylabel(ax, 'Voltage (V)');
        
        voltageHandles = [];
        voltageEntries = {};
        
        for iCharge = 1:numCharges 
            if checkboxes{iCharge}.Value
                h = plot(ax, getfield(curveData(iCharge).charge,...
                    data.ChargeData(iCharge).xaxis), ...
                    curveData(iCharge).charge.Voltage_V, '-', ...
                    'Color', data.colors(iCharge,:), 'LineWidth', 1.5);
                
                voltageHandles(end+1) = h;
                voltageEntries{end+1} = sprintf('%s (V)', curveData(iCharge).name);
            end
        end
        
        % Set left y-axis limits
        if ~isempty(ylims_left)
            ylim(ax, ylims_left);
        end
        
        % Second pass: plot current data (right y-axis)
        yyaxis(ax, 'right');
        ylabel(ax, 'Current (A)');
        
        currentHandles = [];
        currentEntries = {};
        
        for iCharge = 1:numCharges 
            if checkboxes{iCharge}.Value
                g = plot(ax, getfield(curveData(iCharge).charge,...
                    data.ChargeData(iCharge).xaxis), ...
                    curveData(iCharge).charge.Current_A, '--', ...
                    'Color', data.colors(iCharge,:), 'LineWidth', 1.5);
                
                currentHandles(end+1) = g;
                currentEntries{end+1} = sprintf('%s (I)', curveData(iCharge).name);
            end
        end
        
        % Set right y-axis limits
        if ~isempty(ylims_right)
            ylim(ax, ylims_right);
        end
        
        hold(ax, 'off');
        
        % Set x-axis limits (common for both y-axes)
        if ~isempty(xlims)
            xlim(ax, xlims);
        end
        
        % Combine handles and entries for legend
        legendHandles = [voltageHandles, currentHandles];
        legendEntries = [voltageEntries, currentEntries];
        
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

    function [xlims, ylims_left, ylims_right] = calculateAxisLimits(data)
        % Calculate optimal axis limits for all selected charge datasets
        all_time = [];
        all_voltage = [];
        all_current = [];
        
        % Collect all time, voltage, and current values from selected datasets
        for iCharge = 1:numCharges
            if checkboxes{iCharge}.Value
                chargeData = data.ChargeData(iCharge).charge;
                
                all_time = [all_time; getfield(data.ChargeData(iCharge).charge,...
                    data.ChargeData(iCharge).xaxis)];
                all_voltage = [all_voltage; chargeData.Voltage_V];
                all_current = [all_current; chargeData.Current_A];
            end
        end
        
        % Calculate limits with padding
        if ~isempty(all_time)
            % Time limits (x-axis)
            time_range = max(all_time) - min(all_time);
            time_padding = time_range * 0.05;
            xlims = [min(all_time) - time_padding, max(all_time) + time_padding];
            
            % Handle edge case where time range is zero
            if time_range == 0
                xlims = [min(all_time) - 0.5, max(all_time) + 0.5];
            end
            
            % Voltage limits (left y-axis)
            if ~isempty(all_voltage)
                voltage_range = max(all_voltage) - min(all_voltage);
                voltage_padding = voltage_range * 0.05;
                ylims_left = [min(all_voltage) - voltage_padding, max(all_voltage) + voltage_padding];
                
                if voltage_range == 0
                    ylims_left = [min(all_voltage) - 0.5, max(all_voltage) + 0.5];
                end
            else
                ylims_left = [];
            end
            
            % Current limits (right y-axis)
            if ~isempty(all_current)
                current_range = max(all_current) - min(all_current);
                current_padding = current_range * 0.05;
                ylims_right = [min(all_current) - current_padding, max(all_current) + current_padding];
                
                if current_range == 0
                    ylims_right = [min(all_current) - 0.5, max(all_current) + 0.5];
                end
            else
                ylims_right = [];
            end
        else
            xlims = [];
            ylims_left = [];
            ylims_right = [];
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