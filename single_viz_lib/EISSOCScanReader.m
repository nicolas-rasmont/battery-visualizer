function SOCEIScan = EISSOCScanReader(dataDirPath, BatteryEISSummary)
    % EISSOCScanReader - Reads individual EIS scan files for each SOC point
    %
    % Syntax: SOCEIScan = EISSOCScanReader(dataDirPath, BatteryEISSummary)
    %
    % Inputs:
    %   dataDirPath - Path to the directory containing details_XXX.txt files
    %   BatteryEISSummary - Structure from batteryEISReader with SOC points
    %
    % Output:
    %   SOCEIScan - Structure containing all EIS scans at various SOC levels
    
    % Check inputs
    if ~isfield(BatteryEISSummary, 'Measurements') || ...
       ~isfield(BatteryEISSummary.Measurements, 'SOC_Points')
        error('BatteryEISSummary must contain Measurements.SOC_Points field');
    end
    
    % Get SOC points
    socPoints = BatteryEISSummary.Measurements.SOC_Points;
    numScans = length(socPoints);
    
    % Initialize output structure
    SOCEIScan = struct();
    SOCEIScan.NumScans = numScans;
    SOCEIScan.SOCPoints = socPoints;
    SOCEIScan.Scans = cell(numScans, 1);
    
    % Arrays to collect common data across all scans
    allFrequencies = [];
    validScans = false(numScans, 1);
    
    % Read each SOC scan file
    for i = 1:numScans
        soc = socPoints(i);
        
        % Construct filename - handle only integer SOC values
        filename = sprintf('details_%02d.txt', round(soc));
     
        filePath = fullfile(dataDirPath, filename);
        
        % Check if file exists
        if ~exist(filePath, 'file')
            warning('File not found: %s (SOC = %.1f%%)', filename, soc);
            SOCEIScan.Scans{i} = [];
            continue;
        end
        
        % Read and parse the file
        try
            scanData = readSingleEISScan(filePath, soc);
            SOCEIScan.Scans{i} = scanData;
            validScans(i) = true;
            
            % Collect frequency points for later analysis
            if ~isempty(scanData.ImpedanceData)
                allFrequencies = union(allFrequencies, scanData.ImpedanceData.Frequency_Hz);
            end
        catch ME
            warning('Error reading %s: %s', filename, ME.message);
            SOCEIScan.Scans{i} = [];
        end
    end
    
    % Create consolidated data matrices for easier analysis
    if any(validScans)
        SOCEIScan = consolidateData(SOCEIScan, allFrequencies, validScans);
    end
    
    % Add summary statistics
    SOCEIScan.ValidScans = validScans;
    SOCEIScan.NumValidScans = sum(validScans);
    SOCEIScan.MissingScans = socPoints(~validScans);
end