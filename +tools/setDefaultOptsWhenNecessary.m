function opts = setDefaultOptsWhenNecessary(opts, defopts)
    fns = fieldnames(defopts);
    for ii = 1:numel(fns)
        if ~isfield(opts, fns{ii})
            opts.(fns{ii}) = defopts.(fns{ii});
        end
    end
end
