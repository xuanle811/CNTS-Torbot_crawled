#!/bin/bash

# --- CẤU HÌNH ---
OUTPUT_FOLDER="outputlink"
DEST_DIR="raw_depth_2"
TEMP_DIR="src" 

# Tạo thư mục lưu trữ nếu chưa có
mkdir -p "$DEST_DIR/html" "$DEST_DIR/raw"

# 1. Hiển thị danh sách các file part
echo "[?] Các file danh sách link hiện có trong $OUTPUT_FOLDER:"
ls "$OUTPUT_FOLDER"/*.txt 2>/dev/null
echo "------------------------------------------"

# 2. Nhập tên file
read -p "[>] Nhập tên file bạn muốn crawl (vd: product_links_part1.txt): " selected_file

if [[ -z "$selected_file" ]]; then
    files_to_run=("$OUTPUT_FOLDER"/*.txt)
else
    files_to_run=("$OUTPUT_FOLDER/$selected_file")
fi

if [[ ! -f "${files_to_run[0]}" ]]; then
    echo "[-] Lỗi: Không tìm thấy file danh sách link."
    exit 1
fi

# --- BẮT ĐẦU VÒNG LẶP ---
for input_file in "${files_to_run[@]}"; do
    echo "[+] Đang xử lý file: $input_file"
    total_links=$(wc -l < "$input_file")
    current=1

    while IFS= read -r raw_link || [[ -n "$raw_link" ]]; do
        # Làm sạch link (xóa ký tự rác từ Windows)
        link=$(echo "$raw_link" | tr -d '\r' | xargs)
        [[ -z "$link" ]] && continue

        echo "[*] ($current/$total_links) Đang xử lý: $link"

        # 1. Trích xuất tên sản phẩm và thêm số thứ tự current
        raw_name=$(echo "$link" | sed 's|/$||' | awk -F'/' '{print $NF}')
        [ -z "$raw_name" ] && raw_name="item"
        
        # Thêm số thứ tự vào đầu (Ví dụ: 1_arsenal-ak47)
        product_name="${current}_${raw_name}"

        # Xóa src cũ để kiểm tra file mới chính xác
        rm -f "$TEMP_DIR"/*.html "$TEMP_DIR"/*.json

        # CHẠY TORBOT
        python3 main.py -u "$link" --depth 1 --save json --html save
        
        # Kiểm tra nếu lệnh trên bị crash hoặc lỗi nặng
        if [ $? -ne 0 ]; then
            echo "[!] LỖI: TorBot gặp sự cố khi crawl link này. Bỏ qua..."
            ((current++))
            continue
        fi

        # Kiểm tra xem có file nào được tải về không
        html_found=$(find "$TEMP_DIR" -maxdepth 1 -name "*.html" | head -n 1)

        if [ -n "$html_found" ]; then
            mv "$TEMP_DIR"/*.html "$DEST_DIR/html/${product_name}.html" 2>/dev/null
            mv "$TEMP_DIR"/*.json "$DEST_DIR/raw/${product_name}.json" 2>/dev/null
            echo "[V] Thành công: ${product_name}.html"
        else
            echo "[-] THẤT BẠI: Không lấy được nội dung (có thể do lỗi mạng Tor). Tiếp tục link sau..."
            # Không cần exit, vòng lặp sẽ tự chạy tiếp link tiếp theo
        fi

        # NGHỈ NGẪU NHIÊN (Chống chặn)
        wait_time=$(( ( RANDOM % 51 ) + 40 )) # 40s đến 70s
        if [ $current -lt $total_links ]; then
            echo "[!] Đang nghỉ $wait_time giây để giữ an toàn..."
            sleep $wait_time
        fi

        ((current++))
    done < "$input_file"
    
    echo "[OK] Đã hoàn thành file: $input_file"
    echo "------------------------------------------"
done

echo "[+] TẤT CẢ ĐÃ HOÀN TẤT!"