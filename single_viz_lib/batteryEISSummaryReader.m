function BatteryEISSummary = batteryEISSummaryReader(dataDirPath)
    % batteryEISSummaryReader - Reads battery EIS test summary data from summary.txt
    %
    % Syntax: BatteryEISSummary = batteryEISSummaryReader(dataDirPath)
    %
    % Input:
    %   dataDirPath - Path to the directory containing summary.txt
    %
    % Output:
    %   BatteryEISSummary - Structure containing parsed battery EIS summary data
    
    % Construct full file path
    filePath = fullfile(dataDirPath, 'summary.txt');
    
    % Check if file exists
    if ~exist(filePath, 'file')
        error('File summary.txt not found in directory: %s', dataDirPath);
    end
    
    % Initialize structure
    BatteryEISSummary = struct();
    
    % Open and read file
    fid = fopen(filePath, 'r');
    if fid == -1
        error('Could not open file: %s', filePath);
    end
    
    try
        % Read file line by line
        currentSection = '';
        impedanceData = [];
        
        while ~feof(fid)
            line = fgetl(fid);
            
            % Skip empty lines and comments (except impedance header)
            if isempty(line) || (startsWith(line, '#') && ~contains(line, 'SOC_%'))
                continue;
            end
            
            % Check for section headers
            if startsWith(line, '[') && endsWith(line, ']')
                currentSection = line(2:end-1);  % Remove brackets
                continue;
            end
            
            % Parse based on current section
            switch currentSection
                case 'Test_Information'
                    parseKeyValue(line, 'BatteryEISSummary.TestInfo');
                    
                case 'Test_Parameters'
                    parseKeyValue(line, 'BatteryEISSummary.TestParams');
                    
                case 'Measurements'
                    parseKeyValue(line, 'BatteryEISSummary.Measurements');
                    
                case 'Impedance_Summary'
                    % Check if this is the header line
                    if contains(line, 'SOC_%')
                        continue;  % Skip header
                    end
                    % Parse impedance data
                    values = str2double(strsplit(line, ','));
                    if ~any(isnan(values))
                        impedanceData = [impedanceData; values];
                    end
            end
        end
        
        % Process collected data
        
        % Convert Test Information fields
        if isfield(BatteryEISSummary, 'TestInfo')
            if isfield(BatteryEISSummary.TestInfo, 'Start_Time')
                BatteryEISSummary.TestInfo.Start_Time = datetime(BatteryEISSummary.TestInfo.Start_Time, ...
                    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
            end
            if isfield(BatteryEISSummary.TestInfo, 'End_Time')
                BatteryEISSummary.TestInfo.End_Time = datetime(BatteryEISSummary.TestInfo.End_Time, ...
                    'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
            end
            if isfield(BatteryEISSummary.TestInfo, 'Total_Duration_Hour')
                BatteryEISSummary.TestInfo.Total_Duration_h = str2double(BatteryEISSummary.TestInfo.Total_Duration_h);
            end
            if isfield(BatteryEISSummary.TestInfo, 'Battery_Capacity_mAh')
                BatteryEISSummary.TestInfo.Battery_Capacity_mAh = str2double(BatteryEISSummary.TestInfo.Battery_Capacity_mAh);
            end
            if isfield(BatteryEISSummary.TestInfo, 'EIS_Interval_Percent')
                BatteryEISSummary.TestInfo.EIS_Interval_Percent = str2double(BatteryEISSummary.TestInfo.EIS_Interval_Percent);
            end
        end
        
        % Convert Test Parameters fields (all numeric)
        if isfield(BatteryEISSummary, 'TestParams')
            fields = fieldnames(BatteryEISSummary.TestParams);
            for i = 1:length(fields)
                BatteryEISSummary.TestParams.(fields{i}) = str2double(BatteryEISSummary.TestParams.(fields{i}));
            end
        end
        
        % Convert Measurements fields
        if isfield(BatteryEISSummary, 'Measurements')
            if isfield(BatteryEISSummary.Measurements, 'Total_Measurements')
                BatteryEISSummary.Measurements.Total_Measurements = str2double(BatteryEISSummary.Measurements.Total_Measurements);
            end
            if isfield(BatteryEISSummary.Measurements, 'SOC_Points')
                BatteryEISSummary.Measurements.SOC_Points = str2double(strsplit(BatteryEISSummary.Measurements.SOC_Points, ','));
            end
        end
        
        % Store impedance data
        if ~isempty(impedanceData)
            BatteryEISSummary.ImpedanceData.SOC_Percent = impedanceData(:, 1);
            BatteryEISSummary.ImpedanceData.OCV_V = impedanceData(:, 2);
            BatteryEISSummary.ImpedanceData.Z_100kHz_Ohm = impedanceData(:, 3);
            BatteryEISSummary.ImpedanceData.Z_10Hz_Ohm = impedanceData(:, 4);
            
            % Also create a table for easier viewing
            BatteryEISSummary.ImpedanceTable = array2table(impedanceData, ...
                'VariableNames', {'SOC_Percent', 'OCV_V', 'Z_100kHz_Ohm', 'Z_10Hz_Ohm'});
        end
        
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    
    fclose(fid);
    
    % Nested function to parse key-value pairs
    function parseKeyValue(line, structPath)
        parts = strsplit(line, '=');
        if length(parts) == 2
            key = strtrim(parts{1});
            value = strtrim(parts{2});
            eval([structPath '.' key ' = value;']);
        end
    end
end