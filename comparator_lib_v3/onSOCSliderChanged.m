function onSOCSliderChanged(fig)
    % Handle SOC slider changes with snap to discrete values
    %
    % Note: This function is kept for compatibility but the main slider
    % handling is now done by debouncedSliderUpdate in wireSOCSlider.m

    controls = getappdata(fig, 'controls');
    socVals = getappdata(fig, 'socTickValues');

    if isempty(controls) || isempty(socVals)
        return;
    end

    % Get and snap to discrete index
    rawIdx = get(controls.socSlider, 'Value');
    idx = round(rawIdx);
    idx = max(1, min(numel(socVals), idx));

    % Snap the slider to the discrete index
    if abs(rawIdx - idx) > 1e-9
        set(controls.socSlider, 'Value', idx);
    end
    setappdata(fig, 'currentSOCIndex', idx);

    % Update plots (no drawnow - let MATLAB handle rendering naturally)
    updatePlotsComparator(fig);
end
