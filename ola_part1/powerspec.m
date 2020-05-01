function powerspec(x, fs)
    L = length(x);
    xf = fft(x);
    p2 = abs(xf/L);
    p1 = p2(1:L/2+1);
    p1(2:end-1) = 2*p1(2:end-1);
    f = fs * (0:L/2) / L;
    
    figure
    plot(f,p1)
    xlabel('frequency (Hz)')
    ylabel('Power')
end