function updateBatteryList(fig)
    % Update the battery listbox display
    
    handles = getappdata(fig, 'handles');
    batteryData = getappdata(fig, 'batteryData');
    
    if batteryData.count == 0
        set(handles.batteryListbox, 'String', {});
        return;
    end
    
    % Create list with battery names and status
    listItems = cell(batteryData.count, 1);
    for i = 1:batteryData.count
        dataset = batteryData.datasets(i);
        capacity = '';
        if isfield(dataset.batteryEIS, 'TestInfo') && ...
           isfield(dataset.batteryEIS.TestInfo, 'Battery_Capacity_mAh')
            capacity = sprintf(' (%.0f mAh)', dataset.batteryEIS.TestInfo.Battery_Capacity_mAh);
        end
        
        % Check data availability
        hasCharge = ~isempty(dataset.chargeData);
        if hasCharge
            chargeIcon = '●';
        else
            chargeIcon = '○';
        end
        
        listItems{i} = sprintf('[%s] %s%s', chargeIcon, dataset.name, capacity);
    end
    
    set(handles.batteryListbox, 'String', listItems);
end