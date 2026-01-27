function removeBattery(fig)
    % Remove selected battery datasets
    
    handles = getappdata(fig, 'handles');
    batteryData = getappdata(fig, 'batteryData');
    
    selected = get(handles.batteryListbox, 'Value');
    if isempty(selected)
        return;
    end
    
    % Confirm deletion
    if length(selected) == 1
        msg = sprintf('Remove battery dataset "%s"?', batteryData.datasets(selected).name);
    else
        msg = sprintf('Remove %d battery datasets?', length(selected));
    end
    
    answer = questdlg(msg, 'Confirm Removal', 'Yes', 'No', 'No');
    if ~strcmp(answer, 'Yes')
        return;
    end
    
    % Remove datasets
    keepIdx = setdiff(1:batteryData.count, selected);
    if isempty(keepIdx)
        batteryData.datasets = [];
        batteryData.count = 0;
    else
        batteryData.datasets = batteryData.datasets(keepIdx);
        batteryData.count = length(keepIdx);
    end
    
    setappdata(fig, 'batteryData', batteryData);
    
    % Update UI
    set(handles.batteryListbox, 'Value', []);
    updateBatteryList(fig);
    updateSelection(fig);
end