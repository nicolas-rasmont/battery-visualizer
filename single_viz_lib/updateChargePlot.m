function updateChargePlot(ax2, ax3, chargeData, currentSOC, comparisonSOCs, fig)
    % Update the charge plot with SOC markers for both voltage and current
    
    % Clear previous markers
    socMarkers = getappdata(fig, 'socMarkers');
    if ~isempty(socMarkers)
        delete(socMarkers(ishandle(socMarkers)));
    end
    
    % Clear and replot voltage curve
    cla(ax2);
    hold(ax2, 'on');
    plot(ax2, chargeData.SOC_Percent, chargeData.Voltage_V, 'b.');
    
    % Clear and replot current curve
    cla(ax3);
    hold(ax3, 'on');
    plot(ax3, chargeData.SOC_Percent, chargeData.Current_A, 'r.');
    
    newMarkers = [];
    
    % Plot markers
    if ~isempty(comparisonSOCs)
        % Multiple SOC markers in compare mode
        comparisonData = getappdata(fig, 'comparisonData');
        for i = 1:length(comparisonSOCs)
            soc = comparisonSOCs(i);
            [~, idx] = min(abs(chargeData.SOC_Percent - soc));
            voltage = chargeData.Voltage_V(idx);
            current = chargeData.Current_A(idx);
            
            % Voltage marker
            h1 = plot(ax2, soc, voltage, 'o', ...
                     'Color', comparisonData(i).Color, ...
                     'MarkerSize', 10, ...
                     'MarkerFaceColor', comparisonData(i).Color);
            
            % Current marker
            h2 = plot(ax3, soc, current, 's', ...
                     'Color', comparisonData(i).Color, ...
                     'MarkerSize', 8, ...
                     'MarkerFaceColor', comparisonData(i).Color);
            
            newMarkers = [newMarkers, h1, h2];
        end
    else
        % Single SOC marker
        [~, idx] = min(abs(chargeData.SOC_Percent - currentSOC));
        voltage = chargeData.Voltage_V(idx);
        current = chargeData.Current_A(idx);
        
        % Voltage marker with lines
        h1 = plot(ax2, currentSOC, voltage, 'bo', ...
                 'MarkerSize', 12, ...
                 'MarkerFaceColor', 'b');
        h2 = plot(ax2, [currentSOC currentSOC], [min(chargeData.Voltage_V) voltage], ...
                 'b--', 'LineWidth', 1, 'Color', [0 0 0.8 0.5]);
        h3 = plot(ax2, [0 currentSOC], [voltage voltage], ...
                 'b--', 'LineWidth', 1, 'Color', [0 0 0.8 0.5]);
        
        % Current marker with lines
        h4 = plot(ax3, currentSOC, current, 'rs', ...
                 'MarkerSize', 10, ...
                 'MarkerFaceColor', 'r');
        h5 = plot(ax3, [currentSOC currentSOC], [0 current], ...
                 'r--', 'LineWidth', 1, 'Color', [0.8 0 0 0.5]);
        h6 = plot(ax3, [0 currentSOC], [current current], ...
                 'r--', 'LineWidth', 1, 'Color', [0.8 0 0 0.5]);
        
        newMarkers = [h1 h2 h3 h4 h5 h6];
    end
    
    % Store new markers
    setappdata(fig, 'socMarkers', newMarkers);
    
    % Update legends
    legend(ax2, {'Voltage'}, 'Location', 'northwest', 'FontSize', 9);
    legend(ax3, {'Current'}, 'Location', 'northeast', 'FontSize', 9);
    
    % Set axis properties
    xlim(ax2, [0 max(100, max(chargeData.SOC_Percent))]);
    xlim(ax3, [0 max(100, max(chargeData.SOC_Percent))]);
    ylim(ax3, [0 max(chargeData.Current_A)*1.1]);
    
    grid(ax2, 'on');
    set(ax2, 'GridLineStyle', ':');
end