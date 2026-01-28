function changeComparisonMode(fig, evt)
    % Handle comparison mode change
    
    newMode = evt.NewValue.String;
    
    if contains(newMode, 'Overlay')
        setappdata(fig, 'comparisonMode', 'overlay');
    else
        setappdata(fig, 'comparisonMode', 'sidebyside');
    end
    
    % Reset persistent handles since comparison mode changed
    setappdata(fig, 'plotCache', []);

    % Reinitialize plots for new comparison mode
    currentIdx = getappdata(fig, 'currentBatteryIdx');
    if ~isempty(currentIdx)
        initializePersistentPlots(fig, currentIdx);
    end

    updatePlotsComparator(fig);
end