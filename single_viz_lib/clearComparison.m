function clearComparison(fig)
    setappdata(fig, 'comparisonData', []);
    handles = getappdata(fig, 'handles');
    set(handles.clearBtn, 'Enable', 'off');
    updatePlots(fig);
end