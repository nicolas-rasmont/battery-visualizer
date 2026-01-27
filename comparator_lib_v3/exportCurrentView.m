function exportCurrentView(fig)
    % Export current plot view
    
    [filename, pathname] = uiputfile({'*.png';'*.fig';'*.pdf'}, ...
                                     'Save Plot As');
    if filename == 0
        return;
    end
    
    handles = getappdata(fig, 'handles');
    panel = handles.rightPanel;
    
    % Create temporary figure for export
    tempFig = figure('Position', [100 100 1200 700], 'Visible', 'off');
    copyobj(allchild(panel), tempFig);
    
    % Save
    fullPath = fullfile(pathname, filename);
    [~, ~, ext] = fileparts(filename);
    
    switch ext
        case '.fig'
            savefig(tempFig, fullPath);
        case '.pdf'
            print(tempFig, fullPath, '-dpdf', '-bestfit');
        otherwise
            print(tempFig, fullPath, '-dpng', '-r300');
    end
    
    close(tempFig);
    
    controls = getappdata(fig, 'controls');
    set(controls.statusText, 'String', sprintf('Exported to: %s', filename));
end