#!/bin/bash

# 1. Khai báo mảng
links_crawl=(
    # "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/services/physical-services/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/services/programming/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/services/security-services/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/malware/other-malware/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/security-hosting/hosting/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/security-hosting/proxies/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/bitcoin-ethereum-wallets/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/ak/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/mossberg/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/shotguns-2/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/drugs/alcohol/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/drugs/barbiturates/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/drugs/opioids/heroin/"
    "http://x6l5uf2uxogl3uek2w56peu7gvs75b3dbjpp3bb7myhboqqud2kx45qd.onion/product-category/drugs/opioids/oxycodone/"

)

# Tạo thư mục lưu trữ (đảm bảo đúng tên raw_1 như lệnh mv bên dưới)
mkdir -p raw_1/html raw_1/json

i=1
total=${#links_crawl[@]}

for link in "${links_crawl[@]}"
do
    # Xử lý làm sạch link để tránh ký tự rác
    current_link=$(echo "$link" | xargs)
    
    echo "[+] ($i/$total) Crawling: $current_link"

    # Dọn dẹp kết quả cũ
    rm -f src/*.html src/*.json

    # Chạy TorBot
    # Lưu ý: Luôn để "$current_link" trong ngoặc kép
    python3 main.py -u "$current_link" --depth 1 --save json --html save

    # Trích xuất tên danh mục
    category=$(echo "$current_link" | sed 's|/$||' | awk -F'/' '{print $NF}')
    [ -z "$category" ] && category="page_${i}"

    # Di chuyển file (Sửa đường dẫn // thành /)
    html_file=$(find src/ -maxdepth 1 -name "*.html" | head -n 1)

    if [ -n "$html_file" ]; then
        mv "$html_file" "raw_1/html/${category}.html"
        echo "[*] Saved ${category}.html"
    else
        echo "[-] No HTML file found for $category"
    fi

    json_file=$(find src/ -maxdepth 1 -name "*.json" | head -n 1)

    if [ -n "$json_file" ]; then
        mv "$json_file" "raw_1/json/${category}.json"
    else
        echo "[-] No JSON file found for $category"
    fi


    # Nghỉ ngẫu nhiên
    wait_time=$(( ( RANDOM % 41 ) + 30 ))
    echo "[!] Sleeping for $wait_time seconds..."
    sleep $wait_time
    
    ((i++))
done

echo "[+] DONE - Dữ liệu đã ở trong raw_1/"