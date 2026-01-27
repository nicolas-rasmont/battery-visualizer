function output = parseSummaryString(inputStr)
    % parseString - Parse a string and return the appropriate data type
    % 
    % Syntax: output = parseString(inputStr)
    %
    % Input:
    %   inputStr - string or char array to parse
    %
    % Output:
    %   output - parsed data in appropriate format:
    %            - double for floats (e.g., "4767.5")
    %            - int64 for integers (e.g., "11")
    %            - double array for comma-separated lists (e.g., "2.757,3.415,3.529")
    %            - datetime for dates (e.g., "2036-02-06 22:28:30")
    %            - string for everything else (e.g., "Disabled")
    
    % Convert to string and remove whitespace
    inputStr = string(strtrim(inputStr));
    
    % Check if it's a date format (YYYY-MM-DD HH:MM:SS)
    datePattern = '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$';
    if ~isempty(regexp(inputStr, datePattern, 'once'))
        output = datetime(inputStr, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
        return;
    end
    
    % Check if it's a comma-separated vector
    if contains(inputStr, ',')
        try
            % Split by comma and convert to numbers
            parts = split(inputStr, ',');
            numbers = str2double(strtrim(parts));
            if all(~isnan(numbers))
                output = numbers'; % Return as row vector
                return;
            end
        catch
            % If conversion fails, treat as regular string
        end
    end
    
    % Check if it's a number (int or float)
    num = str2double(inputStr);
    if ~isnan(num)
        % Check if it contains a decimal point
        if contains(inputStr, '.')
            output = num; % Keep as double (float)
        else
            output = int64(num); % Convert to integer
        end
        return;
    end
    
    % Default: return as string
    output = inputStr;
end