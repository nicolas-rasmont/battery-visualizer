function continuousSliderUpdate(fig)
    % Callback for continuous slider updates during dragging
    %
    % This function now uses the optimized update path with reentrant protection.

    % Check if we're already updating to prevent overlap
    if getappdata(fig, 'isUpdating')
        return;
    end

    setappdata(fig, 'isUpdating', true);

    try
        updatePlotsComparator(fig);
    catch ME
        warning('Continuous update error: %s', ME.message);
    end

    setappdata(fig, 'isUpdating', false);
end
