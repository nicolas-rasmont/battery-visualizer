function quickUpdatePlots(fig)
    % Optimized plot update for real-time slider movement
    
    batteryData = getappdata(fig, 'batteryData');
    currentIdx = getappdata(fig, 'currentBatteryIdx');
    comparisonMode = getappdata(fig, 'comparisonMode');
    viewType = getappdata(fig, 'viewType');
    
    if isempty(currentIdx) || batteryData.count == 0
        return;
    end
    
    % Get controls
    controls = getappdata(fig, 'controls');
    socValue = get(controls.socSlider, 'Value');
    
    % Update SOC display immediately
    set(controls.socDisplay, 'String', sprintf('%.1f%%', socValue));
    
    % Quick update based on view type
    if strcmp(viewType, 'eis')
        % For EIS, we need to update the plots
        updatePlotsComparator(fig);
    else
        % For charge view, just update the markers
        updateChargeMarkers(fig, socValue);
    end
end