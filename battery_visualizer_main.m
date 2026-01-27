addpath(genpath('.\')) 
dataDirPath = 'C:\Users\CV166\Documents\LabWindowsCVI\BatteryTester\battery-tester\data\SOCEIS180Run';

BatteryEISSummary = batteryEISSummaryReader(dataDirPath);

% read all EIS scans
SOCEIScan = EISSOCScanReader(dataDirPath, BatteryEISSummary);

chargeData = chargeDataReader(dataDirPath);

% Access individual scan
scan50 = SOCEIScan.Scans{6};

% Plot Nyquist for all SOC
figure;
for i = 1:SOCEIScan.NumScans
    if ~isempty(SOCEIScan.Scans{i})
        scan = SOCEIScan.Scans{i};
        plot(scan.ImpedanceData.Z_Real_Ohm, -scan.ImpedanceData.Z_Imag_Ohm);
        hold on;
    end
end
xlabel('Z_{real} (Ohm)');
ylabel('-Z_{imag} (Ohm)');
title('Nyquist Plot at Various SOC');

% Launch the visualizer
%EISVisualizer(SOCEIScan);

% Launch visualizer with both EIS and charge data
EISVisualizerWithCharge(SOCEIScan, chargeData);


