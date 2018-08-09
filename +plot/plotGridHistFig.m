function plotGridHistFig(H1, H2, xs, opts)
    if nargin < 4
        opts = struct();
    end
    defopts = struct('clr1', [0 0 0], 'clr2', [0.5 0.5 0.5], ...
        'width', 4, 'height', 8, 'margin', 0.125, ...
        'FontSize', 14, 'title', '', ...
        'xMult', 4.2, 'yMult', 0.6, 'rowStartInd', nan, ...
        'histError', nan, 'dimScale', 1.0, ...
        'LineWidth', 2, 'LineStyle', 'k-', 'ymax', nan);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);

    xgap = 1.2*range(xs);
    ygap = 1.2*opts.ymax;

    % plot hists in grid with specified gaps
    plot.init;
    [nrows,~,ncols] = size(H1);
    if ~isnan(opts.rowStartInd)
        roworder = [opts.rowStartInd:nrows 1:(opts.rowStartInd-1)];
    else
        roworder = nrows:-1:1;
    end
    for ii = 1:nrows
        for jj = 1:ncols
            if ii == nrows
                colTitle = {'Output-null', ['     dim. ' num2str(jj)]};
                x = min(xs) + (jj-1)*xgap;
                y = ygap + (ii-1)*ygap;
                text(x, y, colTitle, 'FontSize', opts.FontSize, ...
                    'Color', [0.5 0.5 0.5]);
            end
            histRowInd = roworder(ii);
            hs1 = squeeze(H1(histRowInd,:,jj)) + (ii-1)*ygap;
            hs2 = squeeze(H2(histRowInd,:,jj)) + (ii-1)*ygap;
            xsc = xs + (jj-1)*xgap;
            plotSingleHist(xsc, hs1, opts.LineWidth, opts.clr1, ...
                opts.LineStyle);
            plotSingleHist(xsc, hs2, opts.LineWidth, opts.clr2, ...
                opts.LineStyle);
        end
    end

    % plot scale bars
    xscale = opts.xMult*mode(diff(xs));
    yscale = opts.yMult*opts.ymax;
    x1 = min(xs) - 0.5*xscale;
    y1 = -0.3*yscale;
    x = min(xs); y = 0;
    xtxtoffset = 0.4*xscale;
    ytxtoffset = 0.4*yscale;
    % xlabel
    text(x, y1 - ytxtoffset + (ii-1)*ygap, ...
        [num2str(round(2*xscale*opts.dimScale/10)*10, '%0.0f') ...
        ' spikes/s'], 'FontSize', opts.FontSize);
    plot([0 2*xscale], [y1 y1] + (ii-1)*ygap, 'k-', ...
        'LineWidth', opts.LineWidth-1);
    % ylabel
    plot([x1 x1], [y y+1.2*yscale] + (ii-1)*ygap, 'k-', ...
        'LineWidth', opts.LineWidth-1);
    text(x1 - xtxtoffset, y  + (ii-1)*ygap, ...
        'Freq.', 'Rotation', 90, ...
        'FontSize', opts.FontSize);

    
    % plot hist error
    if ~isempty(opts.histError)
        msg = ['Avg. histogram error: ' ...
            num2str(opts.histError, '%0.0f') '%'];
        xt = min(xs) + 0.1*xgap;
        yt = -0.5*yscale;
        text(xt, yt, msg, 'Color', opts.clr2, ...
            'FontSize', opts.FontSize + 6);
    end

    axis off;
    box off;
    plot.setPrintSize(gcf, opts);
end

function h = plotSingleHist(xs, ys, lw, clr, lnsty)
    h = plot(xs, ys, lnsty, 'Color', clr, 'LineWidth', lw);
end
