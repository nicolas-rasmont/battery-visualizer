function plotSingleScan(ax, scan, socValue, color, showMarkers, resetHold)
    % Plot a single scan on the axis
    
    if resetHold
        hold(ax, 'off');
    end
    
    data = scan.ImpedanceData;
    
    % Plot main curve
    plot(ax, data.Z_Real_Ohm, -data.Z_Imag_Ohm, 'r-', ...
         'Color', color, 'LineWidth', 2);
    hold(ax, 'on');
    
    % Add start and end markers
    plot(ax, data.Z_Real_Ohm(1), -data.Z_Imag_Ohm(1), 'o', ...
         'Color', color, 'MarkerSize', 8, 'MarkerFaceColor', color);
    plot(ax, data.Z_Real_Ohm(end), -data.Z_Imag_Ohm(end), 's', ...
         'Color', color, 'MarkerSize', 8, 'MarkerFaceColor', color);
    
    if showMarkers
        % Add frequency markers
        freqsToMark = [10000, 1000, 100, 10, 1, 0.1];
        for freq = freqsToMark
            [~, idx] = min(abs(data.Frequency_Hz - freq));
            if abs(data.Frequency_Hz(idx) - freq) / freq < 0.2  % Within 20% of target
                plot(ax, data.Z_Real_Ohm(idx), -data.Z_Imag_Ohm(idx), 'o', ...
                    'Color', color, 'MarkerSize', 5, 'MarkerFaceColor', 'white', ...
                    'MarkerEdgeColor', color, 'LineWidth', 1.5);
                text(ax, data.Z_Real_Ohm(idx), -data.Z_Imag_Ohm(idx), ...
                    sprintf('  %.0f Hz', freq), 'FontSize', 8, 'Color', 'k');
            end
        end
    end
end
