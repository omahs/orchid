
import os
import re

def extract_dependencies(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    matches = re.findall(r'import\s+[\'"]package:orchid/(.*?)/', content)
    dependencies = {match.split('/')[0] for match in matches}
    return dependencies

def analyze_package_dependencies(package_path, package_name):
    dependencies = set()
    for root, _, files in os.walk(package_path):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                dependencies |= extract_dependencies(file_path)
    dependencies.discard(package_name)
    return dependencies

def main():
    lib_dir = "./lib"  # replace with your lib directory path
    lib_file_list = os.listdir(lib_dir)

    package_dependencies = {
        package: analyze_package_dependencies(os.path.join(lib_dir, package), package)
        for package in lib_file_list
        if os.path.isdir(os.path.join(lib_dir, package))
    }

    #print(package_dependencies)
    for package, dependencies in package_dependencies.items():
        print(f"{package}: {', '.join(sorted(dependencies))}")

if __name__ == "__main__":
    main()
