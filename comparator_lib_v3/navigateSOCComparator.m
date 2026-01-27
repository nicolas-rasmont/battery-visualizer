function navigateSOCComparator(fig, step)
    % step = -1 for previous, +1 for next

    controls = getappdata(fig, 'controls');
    socVals  = getappdata(fig, 'socTickValues');
    idx      = getappdata(fig, 'currentSOCIndex');

    if isempty(controls) || isempty(socVals)
        return;
    end
    if isempty(idx); idx = round(get(controls.socSlider,'Value')); end

    idx = max(1, min(numel(socVals), idx + step));
    set(controls.socSlider, 'Value', idx);
    setappdata(fig, 'currentSOCIndex', idx);

    onSOCSliderChanged(fig);  % will update display & replot
end

% 
% function navigateSOCComparator(fig, direction)
%     % Navigate SOC slider
% 
%     controls = getappdata(fig, 'controls');
%     currentValue = get(controls.socSlider, 'Value');
%     step = 10;  % 10% steps
% 
%     newValue = currentValue + direction * step;
%     newValue = max(0, min(180, newValue));
% 
%     set(controls.socSlider, 'Value', newValue);
%     updatePlots(fig);
% end
