function plotEISOverlay(fig, batteryIndices, socValue)
    % Overlay EIS data from multiple batteries
    
    handles = getappdata(fig, 'handles');
    panel = handles.rightPanel;
    batteryData = getappdata(fig, 'batteryData');
    controls = getappdata(fig, 'controls');
    
    % Create or get axis
    ax = findobj(panel, 'Type', 'axes');
    if isempty(ax)
        ax = axes('Parent', panel, 'Position', [0.08 0.12 0.87 0.82]);
    else
        ax = ax(1);
    end
    cla(ax);
    
    hasData = false;
    xlimits = [Inf -Inf]; 
    ylimits = [Inf -Inf];
    % find global plot limits
    for i = 1:length(batteryIndices)
        dataset = batteryData.datasets(batteryIndices(i));
        
        if isempty(dataset.socEIScan)
            continue;
        end
        
        % Get scan
        validScans = find(dataset.socEIScan.ValidScans);
        [xlimits_i, ylimits_i] = calculateGlobalLimits(dataset.socEIScan, validScans);
        xlimits = [min(xlimits(1),xlimits_i(1)), max(xlimits(2),xlimits_i(2))];
        ylimits = [min(ylimits(1),ylimits_i(1)), max(ylimits(2),ylimits_i(2))];
    end
    [xlimits, ylimits] = nice_axis_limits(xlimits, ylimits);


    for i = 1:length(batteryIndices)
        dataset = batteryData.datasets(batteryIndices(i));
        
        if isempty(dataset.socEIScan)
            continue;
        end
        
        % Find closest SOC
        [~, socIdx] = min(abs(dataset.socEIScan.SOCPoints - socValue));
        actualSOC = dataset.socEIScan.SOCPoints(socIdx);
        
        % Get scan
        validScans = find(dataset.socEIScan.ValidScans);

        if socIdx > length(validScans)
            continue;
        end
        
        
        scanIdx = validScans(socIdx);
        scan = dataset.socEIScan.Scans{scanIdx};
        
        if isempty(scan) || ~isfield(scan, 'ImpedanceData')
            continue;
        end
        
        % Plot
        data = scan.ImpedanceData;
        plot(ax, data.Z_Real_Ohm, -data.Z_Imag_Ohm, '-+', ...
             'Color', dataset.color, 'LineWidth', 1,'DisplayName',sprintf('%s (%.1f%%)', dataset.name, actualSOC));
        hold(ax, 'on');
        
        % Add markers if requested
        if get(controls.showMarkersCheck, 'Value')
            addFrequencyMarkers(ax, data, dataset.color);
        end

        xlim(xlimits)
        ylim(ylimits)
        %legendEntries{end+1} = sprintf('%s (%.1f%%)', dataset.name, actualSOC);
        hasData = true;
    end
    
    if hasData
        xlabel(ax, 'Z_{real} (\Omega)', 'FontSize', 11);
        ylabel(ax, '-Z_{imag} (\Omega)', 'FontSize', 11);
        title(ax, sprintf('EIS Comparison - Target SOC: %.1f%%', socValue), ...
              'FontSize', 13);
        
        if get(controls.showLegendCheck, 'Value')
            legend(ax, 'Location', 'best', 'Interpreter', 'none');
        end
        
        if get(controls.gridCheck, 'Value')
            grid(ax, 'on');
            set(ax, 'GridLineStyle', ':');
        end
        

    else
        title(ax, 'No EIS data available at this SOC', 'FontSize', 13);
    end
end