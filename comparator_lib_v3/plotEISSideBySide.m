function plotEISSideBySide(fig, batteryIndices, socValue)
    % Create side-by-side EIS plots
    
    handles = getappdata(fig, 'handles');
    panel = handles.rightPanel;
    batteryData = getappdata(fig, 'batteryData');
    controls = getappdata(fig, 'controls');
    
    % Clear panel
    delete(allchild(panel));
    
    n = length(batteryIndices);
    if n > 4
        n = 4;  % Limit to 4 plots
        batteryIndices = batteryIndices(1:4);
    end
    
    % Create subplots
    rows = ceil(n/2);
    cols = min(n, 2);
    
    for i = 1:n
        % Create axis
        row = ceil(i/2);
        col = mod(i-1, 2) + 1;
        
        left = 0.05 + (col-1) * 0.48;
        bottom = 0.95 - row * 0.45;
        ax = axes('Parent', panel, ...
                  'Position', [left bottom 0.42 0.38]);
        
        dataset = batteryData.datasets(batteryIndices(i));
        if ~isempty(dataset.socEIScan)
            % Find closest SOC
            [~, socIdx] = min(abs(dataset.socEIScan.SOCPoints - socValue));
            actualSOC = dataset.socEIScan.SOCPoints(socIdx);
            
            % Get scan
            validScans = find(dataset.socEIScan.ValidScans);
            [xlimits, ylimits] = calculateGlobalLimits(dataset.socEIScan, validScans);
            [xlimits, ylimits] = nice_axis_limits(xlimits, ylimits);
            if socIdx <= length(validScans)
                scanIdx = validScans(socIdx);
                scan = dataset.socEIScan.Scans{scanIdx};
                
                if ~isempty(scan) && isfield(scan, 'ImpedanceData')
                    % Plot
                    data = scan.ImpedanceData;
                    plot(ax, data.Z_Real_Ohm, -data.Z_Imag_Ohm, '-+', ...
                         'Color', dataset.color, 'LineWidth', 1);
                    hold(ax, 'on');
                    % Add markers if requested
                    if get(controls.showMarkersCheck, 'Value')
                        addFrequencyMarkers(ax, data, dataset.color);
                    end
                    
                    xlabel(ax, 'Z_{real} (\Omega)');
                    ylabel(ax, '-Z_{imag} (\Omega)');
                    title(ax, sprintf('%s (%.1f%%)', dataset.name, actualSOC), ...
                          'Interpreter', 'none', 'FontSize', 10);
                    
                    if get(controls.gridCheck, 'Value')
                        grid(ax, 'on');
                        set(ax, 'GridLineStyle', ':');
                    end
                    xlim(xlimits)
                    ylim(ylimits)
                end
            end
        else
            title(ax, sprintf('%s - No Data', dataset.name), ...
                  'Interpreter', 'none', 'FontSize', 10);
        end
    end
end