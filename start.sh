#!/bin/bash
while getopts ":ht:d:o:" opt; do
  case $opt in
    h)
      echo "使用方法: $0 [选项]"
      echo "Use: start.sh -t domain.com -d ./dic/subdomain.txt -o ."
      echo "选项:"
      echo "  -h      显示帮助信息"
      echo "  -t      指定域名 (domain)"
      echo "  -d      指定字典 (dic)"
      exit 0
      ;;
    t)
      if [ -n "$OPTARG" ]; then
        domain="$OPTARG"
      else
        echo "错误: -t 选项的参数不能为空。"
        exit 1
      fi
      ;;
    d)
      if [ -n "$OPTARG" ]; then
        dic="$OPTARG"
      else
        echo "错误: -d 选项的参数不能为空。"
        exit 1
      fi
      ;;
    \?)
      echo "无效的选项: -$OPTARG"
      exit 1
      ;;
  esac
done


# 处理其他业务逻辑
if [ -n "$domain" ] && [ -n "$dic" ] ; then
  if [ "$UID" -eq 0 ]; then
    base_pwd=$(pwd)
    sudo_flag=""
else
    sudo -v
    base_pwd=$(sudo pwd)
    sudo_flag="sudo"
fi
  start_time=$(date +%s)
  current_date=$(date +%Y-%m-%d)
  # 显示指定的参数
  echo "指定域名: $domain"
  echo "指定字典: $dic"
  echo "运行位置: $(pwd)"
  echo "输出位置: ./result/$current_date/"
  echo "当前时间: $(date)"
  mkdir ./result/$current_date/
  # 输出进度条
  draw_progress_bar() {
      local progress=$(( 100 * $completed_tasks / $total_tasks ))
      local done=$(( $progress * 4 / 10 ))
      local left=$(( 40 - $done ))

      printf "\r$task_name ["
      printf "%0.s=" $(seq 1 $done)
      printf "%0.s " $(seq 1 $left)
      printf "] %d%%" $progress
  }

  commands=(
    "\"$sudo_flag\" GooFuzz -t \"$domain\" -s -p 100 -d 10 -o \"./result/$current_date/goofuzz_domain_M1.txt\" > /dev/null 2>&1 &"
    "\"$sudo_flag\" GooFuzz -t \"$domain\" -e log,sql,txt,conf,pdf,doc,xls,ppt,odp,ods,docx,xlsx,pptx,bak,mdb,inc -p 100 -d 10 -o \"./result/$current_date/goofuzz_file_M1.txt\" > /dev/null 2>&1 &"
    "\"$sudo_flag\" GooFuzz -t \"$domain\" -w fckeditor,ewebeditor,examples,admin,login,manage,system,console,log -p 100 -d 10 -o \"./result/$current_date/goofuzz_back_M1.txt\" > /dev/null 2>&1 &"
    "\"$sudo_flag\" GooFuzz -t \"$domain\" -c \"登录\",\"后台\",\"日志\",\"配置\",\"备份\",pw,password,username,login -p 100 -d 10 -o \"./result/$current_date/goofuzz_keyword_M1.txt\" > /dev/null 2>&1 &"
    "\"$sudo_flag\" python3 tool/metagoofil/metagoofil.py -d \"$domain\" -f -t log,sql,txt,conf,pdf,doc,xls,ppt,odp,ods,docx,xlsx,pptx,bak,mdb,inc > /dev/null 2>&1 &"
    "\"$sudo_flag\" amass intel -ip -whois -d \"$domain\" -o \"./result/$current_date/amass_M1.txt\" > /dev/null 2>&1 &"
  )

  search_engines=("baidu" "anubis" "bing" "brave" "dnsdumpster" "duckduckgo" "hackertarget" "otx" "rapiddns" "sitedossier" "subdomaincenter" "subdomainfinderc99" "threatminer" "urlscan" "yahoo")
  for engine in "${search_engines[@]}"; do
      output_file="./result/$current_date/theHarvester_${engine}_M1.json"
      commands+=("\"$sudo_flag\" python3 tool/theHarvester/theHarvester.py -d \"$domain\" -l 1000 -f \"$output_file\" -n -b \"$engine\" > /dev/null 2>&1 &")
  done
  completed_tasks=0
  total_tasks=${#commands[@]}
  task_name="基于搜索引擎的信息收集: "
  # 遍历并执行命令
  for command in "${commands[@]}"; do
      eval $command &
      sleep 5
  done
  while true; do
    pid_1=$(pgrep GooFuzz)
    pid_2=$(ps aux | grep 'python3 tool/metagoofil/metagoofil.py' | grep -v grep | awk '{print $2}')
    pid_3=$(pgrep amass)
    pid_4=$(ps aux | grep 'python3 tool/theHarvester/theHarvester.py' | grep -v grep | awk '{print $2}')
    
    for ((i=1; i<=4; i++)); do
      pid="pid_$i"
      if [ -z "${!pid}" ] && [ "$completed_tasks" -eq "$(($i-1))" ]; then
          completed_tasks=$((completed_tasks + 1))
      fi
    done
    draw_progress_bar
    sleep 10
    if [ -z "$pid_1" ] && [ -z "$pid_2" ] && [ -z "$pid_3" ] && [ -z "$pid_4" ]; then
      break
    fi
  done
  commands=(
      "\"$sudo_flag\" amass enum -active -d \"$domain\" -brute -w \"$dic\" -dns-qps 500 -rqps 100 -trqps 100 -nocolor -dir tool/amass/amass4owasp -o \"./result/$current_date/amass_M2.json\" > /dev/null 2>&1 &"
      "\"$sudo_flag\" alterx -l \"$domain\" -pp \"word=$dic\" -enrich | dnsx -a -resp -j \"./result/$current_date/alterx_M2.json\" > /dev/null 2>&1 &"
      "\"$sudo_flag\" fierce --domain \"$domain\" --wide > \"./result/$current_date/fierce_M2.txt\" &"
      "\"$sudo_flag\" python3 tool/OneForAll/oneforall.py --target \"$domain\" --brute True --fmt json --path result/$current_date/ run > /dev/null 2>&1 &"
      "\"$sudo_flag\" ksubdomain e -d \"$domain\" -f \"$dic\" --ns true > \"./result/$current_date/ksubdomain_M2.txt\" &"
  )
  completed_tasks=0
  total_tasks=${#commands[@]}
  echo ""
  task_name="基于字典的域名爆破: "
  # 遍历并执行命令
  for command in "${commands[@]}"; do
      eval $command &
      sleep 30
  done
  while true; do
    pid_1=$(pgrep amass)
    pid_2=$(pgrep alterx)
    pid_3=$(pgrep fierce)
    pid_4=$(ps aux | grep 'python3 tool/OneForAll/oneforall.py' | grep -v grep | awk '{print $2}')
    pid_5=$(pgrep ksubdomain)
    
    for ((i=1; i<=5; i++)); do
      pid="pid_$i"
      if [ -z "${!pid}" ] && [ "$completed_tasks" -eq "$(($i-1))" ]; then
        completed_tasks=$((completed_tasks + 1))
      fi
    done
    draw_progress_bar
    sleep 1
    if [ -z "$pid_1" ] && [ -z "$pid_2" ] && [ -z "$pid_3" ] && [ -z "$pid_4" ]; then
      break
    fi
  done


  end_time=$(date +%s)
  # 计算运行时间
  elapsed_time=$((end_time - start_time))

  # 将运行时间格式化为小时、分钟和秒
  formatted_time=$(date -u -d @$elapsed_time +'%H:%M:%S')

  echo "运行时间：$formatted_time"
else
  echo "缺少必要的参数，请查看帮助信息 (-h)。"
fi

# 如果没有输入参数，则显示帮助信息
if [ "$#" -eq 0 ]; then
  echo "请输入其他参数，或者使用 -h 选项获取帮助信息。"
fi
