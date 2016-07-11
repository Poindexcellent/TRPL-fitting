function ModelTRPL(recombFunc,genFunc,diffFunc)

%     ModelTCSPC.m analyzes the TCSPC data in the current figure ...
%     ... finite difference...
%     ... define input arguments...

%     Designed to be used just after PlotTCSPC. Hide all plots you don't want
%     to fitThis. rFunc, gFunc, dFunc for
%     different functions
%   
%     Created January 29, 2016, Jeremy R. Poindexter
%     Last modified February 3, 2016, Jeremy R. Poindexter

%% 1. Set up data for analysis in new figure.

% Do typical stuff, like load the data from a figure, but only if it's
% visible. Set this up to only analyze one curve at a time. If you find
% multiple visible curves, include some option / prompt to ask "which curve do
% you want to analyze?" or something similar.


%% 2. Define generation.
%%% AUTHOR'S NOTE: Sections 2-5 could (should??) eventually be defined through
%%% dialog boxes or GUIs, for niceness -- but this is totally not necessary as
%%% a first pass.

% Defining generation is the easiest because because there's no dependence on
% \Delta_n (and hence no worry about injection dependence, for example).

% The generation parameters are *passed* to a function 'gFunc', which
% calculates the proper generation term / function.


%% 3. Define diffusion.

% Start with a simple number, defined in cm^2/sec. Start with two options --
% minority-carrier, or ambipolar diffusion.

% Raf's approach: diffusivity is a function of n, and the value for the
% previous timestep is used. Not strictly as accurate but may give similar
% results.

% The diffusion parameters are *passed* to a function 'dFunc', which will
% likely need to be in 'switch/case' form to deal with different cases for D,
% which is ultimately the output needed.


%% 4. Define recombination.

% The hard one. In high injection, there are \Delta_n^2 and \Delta_n^3 terms.
% Rewriting these in matrix formulation might be tricky, or not possible,
% because equation is suddenly nonlinear. Hmm...

% One can still use finite difference methods to calculate \Delta_n at a given
% point, with multiple (3?) 'for' loops. The complexity will vary for
% different recombination functions. Thus, different options should be passed
% to the 'rFunc' function and may best be treated with different 'switch/case'
% functions.


% Open a dialog box to choose options:

%%% NEED TO GET THIS WORKING BETTER.

% % d_ = dialog('Position',[300 300 400 400],'Name','Recombination.');
% % xpos = -600;    %# screen x-position of dialog box
% % ypos = 300;     %# screen y-position of dialog box
% % dwidth = 300;   %# screen width of dialog box
% % dheight = 150;  %# screen height of dialog box
% % 
% % recombType = zeros(3,1);
% % 
% % d_ = dialog('Position',[xpos ypos dwidth dheight],'Name','Set recombination preferences.');
% % 
% % txt = uicontrol('Parent',d_,'Style','text','Position',[0 dheight-20 dwidth-20 15],...
% %     'String','Check the desired recombination model.'); 
% % 
% % boxA = uicontrol('Parent',d_,'Style','checkbox',...
% %     'Position',[25 dheight-50 dwidth-20 15],...
% %     'String','monomolecular','CallBack',{@updateBox, boxA});
% % 
% % boxB = uicontrol('Parent',d_,'Style','checkbox',...
% %     'Position',[25 dheight-75 dwidth-20 15],...
% %     'String','bimolecular','CallBack',{@updateBox, boxB});
% % recombType(2) = boxB.Value;
% % 
% % boxC = uicontrol('Parent',d_,'Style','checkbox',...
% %     'Position',[25 dheight-100 dwidth-20 15],...
% %     'String','trimolecular','CallBack',{@updateBox, boxC});
% % recombType(3) = boxC.Value;
% % 
% % btn = uicontrol('Parent',d_,...
% %     'Position',[dwidth/2-35 20 70 25],...
% %     'String','Close',...
% %     'Callback','delete(gcf)');



%% 5. Define boundary conditions (SRV).

% Should be pretty easy, given SRV and D. Consider injection dependence of SRV
% as an option. Boundary conditions could be passed to a function like
% 'SRVcalc' or something, or simply incorprated into 'nSolve' (or whatever I
% end up calling my \Delta_n solver function) directly.

%% ** BEGIN RUN FITTING ROUTINE (in different function?)
%% 6A. Use finite-difference method to solve for carrier concentration.

% Solve carrier concentration as a function of x, and t. 2D matrix. Refer to
% outside function (e.g., 'nSolve') which handles many different cases of
% rFunc, gFunc, and dFunc. Build this from the ground up.


%% 6B. Calculate PL(t) from carrier concentration.

% Use finite difference method to calculate integral, or just use a simple
% trapzsum function (I forget the actual name, which is probably different).
% There's only one of these so... could define it here, at the end of this
% function, or in a different function. 'DeltaNtoPL.m'?


%% 6C. Run fitting program (lsqcurvefit or something similar) until solution converges.




fitThis = [1 0 0 ...     %# recombination coefficients
    0 ...      %# SRV
    1 ...      %# D
    0 ...      %# nBack
    0 ...      %# alpha
    0 ...      %# reflection
    0 ...      %# thickness
    0 ...      %# sigma
    0 ...      %# T
    0 ...      %# timeShift
    0 ...      %# PLshift
    0];        %# PL normalization factor



% % timeData = linspace(0,10,101);            %# trial time data
% % PLdata = exp(-timeData/0.8);              %# trial PL data

diagnose = fitPL(fitThis,timeData,PLdata);

genType = 'delta';
injectType = 'low';


%%% I'll need to update 'genType' and 'injectType' later.
ParamsNames = {'SRH coefficient (s^{-1})', 'radiative coefficient',...
    'Auger coefficient', 'SRV (cm/s)', 'D (cm^2/s)', 'nBack (cm^{-3})',...
    'alpha (cm^{-1})', 'reflection', 'thickness (nm)', 'sigma', 'T',...
    'timeShift', 'PLshift', 'PL normalization factor'};

fittedPL = nSolve(diagnose.NewParams,timeData,genType,injectType);

figure('Color','w','Position',[200 100 1000 600]);
s1 = subplot(1,3,1:2);
o1 = semilogy(timeData,PLdata,'o','Color',[0.7 0.7 0.7],'MarkerSize',2);
o1.DisplayName = 'PL data';
hold on;
o2 = semilogy(timeData,fittedPL,'--k');
o2.DisplayName = 'fit';
xlabel('time (ns)')
ylabel('normalized PL intensity')
grid on
legend({o1.DisplayName, o2.DisplayName})

s2 = subplot(1,3,3);
Xtext = -0.2;
Ytext = 1;
textColor = copper(14);
set(s2,'YTick','')
set(s2,'Visible','off')

for yy = find(fitThis)
    text(Xtext,Ytext-0.05*yy,sprintf('%s = %1.4g\n', ParamsNames{yy}, ...
        diagnose.NewParams(yy)),'Color',textColor(yy,:),...
        'FontSize',14,'FontWeight','bold')
    if yy == 1
        text(Xtext,0.1,sprintf('%s = %3.1f\n', 'SRH lifetime (ns)',...
            1E9*1/diagnose.NewParams(yy)),'Color',textColor(yy,:),...
            'FontSize',14,'FontWeight','bold')
    end
end




% % 
% % text(sb2,Xtext,Ytext,['\color[rgb]{' num2str(ColourSet(ll,1)) ',' num2str(ColourSet(ll,2)) ',' num2str(ColourSet(ll,3)) '}'...
% %         '\tau_1 = ' num2str(BiexpOutParams{ll}(2),'%.3f') '\pm' ...
% %         num2str((BiErrorInFit(2,2)-BiErrorInFit(2,1))/2,'%.3f') ' ns;    '...
% %         '\tau_2 = ' num2str(BiexpOutParams{ll}(4),'%.3f') '\pm' ...
% %         num2str((BiErrorInFit(4,2)-BiErrorInFit(4,1))/2,'%.3f') ' ns'],...
% %         'Fontsize',12,'Units','Normalized');


%% **END FITTING ROUTINE**


%% 7. Report all the parameters, calculate lifetime(s)


%% 8. Report error and perform some fancy sensitivity analysis if you want



end


    function boxValue = updateBox(boxName)
        boxValue = boxName.Value;
    end