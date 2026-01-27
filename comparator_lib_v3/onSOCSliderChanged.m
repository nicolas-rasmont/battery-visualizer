function onSOCSliderChanged(fig)
    % Snap the slider to the nearest discrete SOC tick and replot live.

    controls = getappdata(fig, 'controls');
    socVals  = getappdata(fig, 'socTickValues');
    if isempty(controls) || isempty(socVals); return; end

    rawIdx = get(controls.socSlider, 'Value');
    idx    = round(rawIdx);
    idx    = max(1, min(numel(socVals), idx));

    % Snap the knob to the discrete index (prevents in-between states)
    if abs(rawIdx - idx) > 1e-9
        set(controls.socSlider, 'Value', idx);
    end
    setappdata(fig, 'currentSOCIndex', idx);

    % Live update the plots & text
    updatePlotsComparator(fig);
    drawnow;  % keep interaction smooth during drags
end
