function toggleCompareMode(fig)
    handles = getappdata(fig, 'handles');
    
    if get(handles.compareCheck, 'Value') == 0
        setappdata(fig, 'comparisonData', []);
        set(handles.clearBtn, 'Enable', 'off');
        updatePlots(fig);
    end
end