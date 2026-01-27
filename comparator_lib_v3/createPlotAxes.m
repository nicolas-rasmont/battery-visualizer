function createPlotAxes(panel, fig)
    % Create axes for different view modes
    
    % Default: single axis
    ax = axes('Parent', panel, ...
              'Position', [0.08 0.12 0.87 0.82], ...
              'Box', 'on', ...
              'Visible', 'on');
    title(ax, 'Select Battery Dataset to Display', 'FontSize', 14);
    grid(ax, 'on');
    
    setappdata(fig, 'plotAxes', ax);
end