function updatePlotsComparator(fig)
    % Main plotting function - updates existing plot objects
    %
    % This function coordinates plot updates without recreating graphics
    % objects, using the persistent handles set up by initializePersistentPlots.

    batteryData = getappdata(fig, 'batteryData');
    currentIdx = getappdata(fig, 'currentBatteryIdx');
    comparisonMode = getappdata(fig, 'comparisonMode');
    viewType = getappdata(fig, 'viewType');

    if isempty(currentIdx) || batteryData.count == 0
        return;
    end

    % Get current SOC value from slider
    controls = getappdata(fig, 'controls');
    socVals = getappdata(fig, 'socTickValues');
    socIdx = round(get(controls.socSlider, 'Value'));

    if ~isempty(socVals) && socIdx >= 1 && socIdx <= length(socVals)
        socValue = socVals(socIdx);
    else
        socValue = socIdx;  % Fallback to using index as value
    end

    % Plot based on view type and comparison mode
    if strcmp(viewType, 'eis')
        if strcmp(comparisonMode, 'overlay')
            plotEISOverlay(fig, currentIdx, socValue);
        else
            plotEISSideBySide(fig, currentIdx, socValue);
        end
    else
        if strcmp(comparisonMode, 'overlay')
            plotChargeOverlay(fig, currentIdx, socValue);
        else
            plotChargeSideBySide(fig, currentIdx, socValue);
        end
    end
end
