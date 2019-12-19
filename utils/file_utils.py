def read_file_content(path):
    result = ''
    with open(path, 'r') as f:
        for line in f.readlines():
            result += line
    return result


def get_file_name(path):
    if '/' in path:
        return path.split('/')[-1]
    else:
        return path
