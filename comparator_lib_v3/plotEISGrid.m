function fig = plotEISGrid(varargin)
    % PLOTEISGRID - Plot EIS curves for multiple batteries across all SOC levels
    %
    % Creates a 4x3 grid of Nyquist plots, one for each SOC level (0-100%),
    % with all batteries overlaid on each subplot.
    %
    % Syntax:
    %   plotEISGrid(dataset1, dataset2, ...)
    %   plotEISGrid(batteryData, selectedIndices)
    %   fig = plotEISGrid(...)
    %
    % Inputs:
    %   Option 1: Variable number of dataset structures, each containing:
    %       .name - Battery identifier string
    %       .socEIScan - EIS scan structure from EISSOCScanReader
    %       .color - [R G B] color for plotting (optional)
    %
    %   Option 2: batteryData structure from comparator with selectedIndices
    %
    % Output:
    %   fig - Handle to the created figure
    %
    % Example:
    %   plotEISGrid(battery1, battery2, battery3)

    % Parse inputs and build datasets array
    [datasets, colors] = parseInputs(varargin{:});

    if isempty(datasets)
        error('No valid datasets provided');
    end

    % Determine SOC levels (use first valid dataset as reference)
    socLevels = [];
    for i = 1:length(datasets)
        if ~isempty(datasets(i).socEIScan) && isfield(datasets(i).socEIScan, 'SOCPoints')
            socLevels = datasets(i).socEIScan.SOCPoints;
            break;
        end
    end

    if isempty(socLevels)
        error('No valid EIS data found in datasets');
    end

    numSOC = length(socLevels);

    % Calculate global axis limits across all datasets and SOC levels
    [globalXlim, globalYlim] = calculateGlobalLimitsAllSOC(datasets);
    [globalXlim, globalYlim] = nice_axis_limits(globalXlim, globalYlim);

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
        hasData = false;

        % Plot each battery at this SOC level
        for batIdx = 1:length(datasets)
            dataset = datasets(batIdx);
            color = colors{batIdx};

            if isempty(dataset.socEIScan)
                continue;
            end

            % Find the scan for this SOC
            [~, scanIdx] = min(abs(dataset.socEIScan.SOCPoints - socValue));

            if scanIdx > length(dataset.socEIScan.Scans)
                continue;
            end

            scan = dataset.socEIScan.Scans{scanIdx};

            if isempty(scan) || ~isfield(scan, 'ImpedanceData')
                continue;
            end

            % Plot Nyquist curve
            data = scan.ImpedanceData;
            plot(data.Z_Real_Ohm, -data.Z_Imag_Ohm, '-', ...
                 'Color', color, ...
                 'LineWidth', 1.5, ...
                 'DisplayName', dataset.name);

            hasData = true;
        end

        % Configure subplot
        if hasData
            xlim(globalXlim);
            ylim(globalYlim);
        end

        title(sprintf('SOC: %.0f%%', socValue), 'FontSize', 11, 'FontWeight', 'bold');
        xlabel('Z_{real} (\Omega)', 'FontSize', 9);
        ylabel('-Z_{imag} (\Omega)', 'FontSize', 9);
        grid on;
        set(gca, 'GridLineStyle', ':', 'FontSize', 8);
        box on;

        hold off;
    end

    % Add legend in the 12th subplot position (or as a separate element)
    if numSOC < nRows * nCols
        subplot(nRows, nCols, nRows * nCols);
        axis off;

        % Create invisible lines for legend
        hold on;
        legendHandles = gobjects(length(datasets), 1);
        for batIdx = 1:length(datasets)
            legendHandles(batIdx) = plot(NaN, NaN, '-', ...
                'Color', colors{batIdx}, ...
                'LineWidth', 2, ...
                'DisplayName', datasets(batIdx).name);
        end
        legend(legendHandles, 'Location', 'center', 'FontSize', 10);
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

function [datasets, colors] = parseInputs(varargin)
    % Parse various input formats into a consistent datasets array

    datasets = struct('name', {}, 'socEIScan', {}, 'color', {});
    colors = {};

    % Default color palette
    defaultColors = {[0 0.447 0.741], [0.85 0.325 0.098], [0.466 0.674 0.188], ...
                     [0.494 0.184 0.556], [0.929 0.694 0.125], [0.301 0.745 0.933], ...
                     [0.635 0.078 0.184], [0.5 0.5 0.5], [0 0.5 0.5], [0.5 0 0.5]};

    if nargin == 0
        return;
    end

    % Check if first argument is a batteryData structure with datasets field
    if nargin >= 1 && isstruct(varargin{1}) && isfield(varargin{1}, 'datasets')
        batteryData = varargin{1};

        if nargin >= 2 && isnumeric(varargin{2})
            selectedIndices = varargin{2};
        else
            selectedIndices = 1:batteryData.count;
        end

        for i = 1:length(selectedIndices)
            idx = selectedIndices(i);
            if idx <= length(batteryData.datasets)
                ds = batteryData.datasets(idx);
                datasets(end+1).name = ds.name;
                datasets(end).socEIScan = ds.socEIScan;

                if isfield(ds, 'color')
                    colors{end+1} = ds.color;
                else
                    colors{end+1} = defaultColors{mod(i-1, length(defaultColors)) + 1};
                end
            end
        end
    else
        % Individual dataset arguments
        for i = 1:nargin
            ds = varargin{i};
            if isstruct(ds) && isfield(ds, 'socEIScan')
                datasets(end+1).name = getDatasetName(ds, i);
                datasets(end).socEIScan = ds.socEIScan;

                if isfield(ds, 'color')
                    colors{end+1} = ds.color;
                else
                    colors{end+1} = defaultColors{mod(i-1, length(defaultColors)) + 1};
                end
            end
        end
    end
end

function name = getDatasetName(ds, idx)
    % Extract or generate a name for the dataset
    if isfield(ds, 'name') && ~isempty(ds.name)
        name = ds.name;
    elseif isfield(ds, 'identifier') && ~isempty(ds.identifier)
        name = ds.identifier;
    else
        name = sprintf('Battery %d', idx);
    end
end

function [xlimits, ylimits] = calculateGlobalLimitsAllSOC(datasets)
    % Calculate axis limits that encompass all data across all datasets and SOC levels

    xmin = inf; xmax = -inf;
    ymin = inf; ymax = -inf;

    for batIdx = 1:length(datasets)
        dataset = datasets(batIdx);

        if isempty(dataset.socEIScan) || ~isfield(dataset.socEIScan, 'Scans')
            continue;
        end

        for scanIdx = 1:length(dataset.socEIScan.Scans)
            scan = dataset.socEIScan.Scans{scanIdx};

            if isempty(scan) || ~isfield(scan, 'ImpedanceData')
                continue;
            end

            data = scan.ImpedanceData;
            xmin = min(xmin, min(data.Z_Real_Ohm));
            xmax = max(xmax, max(data.Z_Real_Ohm));
            ymin = min(ymin, min(-data.Z_Imag_Ohm));
            ymax = max(ymax, max(-data.Z_Imag_Ohm));
        end
    end

    % Handle case with no valid data
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

    % Ensure y-axis includes zero for Nyquist plots
    if ylimits(1) > 0
        ylimits(1) = -0.001;
    end
end
