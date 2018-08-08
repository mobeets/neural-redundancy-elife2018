function plotSingleHistFig(hs1, hs2, xs, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('clr1', [0 0 0], 'clr2', [0.5 0.5 0.5], ...
        'width', 3, 'height', 2.5, 'margin', 0.125, ...
        'FontSize', 16, 'title', '', ...
        'xMult', 4.3, 'yMult', 0.6, 'dimScale', 1.0, ...
        'LineWidth', 3, 'LineStyle', 'k-', 'ymax', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    
%     xs = xs*opts.dimScale;

    % plot hists
    plot.init(opts.FontSize);
    plotSingleHist(xs, hs1, ...
        opts.LineWidth, opts.clr1, opts.LineStyle);
    plotSingleHist(xs, hs2, ...
        opts.LineWidth, opts.clr2, opts.LineStyle);
    
    % manage x axis
    xscale = opts.xMult*mode(diff(xs));
    xmrg = xscale/5;
    minx = min(xs) - xmrg;
    maxx = max(xs);
    xlim([minx maxx]);

    text(opts.lbl1(1), opts.lbl1(2), 'Data', ...
        'FontSize', opts.FontSize, 'Color', opts.clr1);    
    text(opts.lbl2(1), opts.lbl2(2), 'Predicted', ...
        'FontSize', opts.FontSize, 'Color', opts.clr2);
    
    title(opts.title, 'FontSize', opts.FontSize, ...
        'Color', [0.5 0.5 0.5], 'FontWeight', 'Normal');
    
    if ~isnan(opts.ymax)
        ylim([0 opts.ymax]);
    end
    
    xtick = xscale;%ceil(xscale);
    set(gca, 'XTick', [0 2*xtick]);
    set(gca, 'XTickLabel', round(opts.dimScale*[0 2*xtick]/10)*10);
    xlabel('Spikes/s, rel. to baseline', 'FontSize', opts.FontSize);
    
    set(gca, 'YTick', []);
    ylabel('Frequency', 'FontSize', opts.FontSize);
    
    set(gca, 'TickDir', 'out');
    set(gca, 'LineWidth', opts.LineWidth-1);

%     axis off;
    box off;
    plot.setPrintSize(gcf, opts);

end

function h = plotSingleHist(xs, ys, lw, clr, lnsty)
    h = plot(xs, ys, lnsty, 'Color', clr, 'LineWidth', lw);
end
