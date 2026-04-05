#!/bin/bash

# CPU usage
cpu=$(top -bn1 | awk -F',' '/Cpu/ {
  for(i=1;i<=NF;i++){
    if($i ~ /us/){gsub(/[^0-9.]/,"",$i); u=$i}
    if($i ~ /sy/){gsub(/[^0-9.]/,"",$i); s=$i}
  }
  printf("%.1f", u + s)
}')

# Memory (GB)
read mem_used mem_total <<< $(free -m | awk '/Mem:/ {printf("%.1f %.1f", $3/1024, $2/1024)}')

# Disk usage
disk=$(df -h / | awk 'NR==2 {print $5}')

# CPU Temperature
temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
temp_c=$((temp / 1000))

# NVIDIA GPUs
gpu_tooltip=""
if command -v nvidia-smi &>/dev/null; then
    nvidia_info=$(nvidia-smi --query-gpu=index,temperature.gpu,power.draw --format=csv,noheader,nounits)
    while IFS=',' read -r idx temp power; do
        idx=$(echo "$idx" | xargs)
        temp=$(echo "$temp" | xargs)
        power=$(echo "$power" | xargs)
        gpu_tooltip+="GPU$idx Temp: ${temp}°C, Power: ${power}W"
    done <<< "$nvidia_info"
else
    gpu_tooltip="NVIDIA GPU not detected"
fi

# Tooltip
tooltip="CPU: $cpu% ($temp_c°C)\nMemory: ${mem_used}GB / ${mem_total}GB\nDisk: $disk\n$gpu_tooltip"

# Waybar output
printf '{"text": "", "tooltip": "%s"}\n' "$tooltip"