function saveFigsTRPL(f_)


% % p = uigetdir('\\becquerel\pvlab\TCSPC');
p = uigetdir;

for i = 1:length(f_)
    fname = get(f_(i),'name');
    savepath = [p '\' fname '.fig'];
    saveas(f_(i),savepath)
end


end