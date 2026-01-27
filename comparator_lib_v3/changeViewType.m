function changeViewType(fig, evt)
    % Handle view type change
    
    newView = evt.NewValue.String;
    controls = getappdata(fig, 'controls');
    
    if contains(newView, 'EIS')
        setappdata(fig, 'viewType', 'eis');
        % Show EIS controls
        set(controls.socLabel, 'String', 'SOC:');
        set(controls.showMarkersCheck, 'Visible', 'on');
        set(controls.socMarkerCheck, 'Visible', 'off');
        set(controls.prevBtn, 'Enable', 'on');
        set(controls.nextBtn, 'Enable', 'on');
    else
        setappdata(fig, 'viewType', 'charge');
        % Show charge controls
        set(controls.socLabel, 'String', 'SOC:');
        set(controls.showMarkersCheck, 'Visible', 'off');
        set(controls.socMarkerCheck, 'Visible', 'on');
        set(controls.prevBtn, 'Enable', 'off');
        set(controls.nextBtn, 'Enable', 'off');
    end
    
    updatePlotsComparator(fig);
end