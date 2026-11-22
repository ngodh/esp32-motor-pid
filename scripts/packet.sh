#!/usr/bin/env bash
# Tạo "gói vào phiên" từ docs/PROGRESS.md để dán cho Agent (chế độ D).
# Dùng: scripts/packet.sh M1        (M0 đến M6)
#       scripts/packet.sh M1 | xclip -selection clipboard
set -euo pipefail
F="$(cd "$(dirname "$0")/.." && pwd)/docs/PROGRESS.md"
M="${1:?Dùng: scripts/packet.sh M1}"

# In nguyên một mục "## N. ..." (bỏ dòng ---)
sec() { awk -v n="$1" '
  /^## [0-9]+\. / { p = ($0 ~ "^## " n "\\. ") }
  p && $0 != "---" { print }' "$F"; }

# In milestone được chọn
ms() { awk -v m="$1" '
  $0 ~ "^### " m " " { p = 1; print; next }
  /^### / || /^## / { p = 0 }
  p && $0 != "---" { print }' "$F"; }

# Mục 6: phần đầu (lịch sử + mẫu) và 3 mục nhật ký phiên cuối
log() { awk '
  /^## / { insec = ($0 ~ /^## 6\. /) }
  !insec { next }
  /^```/ { fence = !fence }
  !fence && /^### S/ { n++ }
  $0 == "---" { next }
  { line[++t] = $0; ent[t] = n }
  END { first = n - 2; if (first < 1) first = 1
        for (i = 1; i <= t; i++) if (ent[i] == 0 || ent[i] >= first) print line[i] }' "$F"; }

echo "# GÓI VÀO PHIÊN (trích từ docs/PROGRESS.md, milestone $M)"
echo
for n in 0 1 3 4; do sec "$n"; echo; done
echo "## 5. LỘ TRÌNH (chỉ milestone hiện tại)"; echo
ms "$M"; echo
log; echo
sec 7; echo
sec 8
