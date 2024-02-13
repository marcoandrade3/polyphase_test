# This is a simple implementation of a half-band FIR filter
# Using the sinc function and Blackman window as a low-pass filter with fc = 0.25. 

# Import libraries
import numpy as np

def half_band_fir(transition_bandwith, fs):
    # First calculate the size of the filter
    b = transition_bandwith / fs
    N = 4 / b
    # Adjusts for odd
    if (N % 2 == 0):
        N = N + 1
    
    # Calculates blackman and filter
    n = np.arange(N)
    filter = np.sinc(2*0.25* (n - (N - 1) / 2))
    window = np.blackman(N)
    
    # Multiplies, normalizes, returns
    filter = filter * window
    return filter / np.sum(filter)

