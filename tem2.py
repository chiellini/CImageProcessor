import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import quad

# Define curve functions
def f2(x):
    return 0.33464 + 33.17 / (x**3)

def f4(x):
    return 0.26557 + 1475.41 / (x**3)

def f6(x):
    return 0.27803 + 81967.21 / (x**3)

# Compute areas in given ranges
area_5_20, _ = quad(f2, 5, 20)  # Integral for [5,20]
area_20_100 = 0.45 * (100 - 20)  # Rectangle for [20,100]
area_100_136, _ = quad(f6, 100, 136)  # Integral for [100,136]

# Start plotting
plt.figure(figsize=(10, 6))

# Plot lines and markers
x_seg2 = np.linspace(5, 20, 100)
y_seg2 = f2(x_seg2)
plt.plot(x_seg2, y_seg2, color='blue', linestyle='-', linewidth=2)

plt.plot([20, 100], [0.45, 0.45], color='blue', linestyle='-', marker='o', markerfacecolor='red', markeredgecolor='black')

x_seg6 = np.linspace(100, 136, 100)
y_seg6 = f6(x_seg6)
plt.plot(x_seg6, y_seg6, color='blue', linestyle='-', linewidth=2)

# Fill areas
plt.fill_between(x_seg2, y_seg2, color='lightblue', alpha=0.5, label=f'Area [5,20] = {area_5_20:.4f}')
plt.fill_between([20, 100], [0.45, 0.45], color='yellow', alpha=0.5, label=f'Area [20,100] = {area_20_100:.4f}')
plt.fill_between(x_seg6, y_seg6, color='lightcoral', alpha=0.5, label=f'Area [100,136] = {area_100_136:.4f}')

# Label area values on the graph
areas_values = [area_5_20, area_20_100, area_100_136]
positions = [(10, 0.5), (60, 0.46), (118, 0.34)]
for pos, area in zip(positions, areas_values):
    plt.text(pos[0], pos[1], f"{area:.4f}", fontsize=10, color='black', ha='center')

# Add tick marks and labels
plt.xticks([5, 20, 100, 136], labels=["5", "20", "100", "136"])
plt.yticks([0.6, 0.45, 0.36, 0.32])

# Add labels, title, and grid
plt.xlabel("Frequency (10 thousand times)")
plt.ylabel("Unit")
plt.title("Hand-drawn Line Chart - Annotated Area")
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend()

# Show the plot
plt.show()
