# Data-Driven Beamforming Codebook Design to Improve Coverage in Millimeter Wave Networks
M. F. Ozkoc,  C. Tunc, and S. Panwar, "Data-Driven Beamforming Codebook Design to Improve Coverage in Millimeter Wave Networks," *2022 IEEE 95th Vehicular Technology Conference (VTC2022-Spring)*

# Reproducing our results
1. [Download](https://drive.google.com/file/d/11dUKHF-V-a9NXozVCNMKTrDdP0EP5pwZ/view?usp=sharing) path information that we generated using Ray Tracing simulator, Remcom Wireless InSite. This includes BS locations, UE locations, AoA, AoD, power, and delays of each path.
2. Using the ray tracing information we can generate channel data for each transmitter antenna. [rayTracingToChannels](https://github.com/mustafafu/coverageCodebookDesign/blob/main/rayTracingToChannels.m) script provided for a simple 32 element ULA array. The antenna array can be changed by adjusting the TX elements location matrix.
3. Generate codebooks with proposed and baseline algorithms using the [Main](https://github.com/mustafafu/coverageCodebookDesign/blob/main/main.m) script.
4. We used NYU HPC for running the design algorithms in every parameter scenario, I can share the final data and HPC scripts with interested readers. Please contact Mustafa through the email given in the paper.

## Abstract: 
In 5G systems, a predefined codebook with a limited number of beams is 
used during the initial access and beam management procedures to
establish and maintain the connection between the users and the
network. At 5G millimeter wave (mmWave) frequencies, due to the very
narrow and directional beams obtained by beamforming, intelligently
designing a codebook with a limited number of beams is crucial to
avoid coverage holes. We formulate an optimization problem for the
beam-codebook design to maximize the coverage probability, which is a
quadratically-constrained mixed-integer problem. We propose a set of
data-driven codebook design algorithms to solve the optimization
problem, which, for a given codebook size constraint, adapts the
codebook to the deployment scenario using the provided input channel
data. For a sample deployment scenario, we show that as the codebook
size increases, the proposed algorithms converge to the upper bound in
terms of the coverage probability much faster than several benchmark
algorithms. Hence, the proposed algorithms can achieve the coverage
levels of benchmark algorithms with a much smaller codebook size. This
can significantly reduce the initial access, beam management, and
handover delays, which in turn provide higher data rates, lower
latency, and lower interruption times.


## Main Contributions
Our main contributions can be summarized as follows:

-   We formulate a data-driven beamforming codebook design problem to
    improve the coverage performance of a network by intelligently
    designing the beamforming codebook for a given codebook size
    constraint.

-   We propose a set of heuristic algorithms to solve the
    coverage-optimal codebook design problem, which outperforms the
    benchmark codebook design algorithms in terms of the coverage/outage
    probability.

-   The proposed receiver channel-based codebook selection algorithm,
    outperforms other benchmark and heuristic
    algorithms for all scenarios we considered. Moreover, the proposed
    cluster-based proportional beam waterfilling algorithm,
    performs well especially for low levels of
    signal-to-noise-ratio (SNR), which shows its effectiveness to
    improve the coverage of users with poor channel conditions.
