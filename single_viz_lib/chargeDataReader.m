function chargeData = chargeDataReader(dataDirPath)
    % chargeDataReader - Reads battery charge data from charge.csv
    %
    % Syntax: chargeData = chargeDataReader(dataDirPath)
    %
    % Input:
    %   dataDirPath - Path to the directory containing charge.csv
    %
    % Output:
    %   chargeData - Structure containing charge curve data
    
    % Construct full file path
    filePath = fullfile(dataDirPath, 'charge.csv');
    
    % Check if file exists
    if ~exist(filePath, 'file')
        warning('charge.csv not found in directory: %s', dataDirPath);
        chargeData = [];
        return;
    end
    
    % Read CSV file
    try
        % Read the data with comma delimiter
        data = readtable(filePath, 'Delimiter', ',');
        
        % Clean column names (remove spaces if any)
        data.Properties.VariableNames = strrep(data.Properties.VariableNames, ' ', '');
        
        % Check if proper columns exist
        expectedCols = {'Time_s', 'Voltage_V', 'Current_A', 'Power_W', 'SOC_Percent'};
        if ~all(ismember(expectedCols, data.Properties.VariableNames))
            error('CSV file does not contain expected columns: %s', strjoin(expectedCols, ', '));
        end
        
        % Create output structure
        chargeData = struct();
        chargeData.Time_s = data.Time_s;
        chargeData.Voltage_V = data.Voltage_V;
        chargeData.Current_A = data.Current_A;
        chargeData.Power_W = data.Power_W;
        chargeData.SOC_Percent = data.SOC_Percent;
        chargeData.NumPoints = height(data);
        
        % Calculate additional useful metrics
        chargeData.Duration_h = chargeData.Time_s(end) / 3600;
        chargeData.MaxVoltage = max(chargeData.Voltage_V);
        chargeData.MinVoltage = min(chargeData.Voltage_V);
        chargeData.MaxCurrent = max(chargeData.Current_A);
        chargeData.MinCurrent = min(chargeData.Current_A);
        chargeData.AvgCurrent = mean(chargeData.Current_A);
        
    catch ME
        warning('Error reading charge.csv: %s', ME.message);
        chargeData = [];
    end
end