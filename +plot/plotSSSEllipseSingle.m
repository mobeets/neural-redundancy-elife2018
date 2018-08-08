function plotSSSEllipseSingle(YA, YB, CA, CB, opts)
    if nargin < 5
        opts = struct();
    end
    defopts = struct('width', 4.5, 'height', 4.5, 'margin', 0.125, ...
        'FontSize', 24, 'FontName', 'Helvetica', 'TextNoteA', '', ...
        'TextNoteB', '', 'scaleDim', (1000/45), ...
        'LineWidth', 3, 'TextNoteFontSize', 24, 'MarkerSize', 12, ...
        'doSave', false, 'saveDir', 'data/plots', ...
        'filename', 'SSS_ellipse', 'ext', 'pdf', ...
        'clrs', [], 'sigMult', 2);
    opts = tools.setDefaultOptsWhenNecessary(opts, defopts);
    fig = plot.init(opts.FontSize, opts.FontName);
    
    % swap axes
%     YA(:,2) = -YA(:,2);
%     YB(:,2) = -YB(:,2);

    % mean-center data, because we just want to compare variance
    muA = mean(YA);
    muB = mean(YB);
    YA = bsxfun(@plus, YA, -muA);
    YB = bsxfun(@plus, YB, -muB);
    muA = mean(YA);
    muB = mean(YB);
    
    [bpA, ~, ~] = tools.gauss2dcirc([], opts.sigMult, CA);
    [bpB, ~, ~] = tools.gauss2dcirc([], opts.sigMult, CB);    

    plot(YA(:,1), YA(:,2), '.', 'Color', opts.clrs(1,:), ...
        'MarkerSize', opts.MarkerSize);
    plot(YB(:,1), YB(:,2), '.', 'Color', opts.clrs(2,:), ...
        'MarkerSize', opts.MarkerSize);
    
    bpA(1,:) = bpA(1,:) + muA(1);
    bpA(2,:) = bpA(2,:) + muA(2);
    bpB(1,:) = bpB(1,:) + muB(1);
    bpB(2,:) = bpB(2,:) + muB(2);
    plot(bpA(1,:), bpA(2,:), '-', 'Color', opts.clrs(1,:), 'LineWidth', opts.LineWidth);
    plot(bpB(1,:), bpB(2,:), '-', 'Color', opts.clrs(2,:), 'LineWidth', opts.LineWidth);
%     h = patch(bpB(1,:), bpB(2,:), opts.clrs(2,:));
%     h.FaceAlpha = 0.5;
%     h.EdgeColor = 'none';

    pad = 0.5;
    minx = min([bpA(1,:) bpB(1,:)]);
    miny = min([bpA(2,:) bpB(2,:)]);
    maxx = max([bpA(1,:) bpB(1,:)]);
    maxy = max([bpA(2,:) bpB(2,:)]);
    xlim([minx-pad maxx+pad]);
    ylim([miny-pad maxy+pad]);

    xlabel({'Activity, dim. 1', '(spikes/s, rel. to baseline)'});
    ylabel({'Activity, dim. 2', '(spikes/s, rel. to baseline)'});
    tcks = [-1.35 0 1.35];
    set(gca, 'XTick', tcks);
    set(gca, 'YTick', tcks);
    set(gca, 'XTickLabel', round(opts.scaleDim*tcks));
    set(gca, 'YTickLabel', round(opts.scaleDim*tcks));
    set(gca, 'TickDir', 'out');
    set(gca, 'LineWidth', max(opts.LineWidth-1,1));
    box off;
    axis square;

    xl = xlim; yl = ylim;
    text(xl(1)+0.1, 0.9*yl(2), opts.TextNoteA, 'Color', opts.clrs(1,:), ...
        'FontSize', opts.TextNoteFontSize);
    text(xl(1)+0.1, 0.9*yl(2) - 0.24, opts.TextNoteB, 'Color', opts.clrs(2,:), ...
        'FontSize', opts.TextNoteFontSize);

    plot.setPrintSize(fig, opts);
    if opts.doSave
        plot.export_fig(gcf, fullfile(opts.saveDir, ...
            [opts.filename '.' opts.ext]));
    end
