function batchImport(fig)
    % Import multiple battery datasets at once from a parent folder
    
    % Select parent folder containing multiple battery dataset folders
    parentFolder = uigetdir('', 'Select Parent Folder Containing Battery Datasets');
    if parentFolder == 0
        return;
    end
    
    % Find all subdirectories
    subfolders = dir(parentFolder);
    subfolders = subfolders([subfolders.isdir]);
    subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'}));
    
    if isempty(subfolders)
        msgbox('No subdirectories found in selected folder.', 'No Data', 'warn');
        return;
    end
    
    % Check for valid battery data folders (contain summary.txt)
    validFolders = {};
    for i = 1:length(subfolders)
        folderPath = fullfile(parentFolder, subfolders(i).name);
        if exist(fullfile(folderPath, 'summary.txt'), 'file')
            validFolders{end+1} = subfolders(i).name;
        end
    end
    
    if isempty(validFolders)
        msgbox('No valid battery datasets found (folders must contain summary.txt).', ...
               'No Valid Data', 'warn');
        return;
    end
    
    % Confirm batch import
    answer = questdlg(sprintf('Found %d valid battery datasets. Import all?', ...
                              length(validFolders)), ...
                      'Confirm Batch Import', 'Yes', 'No', 'Yes');
    if ~strcmp(answer, 'Yes')
        return;
    end
    
    % Progress dialog
    h = waitbar(0, 'Starting batch import...', 'Name', 'Batch Import Progress');
    successCount = 0;
    failedFolders = {};
    skippedFolders = {};
    
    % Get current battery data to check for duplicates
    batteryData = getappdata(fig, 'batteryData');
    existingPaths = {};
    if batteryData.count > 0
        existingPaths = {batteryData.datasets.folderPath};
    end
    
    % Process each valid folder
    for i = 1:length(validFolders)
        folderName = validFolders{i};
        folderPath = fullfile(parentFolder, folderName);
        
        % Update progress
        waitbar(i/length(validFolders), h, ...
               sprintf('Loading %s (%d/%d)...', folderName, i, length(validFolders)));
        
        % Check if already loaded
        if ismember(folderPath, existingPaths)
            skippedFolders{end+1} = folderName;
            continue;
        end
        
        try
            % Load the dataset
            loadSingleDataset(fig, folderPath, folderName);
            
            % Check if it was actually added (loadSingleDataset might skip)
            newBatteryData = getappdata(fig, 'batteryData');
            if newBatteryData.count > batteryData.count
                successCount = successCount + 1;
                batteryData = newBatteryData;  % Update local copy
            else
                failedFolders{end+1} = folderName;
            end
            
        catch ME
            failedFolders{end+1} = sprintf('%s (%s)', folderName, ME.message);
        end
        
        % Allow GUI to update
        drawnow;
    end
    
    close(h);
    
    % Update battery list display
    updateBatteryList(fig);
    
    % Prepare summary message
    msg = sprintf('Batch import complete!\n\n');
    msg = sprintf('%s✓ Successfully loaded: %d datasets\n', msg, successCount);
    
    if ~isempty(skippedFolders)
        msg = sprintf('%s⊘ Skipped (already loaded): %d datasets\n', msg, length(skippedFolders));
        if length(skippedFolders) <= 3
            msg = sprintf('%s   %s\n', msg, strjoin(skippedFolders, ', '));
        else
            msg = sprintf('%s   %s, ... and %d more\n', msg, ...
                         strjoin(skippedFolders(1:3), ', '), length(skippedFolders)-3);
        end
    end
    
    if ~isempty(failedFolders)
        msg = sprintf('%s✗ Failed to load: %d datasets\n', msg, length(failedFolders));
        if length(failedFolders) <= 3
            for j = 1:length(failedFolders)
                msg = sprintf('%s   - %s\n', msg, failedFolders{j});
            end
        else
            for j = 1:3
                msg = sprintf('%s   - %s\n', msg, failedFolders{j});
            end
            msg = sprintf('%s   ... and %d more\n', msg, length(failedFolders)-3);
        end
    end
    
    % Show summary
    msgbox(msg, 'Batch Import Summary', 'help');
    
    % Update status bar
    controls = getappdata(fig, 'controls');
    if isfield(controls, 'statusText')
        set(controls.statusText, 'String', ...
            sprintf('Batch import: %d loaded, %d skipped, %d failed', ...
                    successCount, length(skippedFolders), length(failedFolders)));
    end
    
    % Auto-select all newly loaded datasets if some were loaded
    if successCount > 0
        handles = getappdata(fig, 'handles');
        batteryData = getappdata(fig, 'batteryData');
        
        % Select the newly loaded datasets
        startIdx = batteryData.count - successCount + 1;
        newIndices = startIdx:batteryData.count;
        set(handles.batteryListbox, 'Value', newIndices);
        updateSelection(fig);
    end
end