# PROGRESS — Dự án B: esp32-motor-pid

> **Đây là kênh giao tiếp giữa PM (Claude chat) và AGENT (người dạy hằng ngày), phục vụ NGƯỜI HỌC.**
> Vị trí chuẩn trong repo: `~/dwcstinhs/projects/esp32-motor-pid/docs/PROGRESS.md`
> Ngôn ngữ làm việc: **tiếng Việt**, giữ thuật ngữ kỹ thuật bằng tiếng Anh.

---

## 0. ĐỌC TRƯỚC (Agent đọc mục này đầu tiên)

**STATE** (Agent cập nhật các trường "hiện tại" cuối mỗi phiên):

| Trường | Giá trị |
|---|---|
| Milestone hiện tại | **M0** (hoàn tất phần còn lại) → **M1**. **Người học chưa bắt đầu bài thực hành nào của dự án B** (mới xong dựng môi trường và đặt hàng) |
| Phiên kế tiếp | **S00** rồi **S01** (xem §5) |
| Phần cứng | Đã về: motor JGA25-370 có encoder, TB6612FNG, breakout micro-USB ×2, logic analyzer 24M 8CH, header đực 1×40. **Chưa đặt: INA219** (đợt mua 2, cần về trước S09; xem PM-001) |
| Lỗi đang mở | 0 (xem §7) |
| Tin PM chưa được Agent xác nhận (ack) | PM-001, PM-003, PM-004 (xem §8) |
| Điểm đồng bộ PM kế tiếp | **P1: sau khi xong M3** |
| Chế độ Agent | **D** (Agent chỉ chat, chỉ đọc nội dung người học dán; đã xác nhận 2026-11-21). Xem §1.6 |
| Cập nhật lần cuối | 2026-11-21 bởi PM |

**Thứ tự đọc mỗi phiên (không đọc toàn bộ file):** §0 → §8 Inbox → §7 lỗi đang mở → milestone hiện tại ở §5 → 3 mục cuối của §6. Chỉ đọc §2–§4 ở phiên đầu hoặc khi cần tra đường dẫn/phần cứng.

---

## 1. QUY TẮC LÀM VIỆC

### 1.1 Vai trò và quyền hạn

| Vai trò | Làm | Được ghi vào | Không được |
|---|---|---|---|
| **NGƯỜI HỌC** | Thực hành, trả lời teach-back, chuyển file giữa Agent và PM | (qua Agent) | |
| **AGENT** | Dạy và hướng dẫn từng phiên theo §5; ghi nhật ký; ghi lỗi; tick checkbox | §0 (trường "hiện tại"), §5 (chỉ tick `[x]` và thêm ghi chú ngắn), §6, §7, §10 | Đổi kế hoạch, tiêu chí nghiệm thu, danh sách linh kiện, gán chân GPIO, kiến trúc môi trường (muốn đổi → Change Request §9) |
| **PM (Claude chat)** | Lập kế hoạch, đặt mốc và tiêu chí, xử lý lỗi Agent không giải được, rà soát tiến độ | §0 (các trường khác), §2–§5, §8, §9 | Dạy trực tiếp nội dung từng buổi |

### 1.2 Hợp đồng dạy: học nền tảng VÀ thực hành trong cùng một phiên

Mỗi phiên (~2 giờ) theo đúng 5 bước:

1. **Recall (5 phút):** hỏi 2–3 câu về phiên trước.
2. **Concept (≤ 25 phút):** đi theo thứ tự **vấn đề thực tế trước → vì sao cần → cách hoạt động**, có ví dụ đời thường. Giả định người học biết rất ít; dùng đúng thuật ngữ rồi giải thích ngay.
3. **Hands-on (60–75 phút):** người học **tự gõ**. Agent gợi ý trước; chỉ đưa lời giải đầy đủ sau 2 lần thử không thành. Phần boilerplate (CMakeLists, khung file) được đưa thẳng.
4. **Teach-back (10 phút):** người học tự giải thích bằng lời các câu hỏi ở §5. Chưa đạt thì dạy lại bằng ví dụ khác; sau 2 lần vẫn chưa đạt → ghi vào §7 để PM xử lý. **Không chuyển bước khi teach-back chưa đạt.**
5. **Ghi nhật ký và commit (10 phút):** cập nhật §6, tick §5, lưu bằng chứng (§10), `git commit`.

Tỷ lệ tham chiếu: **~30% lý thuyết / ~70% thực hành**, nhưng lý thuyết luôn đứng ngay trước phần thực hành dùng nó và được kiểm tra ngay sau đó. **Không được:** cả phiên chỉ giảng, hoặc cả phiên chỉ chép lệnh.

### 1.3 Tiết kiệm token (người học đặc biệt quan tâm)

- Trả lời ngắn; mỗi lượt chỉ một bước (một lệnh hoặc một đoạn code nhỏ) và tối đa **một câu hỏi**.
- Không lặp lại lý thuyết đã ghi ở §6; tham chiếu "đã học ở S0x".
- Mỗi mục nhật ký §6 **tối đa 5 dòng**. Khi §6 vượt 12 mục, nén các mục cũ thành 1 đoạn tóm tắt.
- Không tạo file HTML. Tài liệu dạng văn bản/markdown.

### 1.4 Cổng dừng phần cứng (STOP GATES, không được bỏ qua)

| Mã | Trước khi… | Phải xác nhận |
|---|---|---|
| **G1** | cấp 5 V từ adapter lên breadboard | Đo DMM giữa VBUS và GND của breakout micro-USB ≈ 5 V, đúng cực |
| **G2** | cấp điện cho bất kỳ dây motor chính | Đã xác định đúng **cặp dây motor** bằng điện trở (vài Ω), không nhầm với 4 dây encoder |
| **G3** | nối encoder | Cấp encoder bằng **3.3 V** (không 5 V); đã đo điện áp |
| **G4** | luôn luôn | Không nối motor thẳng GPIO; không giữ chặt (stall) trục motor quá 2 giây; **không nối hai nguồn 5 V với nhau, chỉ nối chung GND** |
| **G5** | luôn luôn | Không rút USB hay tắt VM khi đang flash |
| **G6** | nối INA219 (M5) | INA219 mắc **nối tiếp** trên đường +5 V của motor (VIN+ phía nguồn, VIN− phía TB6612), chung GND, kiểm tra cực |

### 1.5 Khi nào ESCALATE cho PM

Ghi vào §7 với trạng thái **ESCALATE** nếu: (a) kẹt > 45 phút hoặc 2 hướng sửa đều thất bại; (b) nghi hỏng phần cứng; (c) cần đổi kế hoạch, thiết kế hoặc linh kiện; (d) người học 2 lần không đạt teach-back; (e) tiến độ trễ > 2 phiên so với §5.

**Gói escalate (viết sẵn trong §7):** triệu chứng; lệnh và log nguyên văn (≤ 40 dòng); đã thử gì; giả thuyết; ảnh hưởng đến lịch. Người học gửi cho PM **file này** (hoặc chỉ §0, §7, §8) kèm một dòng mô tả. PM trả lời bằng **khối ngắn** để dán vào §8 và §9 (PM không viết lại cả file).

### 1.6 Chế độ vận hành: CHẾ ĐỘ D (đã xác nhận)

Agent **không truy cập đĩa**, chỉ đọc nội dung người học dán vào chat. Để tiết kiệm token:

- **Gói vào phiên** (người học dán khi mở chat mới): §0, §1, §3, §4, **milestone hiện tại** ở §5, 3 mục cuối §6, các mục §7 đang OPEN/ESCALATE, các tin §8 chưa ack. **Không dán** §2, các milestone khác, §9, §10 (trừ khi Agent yêu cầu).
- Trong **cùng một cuộc chat**, không dán lại. Khuyến nghị **một chat cho mỗi milestone**.
- **Gói cập nhật** (Agent in cuối mỗi phiên, người học dán vào file `PROGRESS.md` trong repo rồi commit): (1) khối STATE mới ở §0; (2) mục mới cho §6 (≤ 5 dòng); (3) mục mới hoặc thay đổi trạng thái ở §7; (4) các checkbox cần tick ở §5 và §10; (5) tin ack ở §8. **Chỉ in phần thay đổi, không in lại cả file.**
- Người học là người duy nhất ghi vào file; Agent phải kiểm tra gói cập nhật đủ 5 phần trước khi kết thúc phiên.

### 1.7 Phiên bản phần mềm

**ESP-IDF v6.1.1** là bản rất mới, nhiều tài liệu và ví dụ trên mạng viết cho v4/v5 có thể dùng API đã bị bỏ. **Không giả định API v4/v5**; tra tài liệu v6.1 trên docs.espressif.com. Nếu build lỗi do API, ghi §7 kèm log.

### 1.8 Bảo mật

Repo có thể công khai: **không ghi** khóa SSH, mật khẩu, email, thông tin cá nhân vào file này.

---

## 2. BỐI CẢNH

**Người học:** sinh viên Kỹ thuật Điện năm nhất tại Việt Nam, học các tài liệu cấp cao hơn trình độ hiện tại nên chỉ hiểu khoảng 40% thuật ngữ khi giải thích nhanh. Học tốt nhất khi: bắt đầu từ vấn đề thực, hiểu **vì sao** trước **cách làm**, đi từng bước, tự tay làm. Nền tảng: C/C++ cơ bản, FPGA/Verilog cơ bản, đã làm lab embedded Linux. **Chưa học:** RTOS, PID, I2C ở mức driver.

**Mục tiêu lớn:** xây portfolio cho kỳ thực tập **Summer 2027** (công ty embedded system / hardware design). Hai dự án trong khoảng 2 tháng:
- **Dự án B (file này, làm trước, ~3 tuần):** ESP32 điều khiển tốc độ motor DC vòng kín.
- **Dự án A (làm sau):** bộ đồng xử lý servo trên FPGA Spartan-3E, điều khiển bởi Pico qua SPI. Sẽ có file `PROGRESS` riêng khi bắt đầu.

**Dự án B trong một đoạn:** ESP32 giữ tốc độ motor ở giá trị đặt (**100 và 150 RPM**) dù tải thay đổi. Đo tốc độ bằng encoder (PCNT), điều khiển bằng PID chạy trong task FreeRTOS chu kỳ 10 ms, đo dòng motor bằng INA219 với **driver I2C tự viết**, log CSV qua UART và vẽ đồ thị step response bằng Python. Sản phẩm cuối: README, sơ đồ nối dây, đồ thị, video demo, mục "Problems & Lessons".

**Nhà tuyển dụng tìm:** sản phẩm chạy thật, debug có hệ thống, hiểu mức thấp, **số liệu đo**, tài liệu hóa, quy trình (git). Vì vậy mỗi phiên phải sinh bằng chứng (§10).

**Tài liệu liên quan:** `docs/ROADMAP.md` (lộ trình dài, có từ điển thuật ngữ ở mục B.4). Agent có thể tra khi cần, không bắt buộc đọc hết.

---

## 3. MÔI TRƯỜNG VÀ ĐƯỜNG DẪN

**Dự án B chỉ làm trong Ubuntu VM.** Không dùng Windows host hay ISE VM cho dự án này.

| Mục | Giá trị |
|---|---|
| Ubuntu VM | VirtualBox, Ubuntu 22.04.5, 4 CPU, RAM 5288 MB, ổ 59 GB, user `dwcstinhs` |
| Repo B | `~/dwcstinhs/projects/esp32-motor-pid` (nhánh `main`, remote `git@github.com:ngodh/esp32-motor-pid.git`, đồng bộ qua SSH) |
| Kích hoạt ESP-IDF | `source ~/.espressif/tools/activate_idf_v6.1.1.sh` (IDF_PATH `~/.espressif/v6.1.1/esp-idf`) |
| Build / nạp / log | `idf.py set-target esp32` (một lần) → `idf.py build` → `idf.py -p /dev/ttyUSB0 flash monitor` (thoát monitor: Ctrl+]) |
| Python (vẽ đồ thị) | venv `embedded-env` (matplotlib, pandas, pyserial). **Dùng terminal khác, không kích hoạt ESP-IDF cùng lúc** (đường dẫn kích hoạt: CHƯA XÁC NHẬN) |
| ESP32 | Chip Silicon Labs CP210x (USB `10c4:ea60`), cổng thường `/dev/ttyUSB0` (số chính xác: CHƯA XÁC NHẬN), user thuộc nhóm `dialout`, USB filter gắn vào Ubuntu VM |
| Logic analyzer | USB 24M 8CH + PulseView (có sẵn trong Ubuntu); USB filter cho thiết bị này: CHƯA XÁC NHẬN đã tạo |
| Serial thay thế | `picocom` đã cài |
| File lớn (video, log thô) | `D:\Ubuntu2204_shared_folder` (thư mục chia sẻ, chỉ để chuyển file; không đặt source ở đó) |
| Snapshot VM | "Ubuntu sạch", "Tools OK" (**không restore khi còn code chưa push**) |

**Cấu trúc repo (hiện tại và dự kiến):**

```
~/dwcstinhs/projects/esp32-motor-pid/
├── CMakeLists.txt          # project: esp32-motor-pid   (CHƯA CÓ, tạo ở M1)
├── main/
│   ├── CMakeLists.txt      # (CHƯA CÓ, tạo ở M1)
│   └── main.c              # (CHƯA CÓ; bài LEDC PWM ra LED chưa làm)
├── scripts/                # Python: log_serial.py, plot.py   (chưa có)
├── docs/
│   ├── ROADMAP.md          # lộ trình dài (thay bằng bản cập nhật 20/11/2026)
│   ├── PROGRESS.md         # FILE NÀY
│   ├── img/                # ảnh, đồ thị                       (chưa tạo)
│   └── data/               # CSV mẫu, bảng số liệu              (chưa tạo)
├── README.md               # đã có (README GitHub)
└── .gitignore              # hiện có: build/, sdkconfig.old, __pycache__/
                            # nên thêm: sdkconfig, managed_components/, .vscode/
```

**Không commit:** `build/`, `sdkconfig`, `managed_components/`, venv, log thô lớn.

**Môi trường khác (chỉ để Agent hiểu bối cảnh):** repo `fpga-servo-coprocessor` (dự án A) có hai clone (Windows `C:\ISE\ISE_Projects\...` và Ubuntu `~/dwcstinhs/projects/fpga-servo-coprocessor`); ISE 14.7 chạy trong một VM riêng (Oracle Linux). Không liên quan đến dự án B.

---

## 4. PHẦN CỨNG

**Đã về:** motor JGA25-370 6 V có encoder, TB6612FNG, breakout micro-USB cái ×2, logic analyzer, header đực 1×40.
**Trong kit SunFounder ESP32:** ESP32 dev board, breadboard, dây (đực-đực, đực-cái, cái-cái), điện trở, tụ gốm 100 nF, LED, potentiometer, L293D (dự phòng), motor DC 3 V (thử nghiệm), I2C LCD1602 (PCF8574, địa chỉ thường 0x27 hoặc 0x3F).
**Nguồn:** adapter Vilros 5 V 2.5 A, đầu ra micro-USB, đưa lên breadboard qua breakout micro-USB (chỉ dùng chân VBUS và GND, **cần hàn chân header vào breakout**). ESP32 cấp điện riêng từ USB của máy tính.
**Có DMM, đồ hàn.** **Chưa có: INA219** (cần cho M5; xem Inbox PM-001).

**Motor chính JGA25-370:** 6 V, tỉ số 1/21.3 (≈280 RPM danh định), trục 4 mm, 6 dây (2 dây dày là motor; 4 dây mỏng là encoder: VCC, GND, A, B; màu dây: CHƯA XÁC NHẬN, phải xác định bằng điện trở, **gate G2**). Encoder 11 xung/vòng trục motor, 2 kênh, cấp 3.3–5 V (dùng **3.3 V**, **gate G3**).
**Hằng số:** `COUNTS_PER_REV = 11 × 4 × 21.3 ≈ 937.2` count/vòng trục ra (đọc quadrature ×4; **phải hiệu chuẩn bằng quay tay 1 vòng**). Trên nguồn 5 V qua TB6612, tốc độ tối đa dự kiến ≈ 200 RPM (ước tính, cần đo), nên đặt setpoint 100 và 150 RPM để còn dư địa điều khiển.

**Sơ đồ nối dây dự kiến (GPIO là gợi ý, xác nhận với board):**

| Tín hiệu | Nối tới |
|---|---|
| TB6612 VM | +5 V (VBUS của breakout micro-USB) |
| TB6612 VCC | ESP32 3V3 |
| TB6612 GND | GND chung |
| TB6612 STBY | 3V3 (hoặc GPIO 14) |
| TB6612 PWMA | GPIO 25 (LEDC, 20 kHz) |
| TB6612 AIN1 / AIN2 | GPIO 26 / GPIO 27 |
| TB6612 AO1 / AO2 | hai dây motor (sau khi qua G2) |
| Encoder VCC / GND | 3V3 / GND |
| Encoder A / B | GPIO 32 / GPIO 33 |
| INA219 SDA / SCL | GPIO 21 / GPIO 22 (VCC 3V3, mắc nối tiếp trên +5 V motor) |
| Tụ gốm 100 nF | song song hai cực motor (giảm nhiễu) |

Tránh GPIO 0, 2, 12, 15 (strapping), 6–11 (flash), 34–39 chỉ là input.

---

## 5. LỘ TRÌNH

Giả định ~4 phiên/tuần, mỗi phiên ~2 giờ; dự án B ≈ 3 tuần (S00–S11). **Điểm đồng bộ PM:** P1 sau M3, P2 sau M4, P3 sau M6 (người học gửi file cho PM). Ngoài ra chỉ gửi khi có ESCALATE.

### M0 — Xác nhận môi trường (S00, ~30 phút) `[ ]`
- **Dạy:** vòng build → flash → monitor; cấu trúc project ESP-IDF; quy trình git (add, commit, push).
- **Làm:** `idf.py --version`; đối chiếu cấu trúc repo với §3 (repo chưa có project ESP-IDF: `CMakeLists.txt` và `main/main.c` tạo ở M1); chạy `idf.py fullclean && idf.py build` trên **project blink đã dùng trước đó** (không phải repo B) trong lúc theo dõi `free -h` để kiểm tra RAM VM 5288 MB (swap dùng < 500 MB); bổ sung `.gitignore` (`sdkconfig`, `managed_components/`, `.vscode/`); copy bản cập nhật `ROADMAP.md` và `PROGRESS.md` vào `docs/`; commit và push.
- **Nghiệm thu:** `git status` sạch; GitHub thấy hai file trong `docs/`; build sạch trên project blink thành công với swap < 500 MB.
- **Teach-back:** (1) 3 bước của vòng phát triển ESP-IDF? (2) Vì sao `build/` không đưa vào git?
- **Ghi chú:** blink đã chạy trên ESP32 (xong).

### M1 — PWM và LEDC (S01, ~2 giờ) `[ ]`
- **Vấn đề mở đầu:** chip chỉ xuất 0 V hoặc 3.3 V; làm sao để LED hoặc motor "chạy một nửa"?
- **Dạy:** GPIO số; duty cycle, tần số, điện áp trung bình; vì sao 5 Hz thấy nhấp nháy còn 20 kHz thì không; LEDC (timer, channel, độ phân giải duty).
- **Làm:** LED + 220 Ω ở GPIO 25 (tạm) fade sáng/tối; đổi tần số xuống 5 Hz; đo DMM điện áp ở duty 50%; (nên) bắt sóng PWM bằng logic analyzer ở duty 25/50/75%.
- **Nghiệm thu:** LED fade; DMM ≈ 1.4–1.9 V ở duty 50% (dự kiến ≈ 1.65 V); code `main/main.c` đã commit.
- **Bằng chứng:** ảnh DMM, ảnh PulseView (nếu có).
- **Teach-back:** (1) Vì sao 5 Hz nhấp nháy còn 20 kHz thì không? (2) Duty 25% ở 3.3 V cho điện áp trung bình bao nhiêu? (≈ 0.83 V).

### M2 — Điều khiển motor an toàn (S02–S03, ~4 giờ) `[ ]`
- **Vấn đề mở đầu:** motor kéo dòng gấp hàng chục lần GPIO chịu được, và muốn đảo chiều phải đảo cực.
- **Dạy:** H-bridge (4 công tắc, chiều quay); bảng chân TB6612 (IN1/IN2/PWM/STBY: thuận, nghịch, short brake, stop); vì sao tách nguồn motor nhưng chung GND; nhiễu và tụ 100 nF; điện áp trung bình → tốc độ; vùng chết (dead zone).
- **Làm (S02):** hàn header vào breakout micro-USB; **G1**; nối TB6612 với **motor 3 V trong kit** trước (rủi ro thấp) + tụ 100 nF; điều khiển chiều và PWM; đo điện áp trên motor ở duty 25/50/75/100%; tìm duty tối thiểu để motor bắt đầu quay.
- **Làm (S03):** **G2** xác định cặp dây motor JGA25-370 bằng DMM; thay motor chính (chưa nối encoder); lặp lại bảng đo; so sánh brake và stop.
- **Nghiệm thu:** quay thuận/nghịch đúng lệnh; ESP32 không reset khi motor khởi động; bảng duty → điện áp cho cả hai motor; ghi duty tối thiểu của motor chính.
- **Bằng chứng:** ảnh mạch, `docs/data/motor_voltage_table.md`.
- **Teach-back:** (1) Vì sao không nối motor thẳng GPIO? (2) Brake khác stop thế nào? (3) Vì sao nguồn motor và ESP32 phải chung GND nhưng không chung nguồn?

### M3 — Encoder và đo tốc độ (S04–S05, ~4 giờ) `[ ]`
- **Vấn đề mở đầu:** không có phản hồi thì chỉ điều khiển mù; xung encoder đến nhanh, kiểm tra bằng vòng lặp sẽ bỏ sót.
- **Dạy:** encoder quadrature (A/B lệch 90° cho biết chiều quay); PPR và count/vòng (×4); tỉ số truyền; ngắt và PCNT (bộ đếm phần cứng); tốc độ = Δcount/Δt; lượng tử hóa và độ dài cửa sổ đo (10 ms so với 50 ms); lọc trung bình trượt.
- **Làm (S04):** **G3**; nối encoder; xem A/B bằng PulseView (hai sóng vuông lệch pha); đếm bằng PCNT quadrature (tra API v6.1, ví dụ component `esp_driver_pcnt`, header `driver/pulse_cnt.h`: xác minh trong docs); hiệu chuẩn quay tay 1 vòng.
- **Làm (S05):** in count và RPM mỗi 100 ms; bảng duty → RPM; so sánh nhiễu giữa cửa sổ 10 ms và 50 ms; thử lọc.
- **Nghiệm thu:** count/vòng đã hiệu chuẩn (kỳ vọng ≈ 937, sai lệch lớn thì dùng số đo thật và ghi lý do); đổi chiều quay thì count tăng/giảm đúng; RPM ổn định ở duty cố định (dao động ≲ ±5%); bảng duty → RPM.
- **Bằng chứng:** ảnh PulseView hai kênh, `docs/data/duty_vs_rpm.csv`.
- **Teach-back:** (1) PPR = 11 vì sao ra ≈ 937 count/vòng trục ra? (2) Cửa sổ đo dài hơn có lợi/hại gì? (3) Vì sao dùng PCNT thay vì ngắt?
- **→ ĐIỂM ĐỒNG BỘ P1 sau milestone này.**

### M4 — PID và FreeRTOS (S06–S08, ~6 giờ) `[ ]`
- **Vấn đề mở đầu:** cùng lệnh 50% nhưng tốc độ đổi theo tải và pin.
- **Dạy:** vòng hở và vòng kín; error; P, I, D tách riêng bằng thí nghiệm (P-only để lại sai lệch cuối, I loại sai lệch, D chống vọt); windup và anti-windup; chu kỳ lấy mẫu; step response (rise time, overshoot, settling time, steady-state error); FreeRTOS task, độ ưu tiên, `vTaskDelayUntil`, queue; vì sao tách task điều khiển khỏi task log.
- **Làm (S06):** `control_task` ưu tiên cao, chu kỳ 10 ms: đọc PCNT → RPM → P-only; thử 3 giá trị Kp.
- **Làm (S07):** thêm I + anti-windup; (D chỉ khi cần); log CSV qua UART với định dạng cố định (`thoi_gian_ms,setpoint,rpm,duty`); `logger_task` qua queue; script Python vẽ đồ thị (đóng monitor trước khi chạy script log).
- **Làm (S08):** 3 bộ tham số có bảng so sánh; thử nhiễu tải bằng cách chạm nhẹ trục (≤ 2 giây, **gate G4**); chỉnh tinh.
- **Nghiệm thu (mục tiêu mềm):** step response cho ≥ 3 bộ tham số kèm overshoot, settling time, sai lệch cuối; bộ cuối đạt sai lệch cuối < 5% và tự phục hồi sau nhiễu tải; ≥ 3 task FreeRTOS.
- **Bằng chứng:** `docs/img/step_response_*.png`, `docs/data/*.csv`, bảng tham số.
- **Teach-back:** (1) Vì sao P-only còn sai lệch cuối? (2) Windup là gì và chặn thế nào? (3) Vì sao `vTaskDelayUntil` chứ không phải `vTaskDelay`?
- **→ ĐIỂM ĐỒNG BỘ P2 sau milestone này.**

### M5 — Driver I2C INA219 và logging (S09–S10, ~4 giờ) `[ ]`
- **Điều kiện:** INA219 đã về. Nếu chưa, S09 dùng **dự phòng:** viết driver I2C cho PCF8574 trên LCD1602 (địa chỉ 0x27/0x3F) để học I2C trước.
- **Vấn đề mở đầu:** muốn biết motor ăn bao nhiêu dòng; thư viện có sẵn che mất giao thức, nhà tuyển dụng muốn thấy bạn hiểu mức thấp.
- **Dạy:** I2C (SDA/SCL, địa chỉ 7-bit, start/stop, ACK, điện trở pull-up); bảng thanh ghi; cách đọc datasheet; shunt resistor và định luật Ohm; thanh ghi calibration của INA219.
- **Làm:** **G6**; I2C scan thấy 0x40; hàm `ina219_read_reg` / `ina219_write_reg` (dùng driver I2C master của ESP-IDF v6.1, **không dùng thư viện INA219**); đọc bus voltage và shunt voltage; tính dòng; so với DMM nối tiếp; thêm kênh dòng điện vào log CSV; đồ thị dòng theo thời gian khi tăng tải.
- **Nghiệm thu:** scan thấy 0x40; driver tự viết; sai khác dòng so với DMM ≲ 5–10%; đồ thị dòng khi tải đổi.
- **Teach-back:** (1) Vì sao I2C cần pull-up? (2) INA219 đo dòng bằng cách nào? (3) Vì sao đặt nối tiếp với tải, không phải song song?

### M6 — Đóng gói portfolio (S11, ~3 giờ) `[ ]`
- **Làm:** README (mẫu ở ROADMAP Phần III); sơ đồ nối dây; ảnh và đồ thị trong `docs/`; video demo 30–60 giây (file lớn qua `D:\Ubuntu2204_shared_folder` rồi upload, dán link vào README); mục **Problems & Lessons** từ §7; dọn repo; tag `v1.0`; cập nhật `ROADMAP.md` và file này; luyện kể dự án trong 60 giây.
- **Nghiệm thu:** README đủ mục; video; repo sạch (`git status` sạch, không file rác); mục Problems & Lessons có ≥ 3 lỗi thật.
- **→ ĐIỂM ĐỒNG BỘ P3 sau milestone này; sau đó PM tạo file tiến độ dự án A.**

### Danh sách cắt giảm (nếu trễ lịch; cắt theo thứ tự)
1. Thành phần D của PID; núm xoay potentiometer làm setpoint.
2. Trau chuốt đồ thị; log nâng cao.
3. M5 rút gọn: chỉ đọc bus voltage và dòng cơ bản, bỏ phần tối ưu calibration.
**Không bao giờ cắt:** bằng chứng đo đạc, README, teach-back, mục Problems & Lessons.

---

## 6. NHẬT KÝ PHIÊN (Agent ghi, mới nhất ở cuối; ≤ 5 dòng mỗi mục)

**Lịch sử trước khi có Agent (PM tóm tắt):** Ubuntu VM và công cụ đã dựng xong; ESP-IDF v6.1.1 đã chạy blink trên ESP32; repo GitHub đã có cấu trúc, đồng bộ SSH; snapshot đã chụp; linh kiện đã về đủ (trừ INA219). Chưa làm: bài LEDC PWM ra LED, đọc ADC núm xoay, hàn dây và tụ 100 nF cho motor 3 V (người học xác nhận 2026-11-21: chưa bắt đầu bài thực hành nào của dự án B).

**Mẫu mục:**
```
### S0x — <tiêu đề> — <ngày>
- Dạy: <khái niệm>
- Người học làm: <việc>
- Kết quả / số liệu: <...>
- Teach-back: ĐẠT / CHƯA ĐẠT (<ghi chú>)
- Bằng chứng: <đường dẫn file> | Commit: <hash>
```

*(chưa có mục nào)*

---

## 7. LỖI VÀ VẤN ĐỀ (Agent ghi; PM xử lý khi trạng thái là ESCALATE)

Trạng thái: `OPEN` (Agent đang xử lý) → `ESCALATE` (giao PM) → `RESOLVED`.

| ID | Ngày | Triệu chứng | Môi trường / log (≤ 40 dòng) | Đã thử | Giả thuyết | Trạng thái | Giải pháp |
|---|---|---|---|---|---|---|---|
| | | | | | | | |

---

## 8. INBOX: PM → AGENT (Agent ghi "ACK + ngày" khi đã đọc)

- **PM-001 (2026-11-21):** Bắt đầu theo §5 từ **M0**, rồi **M1**. Đối chiếu cấu trúc repo với §3 ở phiên S00. **Việc cho người học:** đặt mua **INA219** (module cảm biến dòng I2C, thường kèm shunt 0.1 Ω; **chưa đặt mua**, PM đã giải thích chi tiết cho người học); phải về trước **S09**, nên đặt trước khi vào M3. Nhắc lại ở phiên S04 nếu chưa đặt.
- **PM-002 (2026-11-21): ĐÃ GIẢI QUYẾT.** Chế độ D (Agent chỉ chat). Xem §1.6.
- **PM-004 (2026-11-21):** Người học dán file theo "gói vào phiên" (§1.6). Cuối **mỗi** phiên, in "gói cập nhật" đủ 5 phần; nếu thiếu, nhắc người học trước khi kết thúc.
- **PM-003 (2026-11-21):** Chỉ dùng **motor 3 V trong kit** để thử mạch lần đầu (S02); chỉ nối motor chính sau **G2**.

---

## 9. QUYẾT ĐỊNH VÀ THAY ĐỔI (PM ghi)

| Mã | Ngày | Quyết định | Lý do |
|---|---|---|---|
| D-001 | 2026-11 | Motor chính: JGA25-370 6 V 1/21.3 có encoder | Motor 3 V 19000 RPM chỉ có 1 xung/vòng nên độ phân giải đo tốc độ quá kém |
| D-002 | 2026-11 | Cầu H: TB6612FNG (L293D dự phòng) | Motor 6 V trên nguồn 5 V cần cầu H tụt áp ít |
| D-003 | 2026-11 | Nguồn motor: adapter 5 V 2.5 A qua breakout micro-USB | Đã có adapter; cổng ra là micro-USB |
| D-004 | 2026-11 | ESP-IDF v6.1.1, làm toàn bộ trong Ubuntu VM | Môi trường đã dựng, đã chạy blink |
| D-005 | 2026-11 | Setpoint 100 và 150 RPM | Còn dư địa điều khiển so với tốc độ tối đa dự kiến ≈ 200 RPM |
| D-006 | 2026-11-21 | Dự án B làm trước, dự án A sau | Phần cứng đã về; đúng kế hoạch ban đầu |

**Mẫu Change Request (Agent gửi PM khi muốn đổi kế hoạch, thiết kế hoặc linh kiện):** đề xuất đổi gì → lý do → ảnh hưởng đến lịch và tiêu chí nghiệm thu → phương án thay thế.

---

## 10. BẰNG CHỨNG PORTFOLIO (Agent tick khi đã lưu và commit)

| Milestone | Bằng chứng cần có | Đã có |
|---|---|---|
| M1 | Ảnh DMM ở 50% duty; ảnh PulseView PWM | `[ ]` |
| M2 | Ảnh mạch; bảng duty → điện áp; duty tối thiểu của motor chính | `[ ]` |
| M3 | Ảnh PulseView 2 kênh A/B; số hiệu chuẩn count/vòng; bảng duty → RPM | `[ ]` |
| M4 | Đồ thị step response ≥ 3 bộ tham số; bảng tham số; đồ thị phục hồi nhiễu tải | `[ ]` |
| M5 | Ảnh scan I2C; so sánh dòng driver và DMM; đồ thị dòng | `[ ]` |
| M6 | README, video, sơ đồ nối dây, mục Problems & Lessons | `[ ]` |
