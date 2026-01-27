function updateChargeMarkers(fig, socValue)
    % Update only the SOC markers on charge plots without redrawing everything
    
    handles = getappdata(fig, 'handles');
    panel = handles.rightPanel;
    batteryData = getappdata(fig, 'batteryData');
    currentIdx = getappdata(fig, 'currentBatteryIdx');
    controls = getappdata(fig, 'controls');
    
    if ~get(controls.socMarkerCheck, 'Value')
        return;  % Markers not enabled
    end
    
    % Find and delete existing markers
    existingMarkers = findobj(panel, 'Tag', 'SOCMarker');
    delete(existingMarkers);
    
    % Find all axes in the panel
    allAxes = findobj(panel, 'Type', 'axes');
    
    for i = 1:length(currentIdx)
        dataset = batteryData.datasets(currentIdx(i));
        
        if isempty(dataset.chargeData)
            continue;
        end
        
        % Find the corresponding axes
        % This depends on your plot layout
        [~, idx] = min(abs(dataset.chargeData.SOC_Percent - socValue));
        
        % Add new markers with Tag for easy deletion
        for ax = allAxes'
            if contains(get(ax, 'YLabel'), 'Voltage') || isempty(get(ax, 'YLabel'))
                hold(ax, 'on');
                plot(ax, dataset.chargeData.SOC_Percent(idx), ...
                     dataset.chargeData.Voltage_V(idx), 'o', ...
                     'Color', dataset.color, 'MarkerSize', 8, ...
                     'MarkerFaceColor', dataset.color, ...
                     'Tag', 'SOCMarker');
            elseif contains(get(ax, 'YLabel'), 'Current')
                hold(ax, 'on');
                plot(ax, dataset.chargeData.SOC_Percent(idx), ...
                     dataset.chargeData.Current_A(idx), 's', ...
                     'Color', dataset.color, 'MarkerSize', 6, ...
                     'MarkerFaceColor', dataset.color, ...
                     'Tag', 'SOCMarker');
            end
        end
    end
    
    drawnow limitrate;  % Update display with rate limiting
end