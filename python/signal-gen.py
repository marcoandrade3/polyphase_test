import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin, lfilter

def generate_signal(max_freq, duration=1):
    # Set the sampling frequency to more than twice the max frequency
    fs = max_freq * 2.5
    t = np.arange(0, duration, 1/fs)

    # Generate a signal with frequency components up to the max frequency
    input_signal = np.sum([np.sin(2 * np.pi * f * t) for f in np.linspace(10, max_freq, 10)], axis=0)

    # Design a half-band low-pass FIR filter
    numtaps = 31
    cutoff = fs / 4
    hb_filter = firwin(numtaps, cutoff, window='hamming', scale=False, nyq=fs/2)

    # Apply the filter and decimate
    filtered_signal = lfilter(hb_filter, 1.0, input_signal)
    decimated_signal = filtered_signal[::2]

    return t, input_signal, filtered_signal, decimated_signal

