function [xlimits, ylimits] = calculateGlobalLimits(SOCEIScan, validIdx)
    % Calculate axis limits that encompass all data
    
    xmin = inf; xmax = -inf;
    ymin = inf; ymax = -inf;
    
    for idx = validIdx'
        scan = SOCEIScan.Scans{idx};
        if ~isempty(scan) && isfield(scan, 'ImpedanceData')
            data = scan.ImpedanceData;
            xmin = min(xmin, min(data.Z_Real_Ohm));
            xmax = max(xmax, max(data.Z_Real_Ohm));
            ymin = min(ymin, min(-data.Z_Imag_Ohm));
            ymax = max(ymax, max(-data.Z_Imag_Ohm));
        end
    end
    
    % Add 10% padding
    xrange = xmax - xmin;
    yrange = ymax - ymin;
    
    xlimits = [xmin - 0.05*xrange, xmax + 0.05*xrange];
    ylimits = [ymin - 0.05*yrange, ymax + 0.05*yrange];
    
    % Ensure y-axis starts at or below zero for Nyquist plots
    if ylimits(1) > 0
        ylimits(1) = -0.001;
    end
end
