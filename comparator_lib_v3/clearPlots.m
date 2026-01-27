function clearPlots(fig)
    % Clear all plot axes
    
    handles = getappdata(fig, 'handles');
    panel = handles.rightPanel;
    delete(allchild(panel));
    
    ax = axes('Parent', panel, 'Position', [0.08 0.12 0.87 0.82]);
    title(ax, 'Select Battery Dataset to Display', 'FontSize', 14);
    set(ax, 'XTick', [], 'YTick', []);
end