function continuousSliderUpdate(fig)
    % Callback for continuous slider updates during dragging
    
    % Check if we're already updating to prevent overlap
    if getappdata(fig, 'isUpdating')
        return;
    end
    
    setappdata(fig, 'isUpdating', true);
    
    try
        % Use a simplified update for real-time response
        quickUpdatePlots(fig);
    catch ME
        % Handle any errors silently during rapid updates
    end
    
    setappdata(fig, 'isUpdating', false);
end