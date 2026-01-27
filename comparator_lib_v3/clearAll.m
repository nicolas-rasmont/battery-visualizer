function clearAll(fig)
    % Clear all loaded datasets
    
    answer = questdlg('Clear all loaded battery datasets?', ...
                      'Clear All', 'Yes', 'No', 'No');
    if ~strcmp(answer, 'Yes')
        return;
    end
    
    batteryData = struct();
    batteryData.datasets = [];
    batteryData.count = 0;
    setappdata(fig, 'batteryData', batteryData);
    setappdata(fig, 'currentBatteryIdx', []);
    
    updateBatteryList(fig);
    clearPlots(fig);
    
    handles = getappdata(fig, 'handles');
    set(handles.infoText, 'String', 'No battery loaded');
    
    controls = getappdata(fig, 'controls');
    set(controls.socSlider, 'Enable', 'off');
    set(controls.prevBtn, 'Enable', 'off');
    set(controls.nextBtn, 'Enable', 'off');
    set(controls.statusText, 'String', 'All datasets cleared');
end
