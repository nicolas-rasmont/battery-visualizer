function loadSingleDataset(fig, folderPath, folderName)
    % Helper function to load a single dataset without UI interactions
    %
    % Inputs:
    %   fig - Figure handle
    %   folderPath - Full path to the battery data folder
    %   folderName - Name of the folder (used as dataset name)
    
    batteryData = getappdata(fig, 'batteryData');
    
    % Check if already loaded
    if batteryData.count > 0
        for i = 1:batteryData.count
            if strcmp(batteryData.datasets(i).folderPath, folderPath)
                return;  % Skip if already loaded
            end
        end
    end
    
    try
        % Load summary data
        batteryEIS = batteryEISSummaryReader(folderPath);
        
        if isempty(batteryEIS)
            warning('Could not read summary.txt in %s', folderName);
            return;
        end
        
        % Load EIS scans
        socEIScan = EISSOCScanReader(folderPath, batteryEIS);
        
        % Load charge data if available
        chargeData = chargeDataReader(folderPath);
        
        % Create dataset structure
        newDataset = struct();
        newDataset.name = folderName;
        newDataset.folderPath = folderPath;
        newDataset.batteryEIS = batteryEIS;
        newDataset.socEIScan = socEIScan;
        newDataset.chargeData = chargeData;
        newDataset.color = getDatasetColor(fig, batteryData.count + 1);
        newDataset.loadTime = datetime('now');
        
        % Calculate dataset statistics for quick reference
        if ~isempty(socEIScan)
            newDataset.stats.numValidScans = socEIScan.NumValidScans;
            newDataset.stats.socRange = [min(socEIScan.SOCPoints), max(socEIScan.SOCPoints)];
        else
            newDataset.stats.numValidScans = 0;
            newDataset.stats.socRange = [NaN, NaN];
        end
        
        if ~isempty(chargeData)
            newDataset.stats.hasChargeData = true;
            newDataset.stats.voltageRange = [chargeData.MinVoltage, chargeData.MaxVoltage];
            newDataset.stats.avgCurrent = chargeData.AvgCurrent;
        else
            newDataset.stats.hasChargeData = false;
            newDataset.stats.voltageRange = [NaN, NaN];
            newDataset.stats.avgCurrent = NaN;
        end
        
        % Add to battery data
        batteryData.count = batteryData.count + 1;
        if batteryData.count == 1
            batteryData.datasets = newDataset;
        else
            batteryData.datasets(batteryData.count) = newDataset;
        end
        
        setappdata(fig, 'batteryData', batteryData);
        
    catch ME
        warning('Error loading dataset %s: %s', folderName, ME.message);
    end
end