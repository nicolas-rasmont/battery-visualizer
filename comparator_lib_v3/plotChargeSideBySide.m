function plotChargeSideBySide(fig, batteryIndices, socValue)
    % Create side-by-side charge plots
    
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
        % Calculate position
        row = ceil(i/2);
        col = mod(i-1, 2) + 1;
        
        left = 0.05 + (col-1) * 0.48;
        bottom = 0.95 - row * 0.45;
        width = 0.38;
        height = 0.38;
        
        dataset = batteryData.datasets(batteryIndices(i));
        
        if ~isempty(dataset.chargeData)
            % Create voltage axis
            ax1 = axes('Parent', panel, ...
                      'Position', [left bottom width height]);
            yyaxis left
            plot(ax1, dataset.chargeData.SOC_Percent, dataset.chargeData.Voltage_V, ...
                 'b.', 'LineWidth', 1);
            ylabel(ax1, 'Voltage (V)', 'Color', 'b');
            xlabel(ax1, 'SOC (%)');
            set(ax1, 'YColor', 'b');
            
            % Create current axis
            yyaxis right
            plot(ax1, dataset.chargeData.SOC_Percent, dataset.chargeData.Current_A, ...
                 'r.', 'LineWidth', 1);
            ylabel(ax1, 'Current (A)', 'Color', 'r');
            set(ax1, 'YColor', 'r');
            hold(ax1, 'on');
            
            % Add SOC marker
            if get(controls.socMarkerCheck, 'Value')
                [~, idx] = min(abs(dataset.chargeData.SOC_Percent - socValue));
                hold(ax1, 'on');
                yyaxis left
                plot(ax1, dataset.chargeData.SOC_Percent(idx), ...
                     dataset.chargeData.Voltage_V(idx), 'bo', ...
                     'MarkerSize', 8, 'MarkerFaceColor', 'b','Tag','SOCMarker');
                yyaxis right
                hold(ax1, 'on');
                plot(ax1, dataset.chargeData.SOC_Percent(idx), ...
                     dataset.chargeData.Current_A(idx), 'rs', ...
                     'MarkerSize', 6, 'MarkerFaceColor', 'r','Tag','SOCMarker');
            end
            
            title(ax1, dataset.name, 'Interpreter', 'none', 'FontSize', 10);
            xlim(ax1, [0 ceil(max(dataset.chargeData.SOC_Percent)/10)*10]);
            %xlim(ax2, [0 max(180, socValue+20)]);
            
            if get(controls.gridCheck, 'Value')
                grid(ax1, 'on');
                set(ax1, 'GridLineStyle', ':');
            end
        else
            % No charge data
            ax = axes('Parent', panel, ...
                     'Position', [left bottom width height]);
            title(ax, sprintf('%s - No Charge Data', dataset.name), ...
                  'Interpreter', 'none', 'FontSize', 10);
            set(ax, 'XTick', [], 'YTick', []);
        end
    end
end