#include <iostream>
#include <string>
#include <vector>
#include <dirent.h>
#include <sys/stat.h>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/point_cloud.h>

// ... existing code ...

int main(int argc, char** argv) {
    std::string result_dir = "demo_data/result";
    std::string output_file = "demo_data/merged_cloud.pcd";

    // Check if the directory exists
    struct stat info;
    if (stat(result_dir.c_str(), &info) != 0 || !(info.st_mode & S_IFDIR)) {
        std::cerr << "Error: " << result_dir << " does not exist or is not a directory." << std::endl;
        return 1;
    }

    pcl::PointCloud<pcl::PointXYZI>::Ptr merged_cloud(new pcl::PointCloud<pcl::PointXYZI>);

    // Iterate through all PCD files in the directory
    DIR* dir;
    struct dirent* entry;
    dir = opendir(result_dir.c_str());
    if (dir == nullptr) {
        std::cerr << "Error opening directory: " << result_dir << std::endl;
        return 1;
    }

    while ((entry = readdir(dir)) != nullptr) {
        std::string filename = entry->d_name;
        if (filename.length() > 4 && filename.substr(filename.length() - 4) == ".pcd") {
            std::string full_path = result_dir + "/" + filename;
            pcl::PointCloud<pcl::PointXYZI>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZI>);
            if (pcl::io::loadPCDFile<pcl::PointXYZI>(full_path, *cloud) == -1) {
                std::cerr << "Error loading file: " << full_path << std::endl;
                continue;
            }
            *merged_cloud += *cloud;
            std::cout << "Merged: " << full_path << std::endl;
        }
    }
    // Save the merged point cloud
    if (pcl::io::savePCDFileBinary(output_file, *merged_cloud) == -1) {
        std::cerr << "Error saving merged cloud to " << output_file << std::endl;
        return 1;
    }
    std::cout << "Merged cloud saved to: " << output_file << std::endl;
    std::cout << "Total points in merged cloud: " << merged_cloud->size() << std::endl;
    closedir(dir);

}