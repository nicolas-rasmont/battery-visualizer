function fig = plotEISGridBaseline(varargin)
    % PLOTEISGRIDBASELINE - Plot EIS curves across all SOC levels in a 4x3 grid
    %
    % Creates a 4x3 grid of Nyquist plots showing EIS data at each SOC level
    % for multiple batteries, using data structures from readBaseline.
    %
    % Syntax:
    %   plotEISGridBaseline(data1, data2, ...)
    %   fig = plotEISGridBaseline(data1, data2, ...)
    %
    % Inputs:
    %   data1, data2, ... - Data structures from readBaseline, each containing:
    %       .identifier - Battery name string
    %       .phase_3.eis_measurements - Cell array of EIS measurements
    %       .phase_3.ocv_vs_soc.SOC_Percent - SOC values for each measurement
    %       .summary.Phase3_EIS_Summary.Total_EIS_Measurements - Number of measurements
    %
    % Output:
    %   fig - Handle to the created figure
    %
    % Example:
    %   data1 = readBaseline('path/to/battery1');
    %   data1.identifier = 'Battery A';
    %   data2 = readBaseline('path/to/battery2');
    %   data2.identifier = 'Battery B';
    %   plotEISGridBaseline(data1, data2)

    if nargin == 0
        error('At least one data structure is required');
    end

    % Color palette for different batteries
    colors = {[0 0.447 0.741], [0.85 0.325 0.098], [0.466 0.674 0.188], ...
              [0.494 0.184 0.556], [0.929 0.694 0.125], [0.301 0.745 0.933], ...
              [0.635 0.078 0.184], [0.5 0.5 0.5], [0 0.5 0.5], [0.5 0 0.5]};

    % Extract data from all inputs
    numBatteries = nargin;
    batteryNames = cell(numBatteries, 1);
    batteryColors = cell(numBatteries, 1);
    eisData = cell(numBatteries, 1);
    socLevels = [];

    for i = 1:numBatteries
        currentData = varargin{i};

        % Get battery name
        if isfield(currentData, 'identifier')
            batteryNames{i} = currentData.identifier;
        else
            batteryNames{i} = sprintf('Battery %d', i);
        end

        batteryColors{i} = colors{mod(i-1, length(colors)) + 1};

        % Get SOC levels (use first battery as reference)
        if isempty(socLevels) && isfield(currentData, 'phase_3') && ...
           isfield(currentData.phase_3, 'ocv_vs_soc')
            socLevels = currentData.phase_3.ocv_vs_soc.SOC_Percent;
        end

        % Extract EIS curves
        if isfield(currentData, 'summary') && ...
           isfield(currentData.summary, 'Phase3_EIS_Summary')
            numMeasurements = currentData.summary.Phase3_EIS_Summary.Total_EIS_Measurements;
        else
            numMeasurements = length(currentData.phase_3.eis_measurements);
        end

        eisData{i} = cell(numMeasurements, 1);
        for j = 1:numMeasurements
            eisMeasurement = currentData.phase_3.eis_measurements{j};
            if isfield(eisMeasurement, 'Impedance_Data')
                impedanceData = eisMeasurement.Impedance_Data;
                eisData{i}{j} = struct(...
                    'Z_Real', impedanceData.Z_Real_Ohm, ...
                    'Z_Imag', impedanceData.Z_Imag_Ohm, ...
                    'Freq', impedanceData.Frequency_Hz);
            end
        end
    end

    numSOC = length(socLevels);
    if numSOC == 0
        error('No valid SOC data found in input structures');
    end

    % Calculate global axis limits
    [globalXlim, globalYlim] = calculateGlobalLimits(eisData);

    % Create figure
    fig = figure('Name', 'EIS Grid - All SOC Levels', ...
                 'NumberTitle', 'off', ...
                 'Position', [50, 50, 1400, 1000], ...
                 'Color', 'white');

    % Create 4x3 grid of subplots
    nRows = 4;
    nCols = 3;

    for socIdx = 1:min(numSOC, nRows * nCols)
        subplot(nRows, nCols, socIdx);
        hold on;

        socValue = socLevels(socIdx);

        % Plot each battery at this SOC level
        for batIdx = 1:numBatteries
            if socIdx <= length(eisData{batIdx}) && ~isempty(eisData{batIdx}{socIdx})
                data = eisData{batIdx}{socIdx};
                plot(data.Z_Real, -data.Z_Imag, '-', ...
                     'Color', batteryColors{batIdx}, ...
                     'LineWidth', 1.5, ...
                     'DisplayName', batteryNames{batIdx});
            end
        end

        % Configure subplot
        xlim(globalXlim);
        ylim(globalYlim);
        title(sprintf('SOC: %.0f%%', socValue), 'FontSize', 11, 'FontWeight', 'bold');
        xlabel('Z_{real} (\Omega)', 'FontSize', 9);
        ylabel('-Z_{imag} (\Omega)', 'FontSize', 9);
        grid on;
        set(gca, 'GridLineStyle', ':', 'FontSize', 8);
        box on;
        hold off;
    end

    % Add legend in the 12th subplot position
    if numSOC < nRows * nCols
        subplot(nRows, nCols, nRows * nCols);
        axis off;
        hold on;

        % Create invisible lines for legend
        for batIdx = 1:numBatteries
            plot(NaN, NaN, '-', ...
                'Color', batteryColors{batIdx}, ...
                'LineWidth', 2, ...
                'DisplayName', batteryNames{batIdx});
        end
        legend('Location', 'center', 'FontSize', 10);
        title('Legend', 'FontSize', 12, 'FontWeight', 'bold');
        hold off;
    else
        % Add legend to first subplot
        subplot(nRows, nCols, 1);
        legend('Location', 'best', 'FontSize', 7);
    end

    % Add overall title
    sgtitle('EIS Comparison Across All SOC Levels', 'FontSize', 14, 'FontWeight', 'bold');
end

function [xlimits, ylimits] = calculateGlobalLimits(eisData)
    % Calculate axis limits across all batteries and SOC levels

    xmin = inf; xmax = -inf;
    ymin = inf; ymax = -inf;

    for batIdx = 1:length(eisData)
        for socIdx = 1:length(eisData{batIdx})
            data = eisData{batIdx}{socIdx};
            if ~isempty(data)
                xmin = min(xmin, min(data.Z_Real));
                xmax = max(xmax, max(data.Z_Real));
                ymin = min(ymin, min(-data.Z_Imag));
                ymax = max(ymax, max(-data.Z_Imag));
            end
        end
    end

    % Handle empty data
    if isinf(xmin)
        xlimits = [0 1];
        ylimits = [0 1];
        return;
    end

    % Add padding
    xrange = xmax - xmin;
    yrange = ymax - ymin;
    xlimits = [xmin - 0.05*xrange, xmax + 0.05*xrange];
    ylimits = [ymin - 0.05*yrange, ymax + 0.05*yrange];

    % Round to nice values
    [xlimits, ylimits] = nice_axis_limits(xlimits, ylimits);

    % Ensure y includes zero
    if ylimits(1) > 0
        ylimits(1) = -0.001;
    end
end
