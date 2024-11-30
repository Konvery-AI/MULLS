#!/bin/bash

# Set the directory containing the PCD files
pcd_dir="/home/ubuntu/MULLS/demo_data/pcd_shucai"

# Get a sorted list of PCD files
pcd_files=($(ls -1 "$pcd_dir"/*.pcd | sort))

# Check if there are at least two PCD files
if [ ${#pcd_files[@]} -lt 2 ]; then
    echo "Error: At least two PCD files are required."
    exit 1
fi

# Set the initial target PCD file (first file in the sorted list)
target_pcd="${pcd_files[0]}"

# Set the output directory
output_dir="/home/ubuntu/MULLS/demo_data/results"
mkdir -p "$output_dir"

# Loop through the remaining PCD files
for ((i=1; i<${#pcd_files[@]}; i=i+2)); do
    source_pcd="${pcd_files[i]}"
    output_pcd="$output_dir/transformed_$(basename "$source_pcd")"
    
    echo "Processing: $source_pcd"
    
    # Run MULLS registration
    ./bin/mulls_reg \
    --colorlogtostderr=true \
    -stderrthreshold 0 \
    -log_dir ./log/test \
    --v=10 \
    --point_cloud_1_path="$target_pcd" \
    --point_cloud_2_path="$source_pcd" \
    --output_point_cloud_path="$output_pcd" \
    --realtime_viewer_on=false \
    --cloud_1_down_res=0.00 \
    --cloud_2_down_res=0.00 \
    --dist_inverse_sampling_method=2 \
    --pca_neighbor_radius=1.0 \
    --pca_neighbor_count=50 \
    --gf_grid_size=2.0 \
    --gf_in_grid_h_thre=0.25 \
    --gf_neigh_grid_h_thre=1.2 \
    --gf_ground_down_rate=10 \
    --gf_nonground_down_rate=3 \
    --linearity_thre=0.65 \
    --planarity_thre=0.65 \
    --curvature_thre=0.10 \
    --reciprocal_corr_on=false \
    --fixed_num_corr_on=false \
    --corr_dis_thre=3.0 \
    --converge_tran=0.001 \
    --converge_rot_d=0.01 \
    --reg_max_iter_num=10 \
    --teaser_on=true
    
    # Set the output as the new target for the next iteration
    target_pcd="$output_pcd"
done

echo "Multi-frame registration complete. Results are in $output_dir"
