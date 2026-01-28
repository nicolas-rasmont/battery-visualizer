function [xlimits, ylimits] = nice_axis_limits(xlimits, ylimits, options)
    % NICE_AXIS_LIMITS - Create nicely rounded axis limits
    %
    % Syntax: [xlimits, ylimits] = nice_axis_limits(xlimits, ylimits)
    %         [xlimits, ylimits] = nice_axis_limits(xlimits, ylimits, options)
    %
    % Inputs:
    %   xlimits - [xmin, xmax] data range
    %   ylimits - [ymin, ymax] data range
    %   options - struct with fields:
    %     .sig_digits - number of significant digits (default: 1)
    %     .padding - fractional padding to add (default: 0.01)
    %     .force_zero - force inclusion of zero (default: false)
    %
    % Outputs:
    %   xlimits, ylimits - nicely rounded axis limits
    %
    % Dependencies:
    %   Requires ceilsig.m and floorsig.m in the path

    if nargin < 3
        options = struct();
    end

    % Default options
    if ~isfield(options, 'sig_digits'), options.sig_digits = 1; end
    if ~isfield(options, 'padding'), options.padding = 0.01; end
    if ~isfield(options, 'force_zero'), options.force_zero = false; end

    % Process each axis
    xlimits = process_axis_limits(xlimits, options);
    ylimits = process_axis_limits(ylimits, options);
end

function limits = process_axis_limits(limits, options)
    % Process a single axis to create nice limits
    if isempty(limits)
        return;
    end

    original_range = limits(2) - limits(1);

    % Add padding to the range
    padding = original_range * options.padding;
    padded_limits = [limits(1) - padding, limits(2) + padding];

    % Handle zero-crossing cases
    if options.force_zero || (limits(1) <= 0 && limits(2) >= 0)
        % Range crosses zero or we're forcing zero inclusion
        if limits(1) <= 0
            lower = -ceilsig(-padded_limits(1), options.sig_digits);
        else
            lower = floorsig(padded_limits(1), options.sig_digits);
        end

        if limits(2) >= 0
            upper = ceilsig(padded_limits(2), options.sig_digits);
        else
            upper = -floorsig(-padded_limits(2), options.sig_digits);
        end
    else
        % Range doesn't cross zero - preserve the sign
        lower = floorsig(padded_limits(1), options.sig_digits);
        upper = ceilsig(padded_limits(2), options.sig_digits);
    end

    limits = [lower, upper];
end
