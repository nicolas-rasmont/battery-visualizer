% Add required library paths
addpath(genpath('shared_utils'));
addpath(genpath('baseline_comparator_lib_v2')); 

% Load data structures
% data1 = readBaseline('W:\batPhys\scripts\battery-visualizer\battery data\baseline_20250827_130120');
% data1.identifier='Series A';
% 
% data2 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\FullFinalBaseline");
% data2.identifier='Series B';
% 
% data3 = readBaseline('W:\batPhys\scripts\battery-visualizer\battery data\baseline_20250908_153759');
% data3.identifier='Series C';

% data4 = readBaseline('W:\batPhys\scripts\battery-visualizer\battery data\baseline_20250910_144342');
% data4.identifier='Series D';
% 
% data5 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\baseline_20250909_173140");
% data5.identifier='Series E';

% data6 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\baseline_20250923_100304");
% data6.identifier='Series F';
% 
% data7 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251002_162300");
% data7.identifier='Series G';
% 
% data8 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251003_144927");
% data8.identifier='Series H';
% 
% data9 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251003_153642");
% data9.identifier='Series I';
% 
% data10 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251003_164307");
% data10.identifier='Series J';
% 
% data11 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251003_173605");
% data11.identifier='Series K';
% 
% data12 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251003_175957");
% data12.identifier='Series L';
% 
% data13 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251021_101547");
% data13.identifier='Series M';
% 
% data14 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251021_104604");
% data14.identifier='Series N';
% 
% data15 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\temp_ramp_20251111_171004");
% data15.identifier='Series O';

% data16 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\baseline_20260114_122819");
% data16.identifier='Series P';
% 
% data17 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\BT_16_baseline_20260126_180202");
% data17.identifier='Series BT16';

data18 = readBaseline(".\battery data\BT17_baseline_20260115_154856");
data18.identifier='Series BT17';

% data19 = readBaseline("W:\batPhys\scripts\battery-visualizer\battery data\BT20_baseline_20260123_183439");
% data19.identifier='Series BT20';

% Launch comparison GUI
compareBaselineGUI(data18);

%compareThermalRampRunawayGUI(data15);