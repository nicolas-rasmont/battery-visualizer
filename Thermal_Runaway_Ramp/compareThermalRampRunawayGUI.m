function compareThermalRampRunawayGUI(varargin)
% COMPAREBASELINEGUI Creates multiple GUI windows to compare baseline battery test data
%
% USAGE: compareBaselineGUI(data1, data2, ...)
%
% INPUTS:
%   varargin - Variable number of data structures containing battery test results
%              Each structure should contain phases 1-4 with various measurements
%
% OUTPUTS:
%   Multiple GUI windows displaying:
%   - EIS curve families
%   - Charge data from different test phases
%   - Discharge data from different test phases

    % Initialize data structures for different measurement types
    EISCurves = struct('name', {}, 'curves', {}, 'indexor', {});
    EISThermalData = struct('name', {}, 'temperature_profile', {}, 'xaxis', {});
    
    % Define plot labels and titles
    indexorName = 'Temperature (C)';
    Xtitle = 'Z_{real} (\Omega)';
    Ytitle = '-Z_{imag} (\Omega)';
    Plottitle = 'EIS comparison';
    
    % Process each input data structure
    for i = 1:nargin
        currentData = varargin{i};
        dataName = currentData.identifier;
        
        % Extract EIS curve data and metadata
        EISCurves(i).name = dataName;
        EISCurves(i).indexor = currentData.summary.EIS_Measurements.Temperatures;
        
        % Extract charge data from Phase 3 (EIS measurements)
        EISThermalData(i).name = dataName;
        EISThermalData(i).temperature_profile = currentData.temperature_profile;
        EISThermalData(i).xaxis = 'Time_s';
        
        % Extract individual EIS measurement curves from Phase 3
        %numEISMeasurements = currentData.summary.EIS_Measurements.Total_Measurements;
        length(currentData.eis_measurements)
        for j = 1:length(currentData.eis_measurements)
            eisMeasurement = currentData.eis_measurements{j};
            impedanceData = eisMeasurement.Impedance_Data;
            
            % Store frequency, real impedance, and imaginary impedance
            EISCurves(i).curves{j} = [impedanceData.Frequency_Hz, ...
                                     impedanceData.Z_Real_Ohm, ...
                                     impedanceData.Z_Imag_Ohm];
        end
    end
    
    % Define GUI window positions [x, y, width, height]
    eisPosition = [100, 50, 700, 500];
    eisThermalPosition = [800, 50, 700, 500];
    
    % Create GUI windows for different data visualizations
    curveFamilyGUI(EISCurves, indexorName, Plottitle, Xtitle, Ytitle, eisPosition);
    Thermal_RampGUI(EISThermalData, 'EIS Temperature (C)', 'Time (s)', eisThermalPosition);
    
end