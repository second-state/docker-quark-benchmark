#!/usr/bin/env python3

import os
import re
import sys
import statistics

BENCHMARKS = [
    'benchmark_runc_nodejs',
    'benchmark_quark_nodejs',
    'benchmark_gvisor_nodejs',
    'benchmark_wasmedge_quickjs',
]

def get_log_dir():
    utils_dir = os.path.dirname(os.path.realpath(__file__))
    log_dir = os.path.join(os.path.dirname(utils_dir), 'log')
    return log_dir

def get_data():
    result = {}
    for benchmark_name in BENCHMARKS:
        result[benchmark_name] = {}
        log_file = os.path.join(get_log_dir(), benchmark_name)
        if not os.path.isfile(log_file):
            print(f'{log_file} not exist.')
            return None
        with open(log_file, 'r') as f:
            # container_start_time = js - start
            container_start_time = []
            # container_execution_time = end - js
            container_execution_time = []
            max_memory_usage = []
            current_timestamp = 0
            current_max_memory_usage = 0
            for line in f.readlines():
                m = re.match(r'^(start|js|end|memory_usage): ([\d\.]+)', line)
                if m is not None:
                    action = m.group(1)
                    if action == 'start':
                        timestamp = float(m.group(2))
                        current_timestamp = timestamp
                    elif action == 'js':
                        timestamp = float(m.group(2))
                        container_start_time.append(timestamp - current_timestamp)
                        current_timestamp = timestamp
                    elif action == 'end':
                        timestamp = float(m.group(2))
                        container_execution_time.append(timestamp - current_timestamp)
                        max_memory_usage.append(current_max_memory_usage)
                        current_max_memory_usage = 0
                m = re.match(r'^memory_usage: ([\d\.]+)(G|M)iB', line)
                if m is not None:
                    memory_usage = float(m.group(1))
                    unit = m.group(2)
                    if unit == 'G':
                        memory_usage = memory_usage * 1024
                    current_max_memory_usage = max(memory_usage, current_max_memory_usage)
            result[benchmark_name]['container_start_time'] = container_start_time
            result[benchmark_name]['container_execution_time'] = container_execution_time
            result[benchmark_name]['max_memory_usage'] = max_memory_usage
    return result

def print_data(data):
    for action in ('container_start_time', 'container_execution_time', 'max_memory_usage'):
        print(f'### {action}')
        print('benchmark_name'.ljust(30) +
              'min'.rjust(9) +
              'max'.rjust(9) +
              'avg'.rjust(9) +
              'std'.rjust(9))
        for benchmark_name in BENCHMARKS:
            d = data[benchmark_name][action]
            minimum = min(d)
            maximum = max(d)
            average = statistics.mean(d)
            stdev = 0 if len(d) < 2 else statistics.stdev(d)
            print(f'{benchmark_name:30}'
                  f'{minimum:9.3f}'
                  f'{maximum:9.3f}'
                  f'{average:9.3f}'
                  f'{stdev:9.3f}')
        print()

def main():
    data = get_data()
    print_data(data)

if __name__ == '__main__':
    main()
