function changeComparisonMode(fig, evt)
    % Handle comparison mode change
    
    newMode = evt.NewValue.String;
    
    if contains(newMode, 'Overlay')
        setappdata(fig, 'comparisonMode', 'overlay');
    else
        setappdata(fig, 'comparisonMode', 'sidebyside');
    end
    
    updatePlotsComparator(fig);
end