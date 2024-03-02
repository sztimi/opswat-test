#!/bin/bash

set -e -u -o pipefail

compare() {
  given_value="$1"
  relation="$2"
  expected_value="$3"
  component_name="$4"

  echo "- ${component_name} -"

  comparison_cmd=''

  case $relation in
    '==')
      comparison_cmd="[ '${given_value}' == '${expected_value}' ]"
      echo "expected value: ${expected_value}"
      ;;
    '-le')
      comparison_cmd="[ $((given_value)) -le $((expected_value)) ]"
      echo "expected value: <= ${expected_value}"
      ;;
    '-ge')
      comparison_cmd="[ $((given_value)) -ge $((expected_value)) ]"
      echo "expected value: >= ${expected_value}"
      ;;
    '-eq')
      comparison_cmd="[ $((given_value)) -eq $((expected_value)) ]"
      echo "expected value: ${expected_value}"
      ;;
    *)
      echo "ERROR: Unknown relation '${relation}'"
      exit 1
      ;;
  esac

  echo "given value: ${given_value}"

  if eval "${comparison_cmd}"; then
    echo -e "\e[32mPASSED\e[0m"
    echo ""
    return 0
  fi

  echo -e "\e[31mFAILED\e[0m"
  echo ""
  return 1
}

compare_bool() {
  given_value="$1"
  expected_value="$2"
  comparison_result="$3"
  component_name="$4"

  echo "- ${component_name} -"
  echo "expected value: ${expected_value}"
  echo "given value: ${given_value}"

  if [ $((comparison_result)) -eq 1 ]; then
    echo -e "\e[32mPASSED\e[0m"
    echo ""
    return 0
  fi

  echo -e "\e[31mFAILED\e[0m"
  echo ""
  return 1
}

check_os_name() {
  expected_value='Ubuntu'
  os_name=$(grep '^NAME=' /etc/os-release | cut -f2 -d'=' | tr -d '"')

  compare "${os_name}" '==' "${expected_value}" 'OS'

  return "$?"
}

check_ubuntu_version() {
  maximum_version='20'
  major_version=$(grep VERSION_ID /etc/os-release | cut -f2 -d'=' | tr -d '"' | cut -f1 -d'.')

  compare "${major_version}" '-le' "${maximum_version}" 'Major version'

  return "$?"
}

check_vcpu_count() {
  expected_value='8'
  cpu_count=$(grep -c '^processor' /proc/cpuinfo)

  compare "${cpu_count}" '-ge' "${expected_value}" 'Number of vCPUs'

  return "$?"
}

check_avx_support() {
  expected_value='true'
  avx_support=$(lscpu | grep '^Flags:' | grep avx > /dev/null && echo 'true' || echo 'false')

  compare "${avx_support}" '==' "${expected_value}" 'AVX support'

  return "$?"
}

check_ram() {
  expected_value='16'
  ram_value=$(free -m | awk '/Mem:/ {printf "%.2f\n", $2/1024}' | tr ',' '.')

  comparison_result=$(echo "${ram_value} > ${expected_value}" | bc)

  compare_bool "${ram_value}" "${expected_value}" "${comparison_result}" 'RAM'

  return "$?"
}

check_disk() {
  install_path="${HOME}"
  expected_value='32'
  df_value=$(df -BG --output=avail "${install_path}" | tail -1 | tr -d 'G')
  df_value=$(awk '{$1=$1};1' <<< "${df_value}")

  compare "${df_value}" '-ge' "${expected_value}" 'Free disk space'

  return "$?"
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
