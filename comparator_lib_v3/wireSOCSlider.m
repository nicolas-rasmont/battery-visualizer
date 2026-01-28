function wireSOCSlider(fig)
    % Wire up SOC slider with optimized event handling
    %
    % Uses a single PostSet listener for live updates during dragging,
    % with debouncing to prevent redundant redraws.

    controls = getappdata(fig, 'controls');

    % Initialize tracking state
    setappdata(fig, 'lastSOCIndex', []);
    setappdata(fig, 'isUpdating', false);

    % Use PostSet listener for live updates (fires during drag)
    try
        h = addlistener(controls.socSlider, 'Value', 'PostSet', ...
            @(~,~) debouncedSliderUpdate(fig));
        setappdata(fig, 'socSliderListener', h);
    catch
        % Fallback for older MATLAB: use regular callback
        set(controls.socSlider, 'Callback', @(~,~) debouncedSliderUpdate(fig));
    end
end

function debouncedSliderUpdate(fig)
    % Debounced slider update - only fires when discrete index changes
    % and prevents reentrant calls

    % Check for reentrant call
    if getappdata(fig, 'isUpdating')
        return;
    end

    controls = getappdata(fig, 'controls');
    socVals = getappdata(fig, 'socTickValues');

    if isempty(controls) || ~ishandle(controls.socSlider)
        return;
    end

    % Get current discrete index
    rawIdx = get(controls.socSlider, 'Value');
    maxN = round(get(controls.socSlider, 'Max'));
    idx = max(1, min(round(rawIdx), maxN));

    % Check if index actually changed
    lastIdx = getappdata(fig, 'lastSOCIndex');
    if ~isempty(lastIdx) && idx == lastIdx
        return;  % No change, skip update
    end

    % Mark as updating to prevent reentrant calls
    setappdata(fig, 'isUpdating', true);
    setappdata(fig, 'lastSOCIndex', idx);

    try
        % Snap slider to discrete position
        if abs(rawIdx - idx) > 1e-9
            set(controls.socSlider, 'Value', idx);
        end
        setappdata(fig, 'currentSOCIndex', idx);

        % Update SOC display text
        if ~isempty(socVals) && idx <= length(socVals)
            socValue = socVals(idx);
            set(controls.socDisplay, 'String', sprintf('%.1f%%', socValue));
        end

        % Update plots
        updatePlotsComparator(fig);
    catch ME
        % Log error but don't crash
        warning('Slider update error: %s', ME.message);
    end

    setappdata(fig, 'isUpdating', false);
end
