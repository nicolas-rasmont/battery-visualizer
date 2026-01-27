function color = getNextColor(index)
    % Get color for comparison plots
    colors = {[0 0.447 0.741], [0.85 0.325 0.098], [0.929 0.694 0.125], ...
              [0.494 0.184 0.556], [0.466 0.674 0.188], [0.301 0.745 0.933], ...
              [0.635 0.078 0.184], [0.5 0.5 0.5]};
    color = colors{mod(index-1, length(colors)) + 1};
end