function result = floorsig(x, n)
    % FLOORSIG - Floor a number to N significant digits
    %
    % Syntax: result = floorsig(x, n)
    %
    % Inputs:
    %   x - Input number (scalar or array)
    %   n - Number of significant digits to keep (positive integer)
    %
    % Output:
    %   result - Number floored to n significant digits
    %
    % Examples:
    %   floorsig(123.456, 3) returns 123
    %   floorsig(0.001234, 2) returns 0.0012
    %   floorsig(-123.456, 3) returns -124

    % Handle edge cases
    if any(x == 0)
        result = x;
        if isscalar(x)
            return;
        end
        % For arrays, process non-zero elements
        nonzero_mask = x ~= 0;
        result(~nonzero_mask) = x(~nonzero_mask);
        x = x(nonzero_mask);
    else
        nonzero_mask = true(size(x));
    end

    % Find the magnitude of the first significant digit
    magnitude = floor(log10(abs(x)));

    % Calculate the scaling factor to move nth significant digit to ones place
    scale_power = magnitude - (n - 1);
    scale_factor = 10.^scale_power;

    % Scale, apply floor, then scale back
    scaled = x ./ scale_factor;
    floored_scaled = floor(scaled);
    final_result = floored_scaled .* scale_factor;

    if isscalar(x)
        result = final_result;
    else
        result(nonzero_mask) = final_result;
    end
end
