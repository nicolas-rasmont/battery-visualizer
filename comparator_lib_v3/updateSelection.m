function updateSelection(fig)
    % Update display based on selected batteries
    
    handles = getappdata(fig, 'handles');
    batteryData = getappdata(fig, 'batteryData');
    selected = get(handles.batteryListbox, 'Value');
    
    if isempty(selected)
        set(handles.infoText, 'String', 'No battery selected');
        setappdata(fig, 'currentBatteryIdx', []);
        clearPlots(fig);
        
        % Disable controls
        controls = getappdata(fig, 'controls');
        set(controls.socSlider, 'Enable', 'off');
        set(controls.prevBtn, 'Enable', 'off');
        set(controls.nextBtn, 'Enable', 'off');
        return;
    end
    
    setappdata(fig, 'currentBatteryIdx', selected);
    
    % Update info display
    if length(selected) == 1
        dataset = batteryData.datasets(selected);
        infoStr = sprintf('Name: %s\n', dataset.name);
        
        if isfield(dataset.batteryEIS, 'TestInfo')
            info = dataset.batteryEIS.TestInfo;
            infoStr = sprintf('%sCapacity: %.1f mAh\n', infoStr, info.Battery_Capacity_mAh);
            infoStr = sprintf('%sDuration: %.2f h\n', infoStr, info.Total_Duration_h);
        end
        
        if ~isempty(dataset.socEIScan)
            infoStr = sprintf('%sEIS Points: %d\n', infoStr, dataset.socEIScan.NumValidScans);
            infoStr = sprintf('%sSOC Range: %.0f-%.0f%%\n', infoStr, ...
                            min(dataset.socEIScan.SOCPoints), ...
                            max(dataset.socEIScan.SOCPoints));
        end
        
        if ~isempty(dataset.chargeData)
            infoStr = sprintf('%sCharge Data: Available\n', infoStr);
            infoStr = sprintf('%sVoltage: %.3f-%.3f V\n', infoStr, ...
                            dataset.chargeData.MinVoltage, dataset.chargeData.MaxVoltage);
            infoStr = sprintf('%sAvg Current: %.2f A\n', infoStr, dataset.chargeData.AvgCurrent);
        else
            infoStr = sprintf('%sCharge Data: Not Available\n', infoStr);
        end
        
        infoStr = sprintf('%s\nLoaded: %s', infoStr, ...
                         datestr(dataset.loadTime, 'mm/dd HH:MM'));
    else
        infoStr = sprintf('%d batteries selected:\n\n', length(selected));
        for i = 1:min(length(selected), 8)
            infoStr = sprintf('%s• %s\n', infoStr, batteryData.datasets(selected(i)).name);
        end
        if length(selected) > 8
            infoStr = sprintf('%s... and %d more\n', infoStr, length(selected)-8);
        end
    end
    
    set(handles.infoText, 'String', infoStr);
    
    % Enable controls based on view type
    controls = getappdata(fig, 'controls');
    set(controls.socSlider, 'Enable', 'on');
    
    % Update plots
    updatePlotsComparator(fig);
end