function data = parse_mpt_file(filename)
% PARSE_MPT_FILE Parse EC-Lab .mpt ASCII file format
%   data = parse_mpt_file(filename) reads an EC-Lab .mpt file and returns
%   a structure containing the header information and measurement data.
%
%   Input:
%       filename - Path to the .mpt file
%
%   Output:
%       data - Structure with fields:
%           .header - Cell array containing header text lines
%           .columns - Cell array of column names
%           .values - Numeric matrix (rows = measurements, cols = parameters)
%           
%   The structure also contains each column as a separate field using
%   sanitized column names (removing special characters and spaces).
%
%   Example:
%       data = parse_mpt_file('geis_20251216_174203_C01.mpt');
%       plot(data.freq_Hz, data.Re_Z_Ohm);

    % Open file for reading
    fid = fopen(filename, 'r', 'n', 'UTF-8');
    if fid == -1
        error('Could not open file: %s', filename);
    end
    
    % Read first two lines to get header line count
    line1 = fgetl(fid);
    line2 = fgetl(fid);
    
    % Extract number of header lines
    tokens = regexp(line2, 'Nb header lines\s*:\s*(\d+)', 'tokens');
    if isempty(tokens)
        fclose(fid);
        error('Could not find "Nb header lines" in file');
    end
    num_header_lines = str2double(tokens{1}{1});
    
    % Reset file pointer to beginning
    frewind(fid);
    
    % Read all header lines
    header = cell(num_header_lines, 1);
    for i = 1:num_header_lines
        header{i} = fgetl(fid);
    end
    
    % The last header line should contain column names
    column_line = header{end};
    
    % Split column names by tab
    columns = strsplit(column_line, '\t', 'CollapseDelimiters', false);
    
    % Remove empty trailing columns if any
    columns = columns(~cellfun(@isempty, columns));
    
    % Read remaining data
    data_text = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    
    % Parse numeric data
    num_cols = length(columns);
    num_rows = length(data_text{1});
    values = zeros(num_rows, num_cols);
    
    for i = 1:num_rows
        line = data_text{1}{i};
        parts = strsplit(line, '\t');
        
        % Convert to numbers
        for j = 1:min(length(parts), num_cols)
            if ~isempty(parts{j})
                values(i, j) = str2double(parts{j});
            else
                values(i, j) = NaN;
            end
        end
    end
    
    % Create output structure
    data.header = header;
    data.columns = columns;
    data.values = values;
    
    % Add each column as a separate field with sanitized name
    for i = 1:length(columns)
        % Sanitize column name: remove special characters, replace with underscore
        field_name = regexprep(columns{i}, '[^a-zA-Z0-9]', '_');
        % Remove leading/trailing underscores
        field_name = regexprep(field_name, '^_+|_+$', '');
        % Remove consecutive underscores
        field_name = regexprep(field_name, '_+', '_');
        % Ensure it doesn't start with a number
        if ~isempty(field_name) && isstrprop(field_name(1), 'digit')
            field_name = ['col_' field_name];
        end
        % Handle empty field names
        if isempty(field_name)
            field_name = sprintf('column_%d', i);
        end
        
        data.(field_name) = values(:, i);
    end
    
    fprintf('Successfully parsed %d data points with %d columns\n', ...
            num_rows, num_cols);
end
