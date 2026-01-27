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
    %     .padding - fractional padding to add (default: 0.05)
    %     .force_zero - force inclusion of zero (default: false)
    %
    % Outputs:
    %   xlimits, ylimits - nicely rounded axis limits
    
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

% Test the improved function
function test_nice_axis_limits()
    test_cases = {
        [1.23, 4.56];
        [0.123, 0.456];
        [-4.56, -1.23];
        [-1.23, 4.56];
        [123, 456];
        [0.00123, 0.00456]
    };
    
    fprintf('=== IMPROVED AXIS LIMITS ===\n\n');
    
    for i = 1:length(test_cases)
        original = test_cases{i};
        [new_x, ~] = nice_axis_limits(original, [0, 1]);
        
        fprintf('Case %d: [%.3f, %.3f] → [%.3f, %.3f]\n', ...
                i, original(1), original(2), new_x(1), new_x(2));
        
        % Check if it preserves sign structure
        orig_positive = all(original > 0);
        new_positive = all(new_x > 0);
        orig_negative = all(original < 0);
        new_negative = all(new_x < 0);
        
        if orig_positive && ~new_positive
            fprintf('  ⚠️  Warning: Lost positive-only property\n');
        elseif orig_negative && ~new_negative
            fprintf('  ⚠️  Warning: Lost negative-only property\n');
        else
            fprintf('  ✓ Sign structure preserved\n');
        end
    end
end