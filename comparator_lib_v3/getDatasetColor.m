function color = getDatasetColor(fig, index)
    % Get color for dataset
    
    colorPalette = getappdata(fig, 'colorPalette');
    color = colorPalette{mod(index-1, length(colorPalette)) + 1};
end