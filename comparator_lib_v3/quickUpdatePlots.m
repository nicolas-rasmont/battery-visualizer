function quickUpdatePlots(fig)
    % Quick plot update for real-time slider movement
    %
    % Now that updatePlotsComparator uses persistent handles,
    % this function simply delegates to it.

    updatePlotsComparator(fig);
end
