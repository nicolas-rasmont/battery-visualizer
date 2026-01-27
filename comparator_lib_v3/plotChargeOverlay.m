function plotChargeOverlay(fig, batteryIndices, socValue)
    % Overlay charge diagrams from multiple batteries
    
    handles = getappdata(fig, 'handles');
    panel = handles.rightPanel;
    batteryData = getappdata(fig, 'batteryData');
    controls = getappdata(fig, 'controls');
    
    % Clear panel and create dual y-axis
    delete(allchild(panel));
    
    % Create voltage axis (left)
    ax1 = axes('Parent', panel, ...
               'Position', [0.08 0.12 0.82 0.82], ...
               'Box', 'on');
    
    ylabel(ax1, 'Voltage (V)', 'FontSize', 11, 'Color', [0 0 0.8]);
    xlabel(ax1, 'SOC (%)', 'FontSize', 11);
    set(ax1, 'YColor', [0 0 0.8]);
    hold(ax1, 'on');
    
    % Create current axis (right)
    ax2 = axes('Parent', panel, ...
               'Position', ax1.Position, ...
               'Color', 'none', ...
               'YAxisLocation', 'right', ...
               'XAxisLocation', 'bottom', ...
               'Box', 'off');
    ylabel(ax2, 'Current (A)', 'FontSize', 11, 'Color', [0.8 0 0]);
    set(ax2, 'YColor', [0.8 0 0]);
    set(ax2, 'XTick', []);
    hold(ax2, 'on');
    
    legendEntriesV = {};
    legendEntriesI = {};
    hasData = false;
    
    for i = 1:length(batteryIndices)
        dataset = batteryData.datasets(batteryIndices(i));
        
        if isempty(dataset.chargeData)
            continue;
        end
        
        % Plot voltage
        plot(ax1, dataset.chargeData.SOC_Percent, dataset.chargeData.Voltage_V, ...
             '.', 'Color', dataset.color, 'LineWidth', 1, 'DisplayName',sprintf('%s (V)', dataset.name));
        
        % Plot current
        plot(ax2, dataset.chargeData.SOC_Percent, dataset.chargeData.Current_A, ...
             '+', 'Color', dataset.color, 'LineWidth', 1,'DisplayName',sprintf('%s (I)', dataset.name));
        
        % Add SOC marker if requested
        if get(controls.socMarkerCheck, 'Value')
            [~, idx] = min(abs(dataset.chargeData.SOC_Percent - socValue));
            plot(ax1, dataset.chargeData.SOC_Percent(idx), ...
                 dataset.chargeData.Voltage_V(idx), 'o', ...
                 'Color', dataset.color, 'MarkerSize', 8, ...
                 'MarkerFaceColor', dataset.color,'HandleVisibility', 'off','Tag','SOCMarker');
            plot(ax2, dataset.chargeData.SOC_Percent(idx), ...
                 dataset.chargeData.Current_A(idx), 's', ...
                 'Color', dataset.color, 'MarkerSize', 6, ...
                 'MarkerFaceColor', dataset.color,'HandleVisibility', 'off','Tag','SOCMarker');
        end
        
        hasData = true;
    end
    
    if hasData
        title(ax1, 'Charge Diagram Comparison', 'FontSize', 13);
        
        % Set limits
        xlim(ax1, [0 max(180, socValue+20)]);
        xlim(ax2, [0 max(180, socValue+20)]);
        
        if get(controls.showLegendCheck, 'Value')
            legend(ax1, 'Location', 'northwest', ...
                   'Interpreter', 'none', 'FontSize', 9);
        end
        
        if get(controls.gridCheck, 'Value')
            grid(ax1, 'on');
            set(ax1, 'GridLineStyle', ':');
        end
    else
        title(ax1, 'No charge data available', 'FontSize', 13);
    end
end
