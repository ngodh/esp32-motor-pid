# WORKFLOW — Cách làm việc hằng ngày với Agent và PM

> File này **dành cho người học**, không cần dán cho Agent.
> Vị trí chuẩn trong repo: `docs/WORKFLOW.md`. Cập nhật: 2026-11-23.

**Ba vai trò:** NGƯỜI HỌC (bạn) làm và chuyển tin · AGENT (chat khác) dạy từng phiên · PM (Claude chat này) lập kế hoạch và xử lý lỗi Agent không giải được.
**Kênh giao tiếp:** file `docs/PROGRESS.md`. Agent chỉ đọc cái bạn dán, nên bạn là người duy nhất ghi vào file.

---

## 1. Thiết lập một lần (sau khi cài xclip)

| # | Việc | Lệnh | Đạt khi |
|---|---|---|---|
| 1 | Cài xclip | `sudo apt install -y -o DPkg::Lock::Timeout=600 xclip` | `which xclip` in ra đường dẫn |
| 2 | Commit script | `cd ~/dwcstinhs/projects/esp32-motor-pid && git add scripts/packet.sh && git commit -m "Add session packet helper" && git push` | `git status -sb` chỉ có `## main...origin/main` |
| 3 | Thử tạo gói | `scripts/packet.sh M1 \| xclip -selection clipboard`, dán thử vào Notepad bên Windows | Dòng đầu: `# GÓI VÀO PHIÊN ... milestone M1`, khoảng 200 dòng |
| 4 | Đặt mua INA219 | Loại 2.7–5.5 V, đo 0–26 V, 0–3.2 A, I2C (đã kiểm tra đúng) | Cần về trước phiên S09 |

Nếu `apt` báo khóa (`unattended-upgr`): đó là Ubuntu tự cập nhật, cứ đợi, không `kill`, không xóa file lock. Kiểm tra: `ps -p <pid> -o etime,cmd`.
Nếu xclip không dán được sang Windows: `scripts/packet.sh M1 > /tmp/packet.md`, mở file, Ctrl+A, Ctrl+C.

---

## 2. Chuẩn bị trước mỗi phiên

- Mở Ubuntu VM, cắm ESP32 (`ls /dev/ttyUSB*` thấy cổng).
- Chuẩn bị đúng vật dụng ghi trong milestone hiện tại (§5 của PROGRESS).
- Kích hoạt ESP-IDF: `source ~/.espressif/tools/activate_idf_v6.1.1.sh`, `cd ~/dwcstinhs/projects/esp32-motor-pid`, `git pull`.

---

## 3. Mở chat với Agent

### A. Chat mới (đầu **mỗi milestone**)

1. Tạo gói: `scripts/packet.sh M1 | xclip -selection clipboard` (đổi `M1` thành milestone hiện tại).
2. Mở chat mới, dán gói, rồi dán câu mồi:

> Bạn là AGENT dạy học cho dự án esp32-motor-pid. Trên là gói trích từ PROGRESS.md. Tuân thủ §1, chạy phiên S0x (M?) theo §5: bắt đầu bằng Recall 2 câu, rồi dạy và hướng dẫn mình làm từng bước. Cuối phiên, in "gói cập nhật" đủ 5 phần theo §1.6.

### B. Các phiên tiếp theo trong cùng chat (không dán lại gói)

> Bắt đầu phiên S0x. Recall 2 câu về phiên trước, rồi tiếp tục theo §5.

---

## 4. Trong phiên (~2 giờ)

Nhịp: **Recall 5′ → Concept ≤ 25′ → Hands-on 60–75′ → Teach-back 10′ → Ghi nhật ký và commit 10′.**

- Tự tay gõ code. Trả lời teach-back bằng lời của mình.
- Gặp lỗi, báo Agent theo mẫu:

> Mình gặp lỗi: <triệu chứng>. Lệnh: <...>. Log (≤ 40 dòng): <...>. Đã thử: <...>.

- Chụp ảnh và lưu số liệu ngay khi có (bằng chứng portfolio).
- Cổng dừng phần cứng G1–G6 (§1.4 của PROGRESS): Agent phải nhắc, nhưng bạn cũng tự kiểm tra trước khi cấp điện.

---

## 5. Cuối phiên

1. Nhắn Agent:

> Kết thúc phiên. In gói cập nhật đủ 5 phần theo §1.6.

2. Dán vào `docs/PROGRESS.md`:

| # | Cập nhật | Ở đâu |
|---|---|---|
| 1 | Khối STATE mới | §0 |
| 2 | Mục nhật ký phiên (≤ 5 dòng) | §6 |
| 3 | Lỗi mới hoặc đổi trạng thái | §7 |
| 4 | Tick `[x]` milestone và bằng chứng | §5, §10 |
| 5 | Ack tin của PM | §8 |

3. Lưu ảnh/số liệu vào `docs/img/` hoặc `docs/data/`.
4. Commit: `git add -A && git commit -m "S0x: <nội dung ngắn>" && git push`.

---

## 6. Khi nào gửi cho PM (Claude chat này)

| Tình huống | Gửi gì |
|---|---|
| Xong **M3** (điểm đồng bộ P1), **M4** (P2), **M6** (P3) | `PROGRESS.md` đầy đủ + 1 dòng nhận xét |
| Agent đánh dấu **ESCALATE**: kẹt > 45 phút, nghi hỏng phần cứng, cần đổi kế hoạch, teach-back 2 lần không đạt, trễ > 2 phiên | `PROGRESS.md` (hoặc §0, §7, §8) + gói escalate |

Yêu cầu Agent viết gói escalate:

> Tạo gói ESCALATE cho PM theo §1.5.

PM trả lời bằng **khối ngắn**: một phần dán vào §8 (tin cho Agent), một phần vào §9 (quyết định). PM không viết lại cả file.

---

## 7. Chuyển milestone

1. Kiểm tra mọi `[x]` và bằng chứng đã đủ ở §5 và §10.
2. **Mở chat mới** với Agent.
3. Tạo gói bằng `scripts/packet.sh M<mới>` rồi dán như mục 3A.

Khi §7 có nhiều dòng RESOLVED cũ, xóa bớt khỏi gói trước khi dán để tiết kiệm token.

---

## 8. Các điều CHƯA XÁC NHẬN (xử lý khi đến đúng lúc)

| Cần xác nhận | Khi nào cần |
|---|---|
| Số `pswpout`/`pswpin` (ghi vào nhật ký M0) | Ngay |
| INA219 đã đặt chưa | Trước S09 |
| USB filter của logic analyzer trong Ubuntu VM | M1 (tùy chọn), M3 (cần) |
| Màu dây motor JGA25-370; TB6612 có hàn sẵn chân chưa | M2 (chụp ảnh gửi Agent) |
| Đường dẫn kích hoạt venv `embedded-env` | M4 |
| Đường dẫn mount `ISE_Projects` trong ISE VM, model bo Spartan-3E, `picotool` | Dự án A |

---

## 9. Những điều không làm

1. Không dán cả `PROGRESS.md` mỗi phiên (dùng `packet.sh`).
2. Không để Agent tự đổi kế hoạch, linh kiện, gán chân GPIO: phải qua PM.
3. Không bỏ qua teach-back và cổng dừng phần cứng.
4. Không ghi khóa SSH, mật khẩu, email vào `PROGRESS.md` (repo có thể công khai).
5. Không restore snapshot VM khi còn code chưa push.
