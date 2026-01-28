function initializePersistentPlots(fig, selectedIndices)
    % Initialize persistent axes and line handles for efficient updates
    %
    % Creates plot objects once when selection changes, then only updates
    % their XData/YData on slider movements for better performance.

    handles = getappdata(fig, 'handles');
    panel = handles.rightPanel;
    batteryData = getappdata(fig, 'batteryData');
    cachedLimits = getappdata(fig, 'cachedCombinedLimits');
    controls = getappdata(fig, 'controls');

    % Clear any existing children
    delete(allchild(panel));

    % Create the main axes
    ax = axes('Parent', panel, 'Position', [0.08 0.12 0.87 0.82], 'Box', 'on');
    hold(ax, 'on');

    % Apply cached limits
    if ~isempty(cachedLimits)
        xlim(ax, cachedLimits.xlim);
        ylim(ax, cachedLimits.ylim);
    end

    % Set up labels
    xlabel(ax, 'Z_{real} (\Omega)', 'FontSize', 11);
    ylabel(ax, '-Z_{imag} (\Omega)', 'FontSize', 11);
    title(ax, 'EIS Comparison', 'FontSize', 13);

    if get(controls.gridCheck, 'Value')
        grid(ax, 'on');
        set(ax, 'GridLineStyle', ':');
    end

    % Create line handles for each selected dataset (initially empty)
    lineHandles = gobjects(1, length(selectedIndices));
    for i = 1:length(selectedIndices)
        dataset = batteryData.datasets(selectedIndices(i));
        lineHandles(i) = plot(ax, NaN, NaN, '-+', ...
            'Color', dataset.color, ...
            'LineWidth', 1, ...
            'DisplayName', dataset.name);
    end

    % Store persistent handles
    plotCache = struct();
    plotCache.axes = ax;
    plotCache.lineHandles = lineHandles;
    plotCache.selectedIndices = selectedIndices;
    plotCache.initialized = true;
    setappdata(fig, 'plotCache', plotCache);
end
