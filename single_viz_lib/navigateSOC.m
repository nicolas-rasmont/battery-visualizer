function navigateSOC(fig, direction)
    handles = getappdata(fig, 'handles');
    validIdx = getappdata(fig, 'validIdx');
    
    currentValue = round(get(handles.slider, 'Value'));
    newValue = currentValue + direction;
    
    if newValue >= 1 && newValue <= length(validIdx)
        set(handles.slider, 'Value', newValue);
        updatePlots(fig);
    end
end