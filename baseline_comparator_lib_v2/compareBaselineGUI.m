function compareBaselineGUI(varargin)
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
    EISchargeData = struct('name', {}, 'charge', {}, 'xaxis', {});
    phase1dischargeData = struct('name', {}, 'charge', {}, 'xaxis', {});
    phase2chargeData = struct('name', {}, 'charge', {}, 'xaxis', {});
    phase4dischargeData = struct('name', {}, 'charge', {}, 'xaxis', {});
    
    % Define plot labels and titles
    indexorName = 'SoC (%)';
    Xtitle = 'Z_{real} (\Omega)';
    Ytitle = '-Z_{imag} (\Omega)';
    Plottitle = 'EIS comparison';
    
    % Process each input data structure
    for i = 1:nargin
        currentData = varargin{i};
        dataName = currentData.identifier;
        
        % Extract EIS curve data and metadata
        EISCurves(i).name = dataName;
        EISCurves(i).indexor = currentData.phase_3.ocv_vs_soc.SOC_Percent;
        
        % Extract charge data from Phase 3 (EIS measurements)
        EISchargeData(i).name = dataName;
        EISchargeData(i).charge = currentData.phase_3.charge_data;
        EISchargeData(i).xaxis = 'SOC_Percent';
        
        % Extract discharge data from Phase 1
        phase1dischargeData(i).name = dataName;
        phase1dischargeData(i).charge = currentData.phase_1.discharge_data;
        phase1dischargeData(i).xaxis = 'Time_s';
        
        % Extract combined charge/discharge data from Phase 2
        phase2chargeData(i).name = dataName;
        phase2chargeData(i).charge = [currentData.phase_2.charge_data; ...
                                     currentData.phase_2.discharge_data];
        phase2chargeData(i).xaxis = 'Time_s';
        
        % Extract discharge data from Phase 4
        phase4dischargeData(i).name = dataName;
        phase4dischargeData(i).charge = currentData.phase_4.discharge_data;
        phase4dischargeData(i).xaxis = 'Time_s';
        
        % Extract individual EIS measurement curves from Phase 3
        numEISMeasurements = currentData.summary.Phase3_EIS_Summary.Total_EIS_Measurements;
        
        for j = 1:numEISMeasurements
            eisMeasurement = currentData.phase_3.eis_measurements{j};
            impedanceData = eisMeasurement.Impedance_Data;
            
            % Store frequency, real impedance, and imaginary impedance
            EISCurves(i).curves{j} = [impedanceData.Frequency_Hz, ...
                                     impedanceData.Z_Real_Ohm, ...
                                     impedanceData.Z_Imag_Ohm];
        end
    end
    
    % Define GUI window positions [x, y, width, height]
    eisPosition = [100, 50, 700, 500];
    eisChargePosition = [800, 50, 700, 500];
    phase1Position = [800, 550, 700, 500];
    phase2Position = [100, 550, 700, 500];
    phase4Position = [100, 50, 700, 500];
    
    % Create GUI windows for different data visualizations
    chargeGUI(phase1dischargeData, 'Phase 1 discharge', 'Time (s)', phase1Position);
    chargeGUI(phase2chargeData, 'Phase 2 charge', 'Time (s)', phase2Position);
    chargeGUI(phase4dischargeData, 'Phase 4 discharge', 'Time (s)', phase4Position);
    curveFamilyGUI(EISCurves, indexorName, Plottitle, Xtitle, Ytitle, eisPosition);
    chargeGUI(EISchargeData, 'EIS charge', 'SOC (%)', eisChargePosition);
    
end