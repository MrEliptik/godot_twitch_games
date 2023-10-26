import subprocess

project_file = 'project.godot'

def parse_build_nb_from_file(file):
    # If you have a better way of parsing the file, tell me!
    with open(file, 'r', encoding='UTF-8') as f:
        for line in f:
            if 'config/version' in line:
                number = line.strip().split("config/version=", 1)[1]
                number = number.replace('"', '')
                return number

## Assume 'git' is available
def create_and_push_tag(version):
    # Execute git tag
    cmd = ['git', 'tag', version]
    print("    |---> Executing command: ", cmd)

    with subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, encoding='utf-8') as sp:
        for line in sp.stdout:
            print(line.strip())

    # Execute git push
    cmd = ['git', 'push', '--tags']
    print("    |---> Executing command: ", cmd)

    with subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, encoding='utf-8') as sp:
        for line in sp.stdout:
            print(line.strip())

def main():
    version = parse_build_nb_from_file(project_file)
    version = 'v' + version

    create_and_push_tag(version)

if __name__ == '__main__':
    main()