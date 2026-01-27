function SOCEIScan = consolidateData(SOCEIScan, allFrequencies, validScans)
    % Create consolidated data matrices for analysis
    
    numFreqs = length(allFrequencies);
    numValidScans = sum(validScans);
    validIndices = find(validScans);
    
    % Initialize matrices
    SOCEIScan.ConsolidatedData = struct();
    SOCEIScan.ConsolidatedData.Frequencies = sort(allFrequencies, 'descend');
    SOCEIScan.ConsolidatedData.SOCValues = SOCEIScan.SOCPoints(validScans);
    
    % Matrices for impedance data (SOC x Frequency)
    SOCEIScan.ConsolidatedData.Z_Real_Matrix = NaN(numValidScans, numFreqs);
    SOCEIScan.ConsolidatedData.Z_Imag_Matrix = NaN(numValidScans, numFreqs);
    SOCEIScan.ConsolidatedData.Z_Mag_Matrix = NaN(numValidScans, numFreqs);
    SOCEIScan.ConsolidatedData.Phase_Matrix = NaN(numValidScans, numFreqs);
    
    % Fill matrices
    for i = 1:numValidScans
        scanIdx = validIndices(i);
        scan = SOCEIScan.Scans{scanIdx};
        
        if ~isempty(scan) && isfield(scan, 'ImpedanceData')
            % Find frequency indices
            [~, freqIdx] = ismember(scan.ImpedanceData.Frequency_Hz, SOCEIScan.ConsolidatedData.Frequencies);
            validFreqIdx = freqIdx > 0;
            
            % Fill data
            SOCEIScan.ConsolidatedData.Z_Real_Matrix(i, freqIdx(validFreqIdx)) = ...
                scan.ImpedanceData.Z_Real_Ohm(validFreqIdx);
            SOCEIScan.ConsolidatedData.Z_Imag_Matrix(i, freqIdx(validFreqIdx)) = ...
                scan.ImpedanceData.Z_Imag_Ohm(validFreqIdx);
            SOCEIScan.ConsolidatedData.Z_Mag_Matrix(i, freqIdx(validFreqIdx)) = ...
                scan.ImpedanceData.Z_Mag_Ohm(validFreqIdx);
            SOCEIScan.ConsolidatedData.Phase_Matrix(i, freqIdx(validFreqIdx)) = ...
                scan.ImpedanceData.Phase_Deg(validFreqIdx);
        end
    end
    
    % Extract OCV vs SOC curve
    ocvValues = NaN(numValidScans, 1);
    for i = 1:numValidScans
        scanIdx = validIndices(i);
        scan = SOCEIScan.Scans{scanIdx};
        if ~isempty(scan) && isfield(scan, 'OCVResults') && isfield(scan.OCVResults, 'Final_Voltage_V')
            ocvValues(i) = scan.OCVResults.Final_Voltage_V;
        end
    end
    SOCEIScan.ConsolidatedData.OCV_Curve = ocvValues;
end