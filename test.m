% Create example surface plot
[X,Y] = meshgrid(-2:.2:2);
Z = X .* exp(-X.^2 - Y.^2);
fig = figure;
surf(X,Y,Z)
colorbar

% Get all objects
allObjs = findall(fig);

% Initialize storage
typeFreq = containers.Map('KeyType', 'char', 'ValueType', 'double');

% Analyze each object
for i = 1:length(allObjs)
    obj = allObjs(i);
    props = get(obj);
    propNames = fieldnames(props);
    
    % Check each property
    for j = 1:length(propNames)
        propName = propNames{j};
        propValue = props.(propName);
        
        if isenum(propValue)
            propType = ['enum: ' class(propValue)];
        else
            propType = class(propValue);
        end
        
        % Update frequency
        if ~isKey(typeFreq, propType)
            typeFreq(propType) = 0;
        end
        typeFreq(propType) = typeFreq(propType) + 1;
    end
end

% Display results
types = keys(typeFreq);
counts = values(typeFreq);
[sortedCounts, idx] = sort(cell2mat(counts), 'descend');
sortedTypes = types(idx);

% Print results
fprintf('\nProperty Type Frequencies:\n');
for i = 1:length(sortedTypes)
    fprintf('%s: %d\n', sortedTypes{i}, sortedCounts(i));
end

close(fig);