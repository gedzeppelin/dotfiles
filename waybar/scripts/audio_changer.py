#!/usr/bin/env python 
import subprocess

def parse_wpctl_status():
    output = str(subprocess.check_output("wpctl status", shell=True, encoding="utf-8"))
    lines = output.replace("├", "").replace("─", "").replace("│", "").replace("└", "").splitlines()

    sinks_index = None
    for index, line in enumerate(lines):
        if "Sinks:" in line:
            sinks_index = index
            break

    sinks = []
    for line in lines[sinks_index +1:]:
        if not line.strip():
            break
        sinks.append(line.strip())

    for index, sink in enumerate(sinks):
        sinks[index] = sink.split("[vol:")[0].strip()

    for index, sink in enumerate(sinks):
        if sink.startswith("*"):
            del sinks[index]

    if len(sinks) == 0:
        return None

    return sinks[0].split(".")[0]

next_sink_id = parse_wpctl_status()

if next_sink_id is not None:
    subprocess.run(f"wpctl set-default {next_sink_id}", shell=True)
