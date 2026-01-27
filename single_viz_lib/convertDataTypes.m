function scanData = convertDataTypes(scanData)
    % Convert string values to appropriate data types
    
    % Measurement Information
    if isfield(scanData, 'MeasurementInfo')
        if isfield(scanData.MeasurementInfo, 'Timestamp')
            scanData.MeasurementInfo.Timestamp = datetime(scanData.MeasurementInfo.Timestamp, ...
                'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
        end
        numericFields = {'Target_SOC_Percent', 'Actual_SOC_Percent', 'Elapsed_Time_s', 'Battery_Voltage_V'};
        for i = 1:length(numericFields)
            if isfield(scanData.MeasurementInfo, numericFields{i})
                scanData.MeasurementInfo.(numericFields{i}) = ...
                    str2double(scanData.MeasurementInfo.(numericFields{i}));
            end
        end
    end
    
    % OCV Parameters - all numeric
    if isfield(scanData, 'OCVParams')
        fields = fieldnames(scanData.OCVParams);
        for i = 1:length(fields)
            scanData.OCVParams.(fields{i}) = str2double(scanData.OCVParams.(fields{i}));
        end
    end
    
    % OCV Results
    if isfield(scanData, 'OCVResults')
        if isfield(scanData.OCVResults, 'Final_Voltage_V')
            scanData.OCVResults.Final_Voltage_V = str2double(scanData.OCVResults.Final_Voltage_V);
        end
        if isfield(scanData.OCVResults, 'Data_Points')
            scanData.OCVResults.Data_Points = str2double(scanData.OCVResults.Data_Points);
        end
    end
    
    % GEIS Parameters - all numeric
    if isfield(scanData, 'GEISParams')
        fields = fieldnames(scanData.GEISParams);
        for i = 1:length(fields)
            scanData.GEISParams.(fields{i}) = str2double(scanData.GEISParams.(fields{i}));
        end
    end
    
    % GEIS Results
    if isfield(scanData, 'GEISResults')
        if isfield(scanData.GEISResults, 'Data_Points')
            scanData.GEISResults.Data_Points = str2double(scanData.GEISResults.Data_Points);
        end
    end
end