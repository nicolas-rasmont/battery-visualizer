function updatePlotsComparator(fig)
% Main plotting function

batteryData = getappdata(fig, 'batteryData');
currentIdx = getappdata(fig, 'currentBatteryIdx');
comparisonMode = getappdata(fig, 'comparisonMode');

viewType = getappdata(fig, 'viewType');

if isempty(currentIdx) || batteryData.count == 0 return; end
% Clear existing plots
clearPlots(fig);
% Get controls
controls = getappdata(fig, 'controls');
socValue = get(controls.socSlider, 'Value');
set(controls.socDisplay, 'String', sprintf('%.1f%%', socValue));

% Plot based on view type and comparison mode

if strcmp(viewType, 'eis')
    if strcmp(comparisonMode, 'overlay')
        plotEISOverlay(fig, currentIdx, socValue);
    else plotEISSideBySide(fig, currentIdx, socValue);
    end
else
    if strcmp(comparisonMode, 'overlay')
        plotChargeOverlay(fig, currentIdx, socValue);
    else plotChargeSideBySide(fig, currentIdx, socValue);
    end
end
end