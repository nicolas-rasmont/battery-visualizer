function clearPlots(fig)
    % Clear all plot axes and reset persistent handles
    %
    % This is called when selection is cleared or when a full reset is needed.
    % For normal slider updates, use updatePlotsComparator instead.

    handles = getappdata(fig, 'handles');
    panel = handles.rightPanel;

    % Clear all children
    delete(allchild(panel));

    % Reset the plot cache
    setappdata(fig, 'plotCache', []);
    setappdata(fig, 'cachedCombinedLimits', []);

    % Create placeholder axes
    ax = axes('Parent', panel, 'Position', [0.08 0.12 0.87 0.82]);
    title(ax, 'Select Battery Dataset to Display', 'FontSize', 14);
    set(ax, 'XTick', [], 'YTick', []);
end
