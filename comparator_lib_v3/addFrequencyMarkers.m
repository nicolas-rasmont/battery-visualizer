function addFrequencyMarkers(ax, data, color)
    % Add frequency markers to EIS plot
    
    freqsToMark = [10000, 1000, 100, 10, 1, 0.1];
    for freq = freqsToMark
        [~, idx] = min(abs(data.Frequency_Hz - freq));
        if abs(data.Frequency_Hz(idx) - freq) / freq < 0.2
            plot(ax, data.Z_Real_Ohm(idx), -data.Z_Imag_Ohm(idx), 'o', ...
                'Color', color, 'MarkerSize', 5, 'MarkerFaceColor', 'white', ...
                'MarkerEdgeColor', color, 'LineWidth', 1.5,'HandleVisibility','off');
            text(ax, data.Z_Real_Ohm(idx), -data.Z_Imag_Ohm(idx), ...
                sprintf('  %.0f Hz', freq), 'FontSize', 8, 'Color', color);
        end
    end
end