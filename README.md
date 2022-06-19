# Data-Driven Beamforming Codebook Design to Improve Coverage in Millimeter Wave Networks
M. F. Ozkoc,  C. Tunc, and S. Panwar, "Data-Driven Beamforming Codebook Design to Improve Coverage in Millimeter Wave Networks," *2022 IEEE 95th Vehicular Technology Conference (VTC2022-Spring)*

# Reproducing our results
1. [Download](https://drive.google.com/file/d/11dUKHF-V-a9NXozVCNMKTrDdP0EP5pwZ/view?usp=sharing) path information that we generated using Ray Tracing simulator, Remcom Wireless InSite. This includes BS locations, UE locations, AoA, AoD, power, and delays of each path.
2. Using the ray tracing information we can generate channel data for each transmitter antenna. [rayTracingToChannels](https://github.com/mustafafu/coverageCodebookDesign/blob/main/rayTracingToChannels.m) script provided for a simple 32 element ULA array. The antenna array can be changed by adjusting the TX elements location matrix.
