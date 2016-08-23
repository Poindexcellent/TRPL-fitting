
%     ModelTRPL.m analyzes and fits time-resolved photoluminescence (TRPL)
%     data to a model incorporating generation, diffusion, and recombination.
%     The script is intended to be modular such that different models for
%     generation, recombination, and diffusion can be swapped in and out in
%     sub-functions ('genFunc', 'diffFunc', and 'recombFunc').
% 
%     This model uses a 1D finite difference approach to calculate the
%     photoluminescence at every point in space and time within the film.
% 
%     Throughout ModelTRPL and all sub-functions, any values that need to be
%     hard-coded in are indicated with '#' symbols preceding comments.
%     Author's notes, used to note places for future improvement (as
%     distinguished from comments), are indicated by a double asterisk '**'.
% 
%     More information to be added later for version 2.0.
% 
%     Created January 29, 2016, Jeremy R. Poindexter
%     Last modified July 13, 2016, Jeremy R. Poindexter
%     Current version: v1.1

%% 0. **Version improvement notes:
%     1/29/2016 - 7/10/2016: v0.1
%     7/11/2016 - present: v1.0
% 
%     To improve in future versions:
%     - read a subset of data from figure rather than workspace (Section 1)
%     - implement selection of parameters via GUI and/or dialog boxes
%     (Sections 2-5)
%     - implement ambipolar diffusion (Section 3)
%     - test n^2 and n^3 recombination terms (Section 4)
%     - complete parameter "reporting" (Section 7)
%     - implement error and sensitivity analysis (Section 8)

    
%% 1. Set up data for analysis in new figure.

% **Do typical stuff, like load the data from a figure, but only if it's
% visible. Set this up to only analyze one curve at a time. If you find
% multiple visible curves, include some option / prompt to ask "which curve do
% you want to analyze?" or something similar.

% **For timeData, need prompts to select ONLY the data to be fitted from
% the broader data set


%% 2. Define generation.

% **Defining generation is the easiest because because there's no dependence on
% \Delta_n (and hence no worry about injection dependence, for example).

% **The generation parameters are *passed* to a function 'genFunc', which
% calculates the proper generation term / function.


%%% 2a-temp. Temporary hard-coded generation types and injection levels:
genType = 'delta';          %# temporary 'genType' declaration
injectType = 'low';         %# temporary 'injectType' declaration


%% 3. Define diffusion.

% **Start with a simple number, defined in cm^2/sec. Start with two options --
% minority-carrier, or ambipolar diffusion.

% **Raf's approach: diffusivity is a function of n, and the value for the
% previous timestep is used. Not strictly as accurate but may give similar
% results.

% **The diffusion parameters are *passed* to a function 'diffFunc', which will
% likely need to be in 'switch/case' form to deal with different cases for D,
% which is ultimately the output needed.


%%% 3a-temp. Temporary hard-coded recombination type:
diffType = 'p-type';


%% 4. Define recombination.

%** The hard one. In high injection, there are \Delta_n^2 and \Delta_n^3 terms.
% Rewriting these in matrix formulation might be tricky, or not possible,
% because equation is suddenly nonlinear. Hmm...

% **One can still use finite difference methods to calculate \Delta_n at a given
% point, with multiple (3?) 'for' loops. The complexity will vary for
% different recombination functions. Thus, different options should be passed
% to the 'recombFunc' function and may best be treated with different
% 'switch/case' functions.


%%% 4a-temp. Temporary hard-coded recombination type:
% % recombType = 'A';
recombType = 'D';
% % recombType = 'E';
% % recombType = 'C';

% Open a dialog box to choose options:

%%% **NEED TO GET THE FOLLOWING SECTION (for GUI) WORKING BETTER:
%{
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
%}


%% 5. Define boundary conditions (SRV).

% **Should be pretty easy, given SRV and D. Consider injection dependence of SRV
% as an option. Boundary conditions could be passed to a function like
% 'SRVcalc' or something, or simply incorprated into 'nSolve' directly.


%% 5-temp. Temporary declaration of parameters to fit (until GUI works)


% For 'fitThis', '1' = fit this parameter; '0' = do not fit this parameter.
fitThis = [1 1 0 ...     %# recombination coefficients
    1 ...      %# SRV
    0 ...      %# D
    0 ...      %# nBack
    0 ...      %# alpha
    0 ...      %# reflection
    0 ...      %# thickness
    0 ...      %# sigma
    0 ...      %# T
    0 ...      %# timeShift
    0 ...      %# PLshift
    0];        %# PL normalization factor


%% 6. Run PL fitting routine (see fitPL.m).

% % timeData = linspace(0,10,101);            %# trial time data
% % PLdata = exp(-timeData/0.8);              %# trial PL data


%%% 6a. Call 'fitPL' PL fitting routine:
fitTypes = {genType diffType recombType injectType};
fitPLparams = fitPL(fitThis,timeData,PLdata,fitTypes);


%%% 6b. Calculate fitted TRPL:
ParamsNames = {'SRH coefficient (s^{-1})',...
    'radiative coefficient (s^{-1}cm^3)',...
    'Auger coefficient (s^{-1}cm^6)', 'SRV (cm/s)', 'D (cm^2/s)',...
    'nBack (cm^{-3})', 'alpha (cm^{-1})', 'reflection', 'thickness (nm)',...
    'sigma', 'T', 'timeShift', 'PLshift', 'PL normalization factor'};

lifetimeNames = {'SRH', 'radiative', 'Auger'};

% **I'll need to update 'genType' and 'injectType' sometime.
[fittedPL, fittedDeltaN] = nSolve(fitPLparams.NewParams,timeData,fitTypes);


%%% 6c. Calculate lifetimes:
avgDeltaN = mean(mean(fittedDeltaN));     % the average over both x and t
[rContribute, lifetimes] = deal(ones(3,1));

lifetimes(1) = 1E9/fitPLparams.NewParams(1);
lifetimes(2) = 1E9/(fitPLparams.NewParams(2)*avgDeltaN);
lifetimes(3) = 1E9/(fitPLparams.NewParams(3)*avgDeltaN^2);


%%% 6d. Calculate contributions to total recombination rate:
rTotal = (avgDeltaN*ones(1,3)).^(1:3)*...
    [fitPLparams.NewParams(1);
    fitPLparams.NewParams(2);
    fitPLparams.NewParams(3)];
rContribute(1) = fitPLparams.NewParams(1)*avgDeltaN/rTotal;
rContribute(2) = fitPLparams.NewParams(2)*avgDeltaN^2/rTotal;
rContribute(3) = fitPLparams.NewParams(3)*avgDeltaN^3/rTotal;


%% 7. Plot, report, and format the results.


%%% 7a. Generate figure:
changePlotTRPL;     % script to change plot defaults

figure('Color','w','Position',[200 100 1000 600]);

PLdataColor = [0.7 0.7 0.7];        %# plot display color of original PL data
PLmarker = 2;                       %# plot marker size of original PL data


%%% 7b. Plot the original PL data:
s1 = subplot(1,3,1:2);
o1 = semilogy(timeData,PLdata,'o','Color',PLdataColor,'MarkerSize',PLmarker);
o1.DisplayName = 'PL data';
hold(s1,'on')


%%% 7c. Plot the fitted result:
o2 = semilogy(timeData,fittedPL,'-k');
o2.DisplayName = 'fit';
xlabel('time (ns)')
ylabel('normalized PL intensity')
grid on
legend({o1.DisplayName, o2.DisplayName})


%%% 7d. Display the fit parameters:
s2 = subplot(1,3,3);
Xtext = -0.2;
Ytext = 1;
textColor = hsv(length(fitThis))*0.6;
set(s2,'YTick','')
set(s2,'Visible','off')

for yy = find(fitThis)
    text(Xtext,Ytext-0.05*yy,sprintf('%s = %1.4g\n', ParamsNames{yy}, ...
        fitPLparams.NewParams(yy)),'Color',textColor(yy,:),...
        'FontSize',14,'FontWeight','bold')
    % Report any lifetimes and contributions to recombination rate:
    if yy < 4
        text(Xtext,0.2-0.05*yy,sprintf('%s = %3.1f (%2.1f %%)\n',...
            [lifetimeNames{yy} ' lifetime (ns)'],lifetimes(yy),...
            100*rContribute(yy)),...
            'Color',textColor(yy,:),'FontSize',14,'FontWeight','bold')
    end
    
end


%% 8. Error and sensitivity analysis

% **Need to figure out what to implement and how.


