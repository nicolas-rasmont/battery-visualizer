function addBattery(fig)
    % Add a new battery dataset
    
    % Select folder
    folderPath = uigetdir('', 'Select Battery Data Folder');
    if folderPath == 0
        return;
    end
    
    % Get battery name from folder
    [~, folderName] = fileparts(folderPath);
    
    % Check if already loaded
    batteryData = getappdata(fig, 'batteryData');
    
    if batteryData.count > 0
        for i = 1:batteryData.count
            if strcmp(batteryData.datasets(i).folderPath, folderPath)
                msgbox('This battery dataset is already loaded.', 'Duplicate Dataset', 'warn');
                return;
            end
        end
    end
    
    % Load data with progress dialog
    h = waitbar(0, 'Loading battery data...', 'Name', 'Loading Dataset');
    
    % try
        % Load summary
        waitbar(0.2, h, 'Reading summary data...');
        batteryEIS = batteryEISSummaryReader(folderPath);
        
        if isempty(batteryEIS)
            error('Could not read summary.txt file');
        end
        
        % Load EIS scans
        waitbar(0.4, h, 'Reading EIS scans...');
        socEIScan = EISSOCScanReader(folderPath, batteryEIS);
        
        % Load charge data if available
        waitbar(0.7, h, 'Reading charge data...');
        chargeData = chargeDataReader(folderPath);
        
        % Create dataset structure
        waitbar(0.9, h, 'Organizing data...');
        newDataset = struct();
        newDataset.name = folderName;
        newDataset.folderPath = folderPath;
        newDataset.batteryEIS = batteryEIS;
        newDataset.socEIScan = socEIScan;
        newDataset.chargeData = chargeData;
        newDataset.color = getDatasetColor(fig, batteryData.count + 1);
        newDataset.loadTime = datetime('now');
        
        % Add to battery data
        batteryData.count = batteryData.count + 1;
        if batteryData.count == 1
            batteryData.datasets = newDataset;
        else
            batteryData.datasets(batteryData.count) = newDataset;
        end
        
        setappdata(fig, 'batteryData', batteryData);
        
        % Update UI
        updateBatteryList(fig);
        
        % Select the new battery
        handles = getappdata(fig, 'handles');
        set(handles.batteryListbox, 'Value', batteryData.count);
        updateSelection(fig);
        
        close(h);
        
        % Update status
        controls = getappdata(fig, 'controls');
        set(controls.statusText, 'String', ...
            sprintf('Successfully loaded: %s', folderName));
        
    % catch ME
    %     close(h);
    %     errordlg(sprintf('Error loading battery data: %s: %s',ME.identifier, ME.message), ...
    %             'Loading Error');
    % end
end