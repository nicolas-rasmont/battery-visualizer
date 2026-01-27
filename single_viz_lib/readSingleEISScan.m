function scanData = readSingleEISScan(filePath, targetSOC)
    % Read a single EIS scan file
    
    scanData = struct();
    scanData.TargetSOC = targetSOC;
    scanData.FileName = filePath;
    
    fid = fopen(filePath, 'r');
    if fid == -1
        error('Could not open file: %s', filePath);
    end
    
    try
        currentSection = '';
        impedanceData = [];
        
        while ~feof(fid)
            line = fgetl(fid);
            
            % Skip empty lines
            if isempty(line) || strcmp(line, -1)
                continue;
            end
            
            % Check for section headers
            if startsWith(line, '[') && endsWith(line, ']')
                currentSection = line(2:end-1);
                continue;
            end
            
            % Parse based on current section
            switch currentSection
                case 'Measurement_Information'
                    parseKeyValueToStruct(line, scanData, 'MeasurementInfo');
                    
                case 'OCV_Parameters'
                    parseKeyValueToStruct(line, scanData, 'OCVParams');
                    
                case 'OCV_Results'
                    parseKeyValueToStruct(line, scanData, 'OCVResults');
                    
                case 'GEIS_Parameters'
                    parseKeyValueToStruct(line, scanData, 'GEISParams');
                    
                case 'GEIS_Results'
                    parseKeyValueToStruct(line, scanData, 'GEISResults');
                    
                case 'Impedance_Data'
                    % Skip header line
                    if contains(line, 'Frequency_Hz')
                        continue;
                    end
                    % Parse impedance data
                    values = str2double(strsplit(line, ','));
                    if ~any(isnan(values)) && length(values) == 5
                        impedanceData = [impedanceData; values];
                    end
            end
        end
        
        % Convert data types
        scanData = convertDataTypes(scanData);
        
        % Store impedance data
        if ~isempty(impedanceData)
            scanData.ImpedanceData = struct();
            scanData.ImpedanceData.Frequency_Hz = impedanceData(:, 1);
            scanData.ImpedanceData.Z_Real_Ohm = impedanceData(:, 2);
            scanData.ImpedanceData.Z_Imag_Ohm = impedanceData(:, 3);
            scanData.ImpedanceData.Z_Mag_Ohm = impedanceData(:, 4);
            scanData.ImpedanceData.Phase_Deg = impedanceData(:, 5);
            
            % Calculate derived quantities
            scanData.ImpedanceData.Z_Complex = complex(impedanceData(:, 2), impedanceData(:, 3));
            
            % Create table for convenience
            scanData.ImpedanceTable = array2table(impedanceData, ...
                'VariableNames', {'Frequency_Hz', 'Z_Real_Ohm', 'Z_Imag_Ohm', 'Z_Mag_Ohm', 'Phase_Deg'});
        end
        
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    
    fclose(fid);
end