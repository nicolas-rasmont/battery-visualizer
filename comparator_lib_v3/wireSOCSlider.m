function wireSOCSlider(fig)
    controls = getappdata(fig,'controls');

    % Keep keyboard/page-up/down & mouse-up working via the slider callback
    set(controls.socSlider, 'Callback', @(~,~) onSOCSliderChanged(fig));

    % Try a property listener that fires while dragging on newer MATLAB (HG2+)
    try
        h = addlistener(controls.socSlider, 'Value', 'PostSet', @(~,~) onSOCSliderChanged(fig));
        setappdata(fig, 'socSliderListener', h);  % keep it alive
    catch
        % If not supported, the motion poller below handles live updates
    end

    % Motion poller: runs often, but only triggers a replot when the discrete index changes
    set(fig, 'WindowButtonMotionFcn', @(~,~) socMotionHandler(fig));

    % Track last discrete index to avoid redundant replots
    setappdata(fig,'lastSOCIndex', []);
end

function socMotionHandler(fig)
    controls = getappdata(fig,'controls');
    if isempty(controls) || ~ishandle(controls.socSlider) ...
            || strcmp(get(controls.socSlider,'Enable'),'off')
        return;
    end

    % Quantize to discrete index
    rawIdx = get(controls.socSlider,'Value');
    maxN   = round(get(controls.socSlider,'Max'));
    idx    = max(1, min(round(rawIdx), maxN));

    last = getappdata(fig,'lastSOCIndex');
    if isempty(last) || idx ~= last
        onSOCSliderChanged(fig);              % snaps + replots
        setappdata(fig,'lastSOCIndex', idx);
    end
end