function updatePlots(fig)
    % Update both Nyquist and charge plots
    
    SOCEIScan = getappdata(fig, 'SOCEIScan');
    chargeData = getappdata(fig, 'chargeData');
    validIdx = getappdata(fig, 'validIdx');
    handles = getappdata(fig, 'handles');
    axes_handles = getappdata(fig, 'axes');
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
    
    % Build info text
    infoStr = '';
    if isfield(currentScan, 'MeasurementInfo')
        info = currentScan.MeasurementInfo;
        infoStr = sprintf('OCV: %.3f V | Battery V: %.3f V | Actual SOC: %.1f%%', ...
                         currentScan.OCVResults.Final_Voltage_V, ...
                         info.Battery_Voltage_V, ...
                         info.Actual_SOC_Percent);
    end
    
    % Add charge info if available
    if ~isempty(chargeData)
        [~, chargeIdx] = min(abs(chargeData.SOC_Percent - currentSOC));
        chargeV = chargeData.Voltage_V(chargeIdx);
        chargeI = chargeData.Current_A(chargeIdx);
        infoStr = sprintf('%s | Charge: %.3f V @ %.2f A', infoStr, chargeV, chargeI);
    end
    
    set(handles.infoText, 'String', infoStr);
    
    % Check modes
    compareMode = get(handles.compareCheck, 'Value');
    showFreqMarkers = get(handles.freqCheck, 'Value');
    
    % Update Nyquist plot
    if length(axes_handles) > 1
        ax1 = axes_handles(1);
        ax2 = axes_handles(2);
        ax3 = axes_handles(3);
    else
        ax1 = axes_handles;
        ax2 = [];
        ax3 = [];
    end
    
    if ~compareMode
        % Clear and plot current data only
        cla(ax1);
        plotSingleNyquist(ax1, currentScan, currentSOC, 'b', showFreqMarkers, true);
        
        % Update charge plot if exists
        if ~isempty(ax2) && ~isempty(chargeData)
            updateChargePlot(ax2, ax3, chargeData, currentSOC, [], fig);
        end
    else
        % Compare mode
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
        cla(ax1);
        comparisonSOCs = [];
        for i = 1:length(comparisonData)
            plotSingleNyquist(ax1, comparisonData(i).Scan, ...
                             comparisonData(i).SOC, comparisonData(i).Color, ...
                             showFreqMarkers && i == length(comparisonData), ...
                             i == 1);
            comparisonSOCs(i) = comparisonData(i).SOC;
        end
        
        % Add legend
        legendEntries = arrayfun(@(x) sprintf('SOC = %.1f%%', x.SOC), ...
                                comparisonData, 'UniformOutput', false);
        legend(ax1, legendEntries, 'Location', 'best', 'FontSize', 9);
        
        % Update charge plot with all comparison SOCs
        if ~isempty(ax2) && ~isempty(chargeData)
            updateChargePlot(ax2, ax3, chargeData, currentSOC, comparisonSOCs, fig);
        end
    end
    
    % Maintain fixed axis limits
    xlim(ax1, xlimits);
    ylim(ax1, ylimits);
    grid(ax1, 'on');
    set(ax1, 'GridLineStyle', ':');
end