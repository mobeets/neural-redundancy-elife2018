function opts = setDefaultOptsWhenNecessary(opts, defopts)
% for every field in defopts (struct) that isn't in opts (struct),
% add that field/value pair to opts (used for setting default params)
% 
    fns = fieldnames(defopts);
    for ii = 1:numel(fns)
        if ~isfield(opts, fns{ii})
            opts.(fns{ii}) = defopts.(fns{ii});
        end
    end
end
