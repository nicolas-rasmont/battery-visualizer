function updatePlot(fig)
    % Update Nyquist plot based on current slider position
    
    SOCEIScan = getappdata(fig, 'SOCEIScan');
    validIdx = getappdata(fig, 'validIdx');
    handles = getappdata(fig, 'handles');
    ax = getappdata(fig, 'mainAxis');
    xlimits = getappdata(fig, 'xlimits');
    ylimits = getappdata(fig, 'ylimits');
    
    % Get current index
    sliderValue = round(get(handles.slider, 'Value'));
    scanIdx = validIdx(sliderValue);
    setappdata(fig, 'currentIdx', sliderValue);
    
    % Get current scan data
    currentScan = SOCEIScan.Scans{scanIdx};
    if isempty(currentScan) || ~isfield(currentScan, 'ImpedanceData')
        return;
    end
    
    % Update SOC display
    currentSOC = SOCEIScan.SOCPoints(scanIdx);
    set(handles.socDisplay, 'String', sprintf('%.1f%%', currentSOC));
    
    % Update info text
    if isfield(currentScan, 'MeasurementInfo')
        info = currentScan.MeasurementInfo;
        infoStr = sprintf('OCV: %.3f V | Battery Voltage: %.3f V | Actual SOC: %.1f%% | Time: %s', ...
                         currentScan.OCVResults.Final_Voltage_V, ...
                         info.Battery_Voltage_V, ...
                         info.Actual_SOC_Percent, ...
                         datestr(info.Timestamp, 'yyyy-mm-dd HH:MM:SS'));
        set(handles.infoText, 'String', infoStr);
    end
    
    % Check compare mode
    compareMode = get(handles.compareCheck, 'Value');
    showFreqMarkers = get(handles.freqCheck, 'Value');
    
    if ~compareMode
        % Clear axis and plot current data only
        cla(ax);
        plotSingleScan(ax, currentScan, currentSOC, 'b', showFreqMarkers, true);  
    else
        % Add to comparison
        comparisonData = getappdata(fig, 'comparisonData');
        
        % Check if this SOC is already in comparison
        alreadyExists = false;
        if ~isempty(comparisonData)
            existingSOCs = [comparisonData.SOC];
            alreadyExists = any(abs(existingSOCs - currentSOC) < 0.1);
        end
        
        if ~alreadyExists
            newEntry = struct('SOC', currentSOC, ...
                            'Scan', currentScan, ...
                            'Color', getNextColor(length(comparisonData) + 1));
            comparisonData = [comparisonData, newEntry];
            setappdata(fig, 'comparisonData', comparisonData);
            set(handles.clearBtn, 'Enable', 'on');
        end
        
        % Replot all comparison data
        cla(ax);
        for i = 1:length(comparisonData)
            plotSingleScan(ax, comparisonData(i).Scan, ...
                          comparisonData(i).SOC, comparisonData(i).Color, ...
                          showFreqMarkers && i == length(comparisonData), ...
                          i == 1);
        end
        
        % Add legend
        legendEntries = arrayfun(@(x) sprintf('SOC = %.1f%%', x.SOC), ...
                                comparisonData, 'UniformOutput', false);
        legend(ax, legendEntries, 'Location', 'best', 'FontSize', 9);
    end
    
    % Always maintain the same axis limits
    xlim(ax, xlimits);
    ylim(ax, ylimits);
    
    % Ensure grid is on
    grid(ax, 'on');
    set(ax, 'GridLineStyle', ':');
end