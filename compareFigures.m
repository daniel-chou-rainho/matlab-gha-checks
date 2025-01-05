function differences = compareFigures(info1, info2, debug)
    differences = struct('class', {}, 'parent', {}, 'field', {}, 'baseline', {}, 'test', {}, 'matches', {});
   
    % Check counts and list objects
    if length(info1) ~= length(info2)
        differences(1).class = 'root';
        differences(1).parent = '';
        differences(1).field = 'object_count';
        differences(1).baseline = {info1.class};
        differences(1).test = {info2.class};
        differences(1).matches = false;
        return;
    end
    
    % Check all classes
    allClasses1 = {info1.class};
    allClasses2 = {info2.class}; 
    if ~isequal(allClasses1, allClasses2)
        differences(1).class = 'root';
        differences(1).parent = '';
        differences(1).field = 'class_mismatch';
        differences(1).baseline = allClasses1;
        differences(1).test = allClasses2;
        differences(1).matches = false;
        return;
    end
   
    % Finally do property comparisons
    for i = 1:length(info1)
        differences = compareProperties(differences, info1(i), info2(i), info1(i).parent, debug);
    end
end

function differences = compareProperties(differences, obj1, obj2, parent, debug)
    blacklist = getBlacklist();
    props1 = obj1.properties;
    props2 = obj2.properties;
    fields = intersect(fieldnames(props1), fieldnames(props2));
    
    for i = 1:length(fields)
        field = fields{i};
        
        key = [obj1.class ':' field];
        if blacklist.isKey(key) || blacklist.isKey(['*:' field])
            continue;
        end
        
        val1 = props1.(field);
        val2 = props2.(field);
        
        if isa(val1, 'matlab.lang.OnOffSwitchState') && isa(val2, 'matlab.lang.OnOffSwitchState')
            val1 = strcmp(string(val1), 'on');
            val2 = strcmp(string(val2), 'on');
            matches = val1 == val2;
        elseif isnumeric(val1) && isnumeric(val2)
            nan_matches = isnan(val1(:)) == isnan(val2(:));
            num_matches = abs(val1(:) - val2(:)) < 1e-10;
            matches = all(nan_matches & (num_matches | isnan(val1(:))));
        else
            matches = isequal(val1, val2);
        end
        
        if debug || ~matches
            nextIdx = length(differences) + 1;
            differences(nextIdx).class = obj1.class;
            differences(nextIdx).parent = parent;
            differences(nextIdx).field = field;
            differences(nextIdx).baseline = val1;
            differences(nextIdx).test = val2;
            differences(nextIdx).matches = matches;
        end
    end
end

function blacklist = getBlacklist()
    blacklist = containers.Map();
    
    % Object-specific properties
    blacklist('matlab.ui.Figure:Number') = [];
    blacklist('matlab.ui.Figure:OuterPosition') = [];
    blacklist('matlab.ui.Root:PointerLocation') = [];
    blacklist('matlab.ui.container.ContextMenu:ContextMenuOpeningFcn') = [];
    blacklist('matlab.graphics.axis.Axes:InteractionOptions') = [];
    blacklist('matlab.graphics.chart.primitive.Line:DataTipTemplate') = [];
    blacklist('matlab.graphics.chart.primitive.Surface:DataTipTemplate') = [];
    
    % Global properties to ignore for all objects
    blacklist('*:Children') = [];
end