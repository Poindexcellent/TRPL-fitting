function R = recombFunc(recombType,rateConstants)

% recombFunc produces a m-by-1 vector 'recombFuncOut' that contains the rate constant coefficients of the recombination
% expression. The recombination mechanism to try (and thus the size of 'recombFuncOut') is determined by the tag
% 'recombType'.

% Description of input arguments:
% 'recombType' = a character variable that describes the user-specified recombination model to try.
% A) "monomolecular" - 
% B) "bimolecular" - 
% C) "trimolecular" - 

% 'rateConstants' = a m-by-1 vector that containts the rate constant coefficients.


% The output, 'R', is a m-by-1 vector that contains the rate constant coefficients.

% Created February 5, 2016, Jeremy R. Poindexter.
% Last modified March 18, 2016, Jeremy R. Poindexter.


% Set all to zero at outset:
[k1, k2, k3] = deal(0);

% Dialog box to pick options: (there are six:)


%{
Cases:
'A' = monomolecular
'B' = bimolecular
'C' = trimolecular
'D' = mono+bi
'E' = bi+tri
'F' = mono+bi+tri
%}



switch recombType
    case 'A'
        k1 = rateConstants(1);
    case 'B'
        k2 = rateConstants(2);
    case 'C'
        k3 = rateConstants(3);
    case 'D'
        k1 = rateConstants(1);
        k2 = rateConstants(2);
    case 'E'
        k2 = rateConstants(2);
        k3 = rateConstants(3);
    case 'F'
        k1 = rateConstants(1);
        k2 = rateConstants(2);
        k3 = rateConstants(3);
    otherwise
        error('Please select some checkboxes...')
end

R = [k1; k2; k3];


        
    % 'monomolecular' - k1; k2 = k3 = 0 (SRH only)
    % 'bimolecular only' - k2; k1 = k3 = 0  (radiative only)
    % 'trimolecular only' - k3; k1 = k2 = 0     (Auger only)
    
    % 'monomolecular + bimolecular' - k1 & k2; k3 = 0
    % ...etc....
   



end