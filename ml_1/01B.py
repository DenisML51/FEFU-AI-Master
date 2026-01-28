import numpy as np

n = int(input())
f_series = np.array(input().split(), dtype=float)
window_size = 10
if n < window_size:
    window_size = n

rank = 5
if rank >= window_size:
    rank = window_size - 1

f_tail = f_series[-window_size:]
x_tail = np.arange(window_size)
coeffs = np.polyfit(x_tail, f_tail, rank)
next_x = window_size
prediction = np.polyval(coeffs, next_x)
print(f"Prediction: {prediction:.10f}")
