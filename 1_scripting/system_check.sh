#!/bin/bash

check_os_name() {
  echo "- OS -"
  expected_value='Ubuntu'
  os_name=$(grep '^NAME=' /etc/os-release | cut -f2 -d'=' | tr -d '"')

  echo "expected value: ${expected_value}"
  echo "set value: ${os_name}"  
  if [[ "${os_name}" == "${expected_value}" ]]; then
    echo -e "\e[32mOS - PASSED\e[0m"
    echo ""
    return 0
  fi

  echo -e "\e[31mOS - FAILED\e[0m"
  echo ""
  return 1
}

check_ubuntu_version() {
  echo "- Major version -"
  maximum_version='20'
  major_version=$(grep VERSION_ID /etc/os-release | cut -f2 -d'=' | tr -d '"' | cut -f1 -d'.')
  
  echo "expected value: <= ${maximum_version}"
  echo "set value: ${major_version}"
  if [[ $((major_version)) -le $((maximum_version)) ]]; then
    echo -e "\e[32mVersion - PASSED\e[0m"
    echo ""
    return 0
  fi

  echo -e "\e[31mVersion - FAILED\e[0m"
  echo ""
  return 1
}

check_vcpu_count() {
  echo "- Number of vCPUs -"
  expected_value='8'
  cpu_count=$(grep -c '^processor' /proc/cpuinfo)

  echo "expected value: >= ${expected_value}"
  echo "set value: ${cpu_count}"  
  if [[ $((cpu_count)) -ge $((expected_value)) ]]; then
    echo -e "\e[32mvCPU - PASSED\e[0m"
    echo ""
    return 0
  fi

  echo -e "\e[31mvCPU - FAILED\e[0m"
  echo ""
  return 1
}

check_avx_support() {
  echo "- AVX support -"
  expected_value='true'
  avx_support=$(lscpu | grep '^Flags:' | grep avx > /dev/null && echo 'true' || echo 'false')

  echo "expected value: ${expected_value}"
  echo "set value: ${avx_support}"  
  if [[ "${expected_value}" == "${avx_support}" ]]; then
    echo -e "\e[32mAVX support - PASSED\e[0m"
    echo ""
    return 0
  fi

  echo -e "\e[31mAVX support - FAILED\e[0m"
  echo ""
  return 1
}

check_ram() {
  echo "- RAM -"
  expected_value='16'
  ram_value=$(free -m | awk '/Mem:/ {printf "%.2f\n", $2/1024}' | tr ',' '.')

  echo "expected value: >= ${expected_value}GB"
  echo "set value: ${ram_value}GB"
  if [ $(echo "${ram_value} > ${expected_value}" | bc) -eq 1 ]; then
    echo -e "\e[32mRAM - PASSED\e[0m"
    echo ""
    return 0
  fi

  echo -e "\e[31mRAM - FAILED\e[0m"
  echo ""
  return 1
}

check_disk() {
  echo "- Free disk space -"
  install_path="${HOME}"
  expected_value='32'
  df_value=$(df -BG --output=avail "${install_path}" | tail -1 | tr -d 'G')
  df_value=$(awk '{$1=$1};1' <<< "${df_value}")

  echo "expected value: >= ${expected_value}GB"
  echo "set value: ${df_value}GB"  
  if [[ $((df_value)) -ge $((expected_value)) ]]; then
    echo -e "\e[32mDisk - PASSED\e[0m"
    echo ""
    return 0
  fi

  echo -e "\e[31mDisk - FAILED\e[0m"
  echo ""
  return 1
}


main() {
  echo "Checking minimum system requirements"

  final_verdict='PASSED'

  if ! check_os_name; then
    final_verdict='FAILED'
  fi

  if ! check_ubuntu_version; then
    final_verdict='FAILED'
  fi

  if ! check_vcpu_count; then
    final_verdict='FAILED'
  fi
  
  if ! check_avx_support; then
    final_verdict='FAILED'
  fi

  if ! check_ram; then
    final_verdict='FAILED'
  fi

  if ! check_disk; then
    final_verdict='FAILED'
  fi
  
  if [[ ${final_verdict} == 'PASSED' ]]; then
    echo -e "Final verdict: \e[32mPASSED\e[0m"
    exit 0
  else
    echo -e "Final verdict: \e[31mFAILED\e[0m"
    exit 1
  fi
}

main "$@"
