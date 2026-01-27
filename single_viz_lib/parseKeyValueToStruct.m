function parseKeyValueToStruct(line, scanData, fieldName)
    % Parse key-value pair and add to structure
    parts = strsplit(line, '=');
    if length(parts) == 2
        key = strtrim(parts{1});
        value = strtrim(parts{2});
        
        if ~isfield(scanData, fieldName)
            scanData.(fieldName) = struct();
        end
        scanData.(fieldName).(key) = value;
    end
end