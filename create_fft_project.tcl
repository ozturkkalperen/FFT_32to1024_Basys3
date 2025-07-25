# Vivado TCL Script for FFT Processor Project Creation
# Compatible with Vivado 2022.2

# Set project variables
set project_name "fft_processor_basys3"
set project_dir "./vivado_project"
set part_name "xc7a35tcpg236-1"

# Create project
create_project $project_name $project_dir -part $part_name -force

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Verilog [current_project]

# Add source files
add_files -norecurse {
    data_generator.v
    seven_segment_driver.v
    uart_tx.v
    magnitude_calculator.v
    peak_detector.v
    uart_data_sender.v
    top_fft_processor.v
}

# Add constraints file
add_files -fileset constrs_1 -norecurse basys3_constraints.xdc

# Add testbench files
add_files -fileset sim_1 -norecurse tb_top_fft_processor.v

# Set top module
set_property top top_fft_processor [current_fileset]

# Create FFT IP
puts "Creating FFT IP Core..."

# Create IP catalog
create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name fft_ip_core

# Configure FFT IP
set_property -dict [list \
    CONFIG.channels {1} \
    CONFIG.transform_length {Variable} \
    CONFIG.target_clock_frequency {100} \
    CONFIG.target_data_throughput {50} \
    CONFIG.implementation_options {pipelined_streaming_io} \
    CONFIG.run_time_configurable_transform_length {true} \
    CONFIG.data_format {fixed_point} \
    CONFIG.input_width {16} \
    CONFIG.phase_factor_width {16} \
    CONFIG.scaling_options {scaled} \
    CONFIG.rounding_modes {convergent_rounding} \
    CONFIG.aclken {false} \
    CONFIG.aresetn {true} \
] [get_ips fft_ip_core]

# Generate IP
generate_target all [get_files $project_dir/$project_name.srcs/sources_1/ip/fft_ip_core/fft_ip_core.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] $project_dir/$project_name.srcs/sources_1/ip/fft_ip_core/fft_ip_core.xci]
launch_runs fft_ip_core_synth_1 -jobs 8
wait_on_run fft_ip_core_synth_1

puts "FFT IP Core generated successfully!"

# Set synthesis options for better performance
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# Create runs for different FFT sizes (for benchmarking)
set fft_sizes {32 64 128 256 512 1024}

foreach size $fft_sizes {
    set run_name "synth_fft_${size}"
    create_run $run_name -parent_run synth_1 -flow {Vivado Synthesis 2022}
    set_property generic "FFT_SIZE=$size" [get_runs $run_name]
    puts "Created synthesis run for FFT size $size"
}

puts "Project created successfully!"
puts "Project location: $project_dir"
puts ""
puts "Next steps:"
puts "1. Open the project in Vivado GUI: vivado $project_dir/$project_name.xpr"
puts "2. Replace the FFT IP placeholder in top_fft_processor.v with actual IP instantiation"
puts "3. Run synthesis and implementation for different FFT sizes"
puts "4. Generate utilization, timing, and power reports"
puts ""
puts "To run synthesis for all FFT sizes:"
foreach size $fft_sizes {
    puts "launch_runs synth_fft_${size} -jobs 8"
}

# Optional: Launch synthesis for 32-point FFT as default
puts ""
puts "Launching synthesis for 32-point FFT..."
launch_runs synth_fft_32 -jobs 8

puts "Script completed successfully!"