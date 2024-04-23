# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
" This is arlpy.readthedocs.io testing for Bellhop"

pip install arlpy
import arlpy
import os
import shutil

#Find where bellhop is, then set path
os.chdir(r"C:\Users\fmm17241\OneDrive - University of Georgia\data\toolbox\AT\windows-bin-20201102")

#Import
import arlpy.uwapm as pm
import arlpy.plot as plt
import numpy as np
import matplotlib.pyplot as plt


###################################################################

#Sets bottom boundary layer of the environment
bathy = [
    [0, 15],    # 20 m water depth at the transmitter
    [300, 16],  # 15 m water depth 300 m away
    [350, 18],  # 15 m water depth 300 m away
    [450, 20]  # 20 m water depth at 600 m
]

#Changes soundspeed profile
ssp = [
    [ 0, 1540],  # 1540 m/s at the surface
    [10, 1530],  # 1530 m/s at 10 m depth
    [15, 1532],  # 1532 m/s at 20 m depth
    [20, 1533],  # 1533 m/s at 25 m depth
]

#Changes the surface, wave motion
surface = np.array([[r, 0.5+0.5*np.sin(2*np.pi*0.005*r)] for r in np.linspace(0,450,451)])

#Creates new environment, accounting for change in SSP and bathy, then prints & plots. This is for transmission loss.
env = pm.create_env2d(
    frequency=600,
    rx_range= 450,
    rx_depth= 19,
    depth=bathy,
    soundspeed=ssp,
    bottom_soundspeed=1450,
    bottom_density=1200,
    bottom_absorption=0.0,
    tx_depth=14,
    surface = surface

)
pm.print_env(env)

#Computes coherent transmission loss through the environment
tloss = pm.compute_transmission_loss(env,mode='coherent')
pm.plot_transmission_loss(tloss, env=env, clim=[-60,-30], width=900,title='Coherent Loss: 0.6 kHz', clabel='Noise Loss (dBs)')


#CComputes incoherent transmission loss through the environment
tloss = pm.compute_transmission_loss(env, mode='incoherent')
pm.plot_transmission_loss(tloss, env=env, clim=[-60,-30], width=900,title='Incoherent Loss: 69 kHz', clabel='Noise Loss (dBs)')

rays = pm.compute_eigenrays(env)
pm.plot_rays(rays, env=env,width=900,title='Eigenray Analysis')

#Computes the arrival time of rays from T to R
arrivals = pm.compute_arrivals(env)
pm.plot_arrivals(arrivals, width=900)

#Table of arrival times
arrivals[arrivals.arrival_number < 10][['time_of_arrival', 'angle_of_arrival', 'surface_bounces', 'bottom_bounces']]






#CComputes incoherent transmission loss through the environment
tloss = pm.compute_transmission_loss(env, mode='incoherent')
pm.plot_transmission_loss(tloss, env=env, clim=[-60,-30], width=900)


rays = pm.compute_rays(env)
pm.plot_rays(rays, env=env,width=900)


#Creates new environment, accounting for change in SSP and bathy, then prints & plots. This is for transmission loss.
env = pm.create_env2d(
    frequency=600,
    rx_range= np.linspace(0, 450, 1001),
    rx_depth= np.linspace(0, 20, 301),
    depth=bathy,
    soundspeed=ssp,
    bottom_soundspeed=1450,
    bottom_density=1200,
    bottom_absorption=0.0,
    tx_depth=13,
    surface = surface
)
pm.print_env(env)



