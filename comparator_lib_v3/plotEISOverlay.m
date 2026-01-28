function plotEISOverlay(fig, batteryIndices, socValue)
    % Overlay EIS data from multiple batteries using persistent plot handles
    %
    % This function updates existing line objects instead of recreating them,
    % which provides much better performance during slider interactions.

    batteryData = getappdata(fig, 'batteryData');
    controls = getappdata(fig, 'controls');
    plotCache = getappdata(fig, 'plotCache');
    cachedLimits = getappdata(fig, 'cachedCombinedLimits');

    % Check if we have valid persistent handles
    if isempty(plotCache) || ~isfield(plotCache, 'initialized') || ~plotCache.initialized
        % Fall back to initialization if cache is invalid
        initializePersistentPlots(fig, batteryIndices);
        plotCache = getappdata(fig, 'plotCache');
    end

    % Check if selection changed (need to reinitialize)
    if ~isequal(plotCache.selectedIndices, batteryIndices)
        initializePersistentPlots(fig, batteryIndices);
        plotCache = getappdata(fig, 'plotCache');
    end

    ax = plotCache.axes;
    lineHandles = plotCache.lineHandles;

    % Verify axes still exist
    if ~isvalid(ax)
        initializePersistentPlots(fig, batteryIndices);
        plotCache = getappdata(fig, 'plotCache');
        ax = plotCache.axes;
        lineHandles = plotCache.lineHandles;
    end

    % Update each line's data
    hasData = false;
    for i = 1:length(batteryIndices)
        dataset = batteryData.datasets(batteryIndices(i));

        if isempty(dataset.socEIScan)
            % Clear this line
            set(lineHandles(i), 'XData', NaN, 'YData', NaN);
            continue;
        end

        % Find closest SOC
        [~, socIdx] = min(abs(dataset.socEIScan.SOCPoints - socValue));
        actualSOC = dataset.socEIScan.SOCPoints(socIdx);

        % Get scan
        validScans = find(dataset.socEIScan.ValidScans);
        if socIdx > length(validScans)
            set(lineHandles(i), 'XData', NaN, 'YData', NaN);
            continue;
        end

        scanIdx = validScans(socIdx);
        scan = dataset.socEIScan.Scans{scanIdx};

        if isempty(scan) || ~isfield(scan, 'ImpedanceData')
            set(lineHandles(i), 'XData', NaN, 'YData', NaN);
            continue;
        end

        % Update line data (fast operation - no object creation)
        data = scan.ImpedanceData;
        set(lineHandles(i), ...
            'XData', data.Z_Real_Ohm, ...
            'YData', -data.Z_Imag_Ohm, ...
            'DisplayName', sprintf('%s (%.1f%%)', dataset.name, actualSOC));

        hasData = true;
    end

    % Update title with current SOC
    if hasData
        title(ax, sprintf('EIS Comparison - Target SOC: %.1f%%', socValue), 'FontSize', 13);
    else
        title(ax, 'No EIS data available at this SOC', 'FontSize', 13);
    end

    % Update legend if enabled (only rebuild if needed)
    if get(controls.showLegendCheck, 'Value')
        legend(ax, 'Location', 'best', 'Interpreter', 'none');
    else
        legend(ax, 'off');
    end
end
