% % nSolveTest

%% Plot DeltaN vs. depth:

changePlotTRPL;
f1 = figure;
a1 = axes;

endplot = 10;    %# hard code in first __ curves to plot
plotSpan = 20;   %# hard code in number of plots
timeIncrement = floor(numTPts/plotSpan);
depthIncrement = floor(numYPts/plotSpan);

BB = 0;

% % plottype = 'endplot';
plottype = 'plotSpan';

switch plottype
    case 'endplot'
        plotarg = endplot;
        timeloopvector = 1:endplot;
        
    case 'plotSpan'
        plotarg = plotSpan+1;
        timeloopvector = 1:timeIncrement:numTPts;
        depthloopvector = 1:depthIncrement:numYPts;
end

prettyplot = jet(plotarg);
Llabel = cell(plotarg,1);
Llabel2 = cell(plotarg,1);

for AA = timeloopvector
    
    BB = BB + 1;
    semilogy(a1,depthVect,DeltaN(:,AA),'color',prettyplot(BB,:))
    hold(a1,'on')
    Llabel{BB} = [sprintf('%1.1f', timeVect(AA)) ' ns'];
    
end

ylabel(a1,'\Deltan (cm^{-3})')
xlabel(a1,'depth (nm)')
legend(a1,Llabel,'FontSize',8)

%%  Plot DeltaN vs. time:

f2 = figure;
a2 = axes;

DD = 0;

for CC = depthloopvector
    
    DD = DD + 1;
    semilogy(a2,timeVect,DeltaN(CC,:),'color',prettyplot(DD,:))
    hold(a2,'on')
    Llabel2{DD} = [sprintf('%1.1f', depthVect(CC)) ' nm'];
    
end

ylabel(a2,'\Deltan (cm^{-3})')
xlabel(a2,'time (ns)')
legend(a2,Llabel2,'FontSize',8)

