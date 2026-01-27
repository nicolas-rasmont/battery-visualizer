function summaryStruct = summaryReader(filePath)
    fid = fopen(filePath, 'r');
    if fid == -1
        error('Could not open file: %s', filePath);
    end
    
    summaryStruct = struct();
    currentSection = '';
    
    try
        while ~feof(fid)
            line = fgetl(fid);
            
            % Skip empty lines
            if isempty(line)
                continue;
            end
            
            % Check for section headers
            if startsWith(line, '[') && endsWith(line, ']')
                currentSection = line(2:end-1); % Remove brackets
                continue;
            end
            
            % Handle Impedance_Data section specially
            if strcmpi(currentSection, 'Impedance_Data')
                summaryStruct = parseImpedanceData(line, summaryStruct, currentSection, fid);
                break; % Impedance data processing handles rest of section
            else
                % Skip comment lines for non-impedance sections
                if startsWith(line, '#')
                    continue;
                end
                summaryStruct = parseKeyValueToStruct(line, summaryStruct, currentSection);
            end
        end
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    
    fclose(fid);
end

function scanData = parseKeyValueToStruct(line, scanData, fieldName)
    % Parse key-value pair and add to structure
    parts = strsplit(line, '=');
    parts
    if length(parts) == 2
        key = strtrim(parts{1});
        value = strtrim(parts{2});
        if ~isfield(scanData, fieldName)
            scanData.(fieldName) = struct();
        end
        scanData.(fieldName).(key) = parseSummaryString(value);
    end
end

function scanData = parseImpedanceData(firstLine, scanData, sectionName, fid)
    % Parse impedance data section with headers and numerical data
    
    if ~isfield(scanData, sectionName)
        scanData.(sectionName) = struct();
    end
    
    headers = {};
    dataRows = [];
    
    % Check if first line is a header (starts with #)
    if startsWith(firstLine, '#')
        headerLine = firstLine(2:end); % Remove #
        headers = strsplit(headerLine, ',');
        headers = cellfun(@strtrim, headers, 'UniformOutput', false);
        headers = cellfun(@makeValidFieldName, headers, 'UniformOutput', false);
    else
        % First line is data, parse it
        if contains(firstLine, ',')
            values = str2double(strsplit(firstLine, ','));
            if ~any(isnan(values))
                dataRows = [dataRows; values];
            end
        end
    end
    
    % Continue reading data rows
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line)
            continue;
        end
        
        % Check if we've hit a new section
        if startsWith(line, '[') && endsWith(line, ']')
            % Put the line back by seeking back (approximate)
            % Since we can't easily seek back, we'll parse this line in main loop
            % For now, we'll stop here - in practice you might want to handle this better
            break;
        end
        
        % Parse data row
        if contains(line, ',')
            values = str2double(strsplit(line, ','));
            if ~any(isnan(values))
                dataRows = [dataRows; values];
            end
        end
    end
    
    
    % If we have headers, also create a table
    if ~isempty(headers) && ~isempty(dataRows)
        if size(dataRows, 2) == length(headers)
            scanData.(sectionName) = array2table(dataRows, 'VariableNames', headers);
        end
    end
end

function validName = makeValidFieldName(name)
    % Convert string to valid MATLAB field name
    validName = matlab.lang.makeValidName(name);
end