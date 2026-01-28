function dataStruct = readBaseline(rootDir)
    % Reads all files in a directory tree and organizes them into a nested struct
    % Files inherit the hierarchical structure of their parent folders
    % CSV files are read with readtable, others with summaryReader
    rootDir
    dataStruct = struct();
    dataStruct = processDirectory(rootDir, {}, dataStruct);
end

function dataStruct = processDirectory(currentDir, pathParts, dataStruct)
    % Recursively process directory contents
    contents = dir(currentDir);

    % Check if this is an eis_measurements folder
    [~, folderName] = fileparts(currentDir);
    if strcmpi(folderName, 'eis_measurements')
        % Special handling for EIS measurements folder
        eisData = parseEIS(currentDir);
        if ~isempty(eisData)
            dataStruct = setNestedField(dataStruct, pathParts, eisData);
        end
        return;
    end

    for i = 1:length(contents)
        item = contents(i);

        % Skip current and parent directory entries
        if strcmp(item.name, '.') || strcmp(item.name, '..')
            continue;
        end

        fullPath = fullfile(currentDir, item.name);

        if item.isdir
            % Directory: recurse with updated path
            newPathParts = [pathParts, {makeValidFieldName(item.name)}];
            dataStruct = processDirectory(fullPath, newPathParts, dataStruct);
        else
            % File: read and store in struct
            [~, fileName, ext] = fileparts(item.name);

            % Skip log files
            if strcmpi(ext, '.log')
                continue;
            end

            finalPathParts = [pathParts, {makeValidFieldName(fileName)}];

            % Choose reader based on extension
            if strcmpi(ext, '.csv')
                data = readtable(fullPath);
            else
                data = summaryReader(fullPath);
            end

            % Check for redundant self-nesting and unwrap if needed
            data = unwrapRedundantStruct(data, fileName);

            % Store in nested struct using dynamic field assignment
            dataStruct = setNestedField(dataStruct, finalPathParts, data);
        end
    end
end

function s = setNestedField(s, fieldPath, value)
    % Set a nested field, creating intermediate struct levels as needed
    %
    % Example: setNestedField(s, {'a', 'b', 'c'}, 123)
    %          creates s.a.b.c = 123, even if s.a or s.a.b don't exist

    if isempty(fieldPath)
        return;
    end

    if length(fieldPath) == 1
        % Base case: single field, just set it
        s.(fieldPath{1}) = value;
    else
        % Recursive case: ensure intermediate struct exists
        firstField = fieldPath{1};
        remainingPath = fieldPath(2:end);

        if ~isfield(s, firstField) || ~isstruct(s.(firstField))
            s.(firstField) = struct();
        end

        s.(firstField) = setNestedField(s.(firstField), remainingPath, value);
    end
end

function validName = makeValidFieldName(name)
    % Convert string to valid MATLAB field name
    validName = matlab.lang.makeValidName(name);
end

function data = unwrapRedundantStruct(data, fileName)
    % Unwrap struct if it contains a single field matching the filename
    if isstruct(data) && isscalar(fieldnames(data))
        fields = fieldnames(data);
        fieldName = fields{1};

        % Check if field name matches filename (case-insensitive)
        if strcmpi(fieldName, fileName) || strcmpi(fieldName, makeValidFieldName(fileName))
            data = data.(fieldName);
        end
    end
end

function eisCellArray = parseEIS(eisDir)
    % Parse all EIS measurement files in eis_measurements folder
    contents = dir(eisDir);
    eisCellArray = {};

    for i = 1:length(contents)
        item = contents(i);

        % Skip directories and non-EIS files
        if item.isdir || strcmp(item.name, '.') || strcmp(item.name, '..')
            continue;
        end

        [~, fileName, ext] = fileparts(item.name);

        % Check if it's an EIS file (eis_*.txt)
        if strcmpi(ext, '.txt') && startsWith(lower(fileName), 'eis_')
            fullPath = fullfile(eisDir, item.name);
            eisData = summaryReader(fullPath);
            eisCellArray{end+1} = eisData;
        end
    end
end
