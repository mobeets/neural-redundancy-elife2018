function Ps = plotError(errs, nms, opts)
    if nargin < 2
        opts = struct();
    end
    defopts = struct('width', 6, 'height', 6, 'margin', 0.125, ...
        'FontSize', 24, 'FontSizeTitle', 28, 'FontName', 'Helvetica', ...
        'doSave', false, 'saveDir', 'data/plots/figures/errors', ...
        'filename', 'avgErr', 'ext', 'pdf', 'title', '', 'clrs', [], ...
        'doBox', true, 'ylbl', 'Avg. error', 'starBaseName', '', ...
        'errFloor', nan, 'showZeroBoundary', false, 'nSEs', 1, ...
        'LineWidth', 2, 'ymin', 0, 'ymax', nan, 'TextNote', '');
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    if numel(errs) == numel(nms)
        error('Must provide multiple errors per hyp.');
    end
    
    % show plot
    plot.init(opts.FontSize, opts.FontName);
    
    % show error floor, if provided
    if ~isnan(opts.errFloor)
        xl = [0.3 size(errs,1)];
        if numel(opts.errFloor) == 1
            plot(xl, [opts.errFloor opts.errFloor], '-', ...
                'LineWidth', opts.LineWidth, 'Color', 0.7*ones(3,1));
        else
            mu = opts.errFloor(1);
            sd = opts.errFloor(2);
            rectangle('Position', [xl(1), mu-sd, xl(2)-xl(1), 2*sd], ...
                'EdgeColor', 'none', 'FaceColor', 0.95*ones(3,1));
%             plot(xlim, [mu - sd; mu - sd], '-', ...
%                 'LineWidth', opts.LineWidth, 'Color', 0.7*ones(3,1));
%             plot(xlim, [mu + sd; mu + sd], '-', ...
%                 'LineWidth', opts.LineWidth, 'Color', 0.7*ones(3,1));
        end
    end
    
    % plot box or bar
    if opts.doBox
        makeBoxPlot(errs, opts.clrs, opts.LineWidth);
    else
        makeBarPlot(errs, opts.clrs, opts.LineWidth, opts.nSEs);
    end
    
    % format x-axis
    if ~isempty(nms)
        set(gca, 'XTick', 1:numel(nms));
        set(gca, 'XTickLabel', nms);    
        xlim([0.25 numel(nms)+0.75]);
        if max(cellfun(@numel, nms)) > 1 % if longest name > 3 chars
            set(gca, 'XTickLabelRotation', 45);
        end
    end
        
    % format y-axis
    yl = ylim;
    if ~isnan(opts.ymax)
        ymx = opts.ymax;
    else
        ymx = yl(2);
    end
    if ~isnan(opts.ymin)
        ymn = opts.ymin;
    else
        ymn = yl(1);
    end
    ylim([ymn ymx]);
    h = ylabel(opts.ylbl);
    set(h, 'interpreter', 'tex'); % funky bug somehow caused by boxplot

    if ~isempty(opts.starBaseName)
        bInd = find(ismember(nms, opts.starBaseName));
        Ps = plot.addSignificanceStars(errs, bInd);
        ylim(yl);
        
        ytrg = ymx;
        yspace = (ymx - ymn)/20;
        hs = findobj(gcf, 'tag', 'sigstar_bar');
        hss = findobj(gcf, 'tag', 'sigstar_stars');
        for jj = 1:numel(hs)
            cy = ytrg - (jj-1)*yspace;
            hs(jj).YData = cy*ones(4,1);
            hss(jj).Position(2) = cy;
        end
        
    end    
    
    if opts.showZeroBoundary
        plot(xlim, [0 0], 'k-', 'LineWidth', opts.LineWidth);
    end
    
    % format plot
    if ~isempty(opts.title)
        title(opts.title, 'FontSize', opts.FontSizeTitle);
    end
    set(gca, 'TickDir', 'out');
    set(gca, 'TickLength', [0 0]);
    set(gca, 'LineWidth', opts.LineWidth);
    box off;
    plot.setPrintSize(gcf, opts);
    ylim([ymn ymx]);
    
    if ~isempty(opts.TextNote)
        xl = xlim; yl = ylim;
        text(0.65*xl(2), 0.95*yl(2), ...
            opts.TextNote, 'FontSize', opts.FontSize);
    end
        
    if opts.doSave
        plot.export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end
end

function makeBoxPlot(pts, clrs, lw)
    bp = boxplot(pts, 'Colors', clrs, ...
        'Symbol', '', 'OutlierSize', 8, 'widths', 0.7);

    % hide horizontal part of error bars
    h = findobj(gcf,'tag','Upper Adjacent Value');
    for jj = 1:numel(h)
        h(jj).Color = 'None';
    end
    h = findobj(gcf,'tag','Lower Adjacent Value');
    for jj = 1:numel(h)
        h(jj).Color = 'None';
    end
    
    h = findobj(gcf,'tag','Box');
%     for jj = 1:numel(h)
%         patch(get(h(jj),'XData'), get(h(jj),'YData'), get(h(jj), 'Color'), ...
%             'FaceAlpha', 1.0, 'EdgeColor', 'none');
%     end
    set(findobj(bp, 'LineStyle', '--'), 'LineStyle', '-');
    set(bp, 'LineWidth', lw);
    set(findobj(bp, 'LineStyle', '--'), 'LineStyle', '-');
    
    % hide outliers
%     outs = findobj(bp, 'tag', 'Outliers');
%     set(outs, 'XData', nan);
end

function makeBarPlot(pts, clrs, lw, nSEs)
    ms = mean(pts);
    bs = nSEs*std(pts)/sqrt(size(pts,1));
    for ii = 1:size(pts,2)        
%         bar(ii, ms(ii), 'EdgeColor', 'k', 'FaceColor', clrs(ii,:), ...
%             'LineWidth', lw);
        bar(ii, ms(ii), 'EdgeColor', clrs(ii,:), 'FaceColor', 'w', ...
            'LineWidth', lw);
%         plot([ii-0.5 ii+0.5], [ms(ii) ms(ii)], '-', ...
%             'Color', clrs(ii,:), 'LineWidth', 2*lw);
%         plot([ii ii], [ms(ii)-bs(ii) ms(ii)+bs(ii)], '-', ...
%             'Color', 'k', 'LineWidth', lw);
        plot([ii ii], [ms(ii)-bs(ii) ms(ii)+bs(ii)], '-', ...
            'Color', clrs(ii,:), 'LineWidth', lw);
    end
end
