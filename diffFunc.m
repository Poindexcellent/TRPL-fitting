function D = diffFunc(diffType,diffValIn,nIn,injectType)

% diffFunc produces a scalar 'diffFuncOut' that is the calculated diffusion coefficient given a certain set of assumptions
% (specified by the 'diffType' tag) and the injection level (specified by nIn).

% Description of input arguments:

% 'diffType' = a character variable that describes the type of diffusivity to calculate. It can have the following
% values:
% A) "p-type" - diffusivity calculated for minority electrons
% B) "n-type" - diffusivity calculated for minority holes
% C) "ambipolar" - ambipolar diffusivity calculated; assumes n = p



% The output, 'D', is the (scalar) value of the diffusivity (cm^2/s).

% Created February 5, 2016, Jeremy R. Poindexter.
% Last modified February 19, 2016, Jeremy R. Poindexter.

D = diffValIn;
% % D = 0.25;     %# temporary hard-coded value for output (cm^2/s)
% % D = 1E-4;

switch lower(diffType)
    case 'p-type'
        D = diffValIn;
    case 'n-type'
    case 'ambipolar'
    otherwise
end

end