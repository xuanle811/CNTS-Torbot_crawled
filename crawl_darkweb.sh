BASE="http://gc3ygt7m2xtjicadvsyxopwo6aamvt2qnapnuym3pdjmj2s4t2qdm3ad.onion/products"

for i in {1..5}
do
  echo "[+] Crawling page $i"

  rm -f src/*.html src/*.json

  python main.py -u "$BASE?page=$i" --depth 1 --save json --html save

  mv src/*.html "raw/html/page_${i}.html" 2>/dev/null
  mv src/*.json "raw/json/page_${i}.json" 2>/dev/null

  sleep 10
done

echo "[+] DONE"