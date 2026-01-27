function ensureSOCSliderConfigured(fig)
    controls   = getappdata(fig, 'controls');
    socVals    = getappdata(fig, 'socTickValues');
    bd         = getappdata(fig, 'batteryData');
    currentIdx = getappdata(fig, 'currentBatteryIdx');

    if isempty(bd) || isempty(currentIdx); return; end
    if ~isempty(socVals); return; end

    % --- your source of truth ---
    socArray = bd.datasets.socEIScan.SOCPoints;

    socVals = unique(socArray(:), 'sorted');
    socVals(isnan(socVals)) = [];
    if isempty(socVals); socVals = 50; end

    setappdata(fig, 'socTickValues', socVals);

    % Configure slider as 1..N index selector
    N = numel(socVals);
    if N > 1
        stepSmall = 1/(N-1);
        stepLarge = min(5/(N-1), 1);
    else
        stepSmall = 1; stepLarge = 1;
    end
    set(controls.socSlider, 'Min', 1, 'Max', N, 'SliderStep', [stepSmall stepLarge]);

    % Initial index near 50%
    [~, idx0] = min(abs(socVals - 50));
    if isempty(idx0); idx0 = 1; end
    set(controls.socSlider, 'Value', idx0);
    setappdata(fig, 'currentSOCIndex', idx0);

    set(controls.socSlider, 'Enable', 'on');
    set(controls.prevBtn,   'Enable', 'on');
    set(controls.nextBtn,   'Enable', 'on');
end
