# Lộ trình 2 dự án Portfolio — Summer 2027 (Embedded / Hardware Intern)

> File này là **sổ tay sống**: bạn đọc, làm theo, và tự sửa khi kế hoạch thay đổi.
> Mọi thuật ngữ đều được giải thích từ đầu trong phần **Từ điển** của từng dự án. Gặp từ lạ → tra từ điển trước, đừng bỏ qua.
>
> **Cập nhật lần cuối: 20/11/2026.** Phần hardware đã chốt, môi trường đã dựng xong, xem **mục 0.5** (trạng thái), **Phần IV** (kiến trúc môi trường) và **Phần V** (sổ tay).

---

## 0. Cách dùng file này

1. Mỗi tuần: đọc phần **"Vì sao"** → đọc **"Kiến thức"** → làm **"Việc cần làm"** → tự kiểm tra bằng **"Làm đúng khi…"**.
2. Đánh dấu `- [x]` khi xong một việc.
3. Mỗi khi gặp lỗi, ghi ngay vào **Nhật ký lỗi** (cuối file). Đây sẽ trở thành mục "Problems & Lessons" trong README, và là phần nhà tuyển dụng đọc kỹ nhất.
4. Nếu kế hoạch đổi (trễ, thiếu linh kiện, đổi ý) → sửa vào **Nhật ký thay đổi** (cuối file) kèm ngày và lý do.
5. **Giả định thời gian:** khoảng 10–12 giờ/tuần. Nếu bạn có ít hơn, kéo dài từng tuần, nhưng **giữ nguyên thứ tự**.

### Quy tắc vàng: vòng lặp học–làm

```
Đọc ngắn (30 phút)  →  Làm ngay một bước nhỏ  →  ĐO để xem có đúng không
        ↑                                                  |
        └──────────── ghi lại lỗi và bài học ←─────────────┘
```

Không đọc cả cuốn sách rồi mới làm. Chỉ đọc đúng cái cần cho bước tiếp theo.

---

## 0.5. Trạng thái hiện tại (cập nhật 20/11/2026)

### Đã hoàn thành
- [x] VM Ubuntu 22.04.5 (4 CPU, RAM 5288 MB, ổ 59 GB), Extension Pack, Guest Additions, nhóm `dialout`
- [x] ESP-IDF v6.1.1 (cài bằng EIM); ví dụ blink đã nạp và chạy trên ESP32 (chip CP210x, ID `10c4:ea60`)
- [x] Pico SDK tại `~/pico/pico-sdk`, submodule `tinyusb` (0.18.0) đã tải; `arm-none-eabi-gcc` 10.3.1
- [x] PulseView + firmware fx2lafw, `picocom`
- [x] GitHub (tài khoản `ngodh`): 2 repo, khóa SSH, cấu trúc thư mục, `.gitignore`, `ROADMAP.md`
- [x] Repo FPGA clone cả ở Ubuntu và Windows (`C:\ISE\ISE_Projects\fpga-servo-coprocessor`); ISE VM thấy repo; sync test Windows ↔ Ubuntu ↔ ISE VM đạt
- [x] Snapshot "Ubuntu sạch" và "Tools OK"
- [x] Hạ RAM Ubuntu VM xuống 5288 MB để chạy cùng ISE VM (6144 MB) trên máy 16 GB
- [x] Đặt mua linh kiện (xem bên dưới)

### Đã đặt mua (chờ hàng về)
| Món | Ghi chú |
|---|---|
| Motor JGA25-370 6 V, tỉ số 1/21.3 (280 RPM), có encoder | Motor chính của dự án B |
| TB6612FNG module (header hàn sẵn) | Cầu H |
| Breakout micro-USB cái ×2 | Đưa 5 V từ adapter lên breadboard (chỉ dùng chân VBUS và GND) |
| Logic analyzer USB 24M 8CH | Dùng với PulseView |
| Hàng rào đực 1×40 chân 2.54 mm | Hàn header cho Pico (và các module chưa có chân) |

**Mua sau:** INA219 (cần từ Tuần 3), tụ điện phân 470–1000 µF 10 V (cần từ Tuần 4). **Tùy chọn:** thêm 2 servo SG90.

### Việc đang chờ hoặc chưa làm
- [ ] PWM ra LED bằng LEDC (nửa đầu Tuần 1) + 2 thí nghiệm: 5 Hz nhìn thấy nhấp nháy, đo điện áp 50% duty bằng DMM
- [ ] Đọc núm xoay (potentiometer) bằng ADC
- [ ] Hàn 2 dây và tụ gốm 100 nF vào motor 3 V trong kit
- [ ] Hàn header cho Pico (khi header về)
- [ ] Tạo thư mục `ise/` trong repo FPGA; xác nhận đường dẫn mount trong ISE VM (`ls /media`)
- [ ] Hàng về: kiểm tra từng món, đo DMM 5 V ở breakout trước khi nối

### Đề xuất bước tiếp theo (đang chờ bạn xác nhận)
1. Hoàn thành PWM ra LED + đọc ADC (không cần hàng mới).
2. Hàn tụ và dây cho motor 3 V cũ.
3. **Bắt đầu phần RTL của Tuần 4 sớm** vì không cần hàng mới: tạo project ISE trong `ise/`, viết `servo_pwm.v` + testbench, chạy ISim, rồi UCF và nạp Spartan-3E (dùng switch/LED). Servo thật chờ nguồn 5 V từ breakout.
4. Khi hàng về: làm Dự án B Tuần 1–3, rồi quay lại Dự án A Tuần 5–8.

---

## 1. Tổng quan

| | **Dự án B** (làm trước) | **Dự án A** (làm sau, dự án chủ lực) |
|---|---|---|
| Tên | Điều khiển tốc độ động cơ vòng kín | Bộ đồng xử lý servo trên FPGA |
| Thiết bị chính | ESP32 + cầu H + motor có encoder + cảm biến I2C | Spartan-3E + Pico + servo |
| Loại | Thiên về **Embedded** | **FPGA + Embedded** |
| Thời gian | Tuần 1–3 | Tuần 4–8 |
| Kỹ năng chứng minh | PWM, ngắt, PID, FreeRTOS, driver I2C, đo đạc | Verilog, testbench, SPI, register map, đồng bộ xung nhịp, tích hợp HW–SW |

**Vì sao làm B trước A?** Dự án A cần bạn đã quen với PWM, timer và SPI ở phía vi điều khiển. Dự án B dạy những thứ đó trong môi trường dễ debug hơn (chỉ một chip, có `printf`). Sau đó sang A (hai chip nói chuyện với nhau) sẽ ít bị rối hơn nhiều.

### Lịch tổng

| Tuần | Dự án | Chủ đề | Kết quả cuối tuần |
|---|---|---|---|
| 1 | B | Quay motor + đếm xung encoder | In ra được RPM thật |
| 2 | B | PID + FreeRTOS | Tốc độ bám theo giá trị đặt, có đồ thị |
| 3 | B | Driver I2C + logging + đóng gói | README + video, dự án B xong |
| 4 | A | Khối PWM servo (Verilog) | Xung 50 Hz đúng, servo quay |
| 5 | A | SPI slave trong FPGA | Testbench báo PASS |
| 6 | A | Register map + ghép khối | 8 kênh PWM điều khiển qua SPI (mô phỏng) + thử Pico đọc ID |
| 7 | A | Phần mềm Pico + CLI | Gõ lệnh → servo quay thật |
| 8 | A | Kiểm thử, tài liệu, video | Dự án A xong |

> Nếu trễ: **giảm phạm vi** (ví dụ 4 servo thay vì 8), **đừng giảm phần đo đạc và tài liệu**.

---

## 2. Chuẩn bị chung (làm trước Tuần 1)

- [x] Tạo tài khoản GitHub, tạo 2 repo: `esp32-motor-pid` và `fpga-servo-coprocessor`
- [x] Học 5 lệnh Git đủ dùng: `git init`, `git add`, `git commit -m "..."`, `git push`, `git log`. Commit **mỗi khi xong một bước nhỏ**, message ghi rõ đã làm gì (ví dụ: `Add servo PWM module with testbench`)
- [x] Tạo thư mục `docs/` trong mỗi repo để chứa ảnh waveform, đồ thị, sơ đồ
- [ ] Chuẩn bị file nhật ký lỗi (xem cuối file)
- [ ] Kiểm tra bộ đồ nghề: DMM hoạt động (đo thử pin AA ≈ 1.5 V), mỏ hàn, dây jumper, breadboard
- [x] (đã đặt mua) Nên có một **logic analyzer rẻ** (loại 8 kênh, 24 MHz, khoảng 100–200k VNĐ) dùng với phần mềm PulseView/sigrok. Nó "nhìn thấy" tín hiệu số mà DMM không thấy được, và sẽ cứu bạn rất nhiều giờ debug ở cả hai dự án.

**Vì sao cần logic analyzer?** DMM chỉ cho bạn *một con số* tại một thời điểm. Còn tín hiệu số như SPI hay I2C là *chuỗi bit thay đổi hàng triệu lần/giây*. Logic analyzer ghi lại chuỗi đó và vẽ thành đồ thị theo thời gian, để bạn thấy bit nào sai.

---

# PHẦN I — DỰ ÁN B: ĐIỀU KHIỂN TỐC ĐỘ ĐỘNG CƠ VÒNG KÍN (ESP32)

## B.1. Bài toán

Bạn cấp 50% công suất cho một động cơ DC. Không tải: quay 300 vòng/phút. Bạn lấy ngón tay giữ nhẹ trục: còn 200 vòng/phút. Pin yếu đi: lại chậm hơn nữa. **Cùng một lệnh, kết quả khác nhau**, vì bạn đang điều khiển mù (*open-loop*: ra lệnh mà không nhìn kết quả).

Cách sửa: **đo tốc độ thật → so với tốc độ mong muốn → tự chỉnh lệnh**, lặp lại liên tục, 100 lần mỗi giây. Đó là điều khiển vòng kín (*closed-loop*). Ví dụ đời thường: bạn lái xe, thấy tốc độ đang 45 km/h mà muốn 60, bạn đạp ga thêm; thấy 65 thì nhả ra. Bạn chính là một bộ điều khiển vòng kín.

## B.2. Sản phẩm cuối cùng

- ESP32 giữ tốc độ động cơ ở giá trị đặt (ví dụ 300 RPM), dù tải thay đổi
- Cảm biến I2C (INA219) đo dòng điện động cơ, **driver do chính bạn viết**
- Dữ liệu log ra máy tính và vẽ thành đồ thị
- Video demo + README + đồ thị step response (trước/sau khi chỉnh PID)

## B.3. Linh kiện và cách nối

| Linh kiện | Việc nó làm |
|---|---|
| ESP32 dev board | "Bộ não" |
| Cầu H (khuyên dùng **TB6612FNG**; L298N cũng được nhưng hao điện và nóng hơn) | Khuếch đại tín hiệu nhỏ của ESP32 thành dòng lớn cho motor |
| Motor DC có encoder (loại N20 hoặc JGA25-370 có sẵn encoder) | Vật được điều khiển + cảm biến tốc độ |
| Nguồn riêng cho motor (pin hoặc adapter 6–12 V, theo thông số motor) | Cấp năng lượng cho motor |
| INA219 module (cảm biến dòng I2C) | Đo dòng điện motor |
| Breadboard, dây jumper | Nối mạch |

**Nếu motor của bạn không có encoder:** dùng module cảm biến khe hồng ngoại (slot sensor) + một đĩa nhựa có lỗ gắn lên trục. Hoặc mua motor có encoder tích hợp (không đắt).

### Linh kiện thực tế đã chốt (20/11/2026)

| Linh kiện | Thông số | Trạng thái |
|---|---|---|
| Motor chính | JGA25-370, 6 V, tỉ số 1/21.3 (≈280 RPM), 6000 RPM trước hộp số, trục 4 mm, encoder 11 xung/vòng trục motor, 2 kênh A–B, encoder cấp 3.3–5 V | Đã đặt mua |
| Cầu H | TB6612FNG: VM tối đa 15 V, logic 2.7–5.5 V, 1.2 A mỗi kênh, PWM tới 100 kHz | Đã đặt mua |
| Nguồn motor | Adapter Vilros 5 V 2.5 A (đầu ra micro-USB) qua breakout micro-USB cái | Adapter có sẵn, breakout đã đặt |
| Motor thử nghiệm | Motor DC 3–6 V trong kit: 0.35–0.4 A, 19000 RPM ở 3 V, 2 dây, không encoder | Có sẵn |
| Cầu H dự phòng | L293D trong kit (tụt áp ~2 V, chịu 600 mA) | Có sẵn |
| Cảm biến dòng | INA219 | Mua sau (Tuần 3) |

- **Cấp encoder bằng 3.3 V từ ESP32** để tín hiệu ra là 3.3 V, an toàn cho chân ESP32.
- Motor 6 V chạy từ nguồn 5 V qua TB6612 (tụt áp ít) nên đạt khoảng 75% tốc độ định mức (≈200 RPM), vẫn còn dư địa cho PID.
- **Không cấp điện cho dây nào của motor khi chưa xác định đúng đâu là cặp dây motor** (đo điện trở bằng DMM giữa các cặp dây: cặp có điện trở thấp, vài Ω, là cuộn dây motor). Cấp nhầm vào dây encoder sẽ làm hỏng encoder.
- Nguồn 5 V (adapter) và nguồn ESP32 (USB máy tính) **không nối với nhau**, chỉ nối chung GND.
- Motor 3 V cũ chỉ dùng thí nghiệm (PWM, cầu H). 19000 RPM với 1 xung/vòng cho độ phân giải đo tốc độ rất kém (cửa sổ 10 ms chỉ ~3 xung), nên không dùng cho đồ thị PID của portfolio. Giữ trục chặt (stall) có thể làm nóng L293D; chỉ chạm nhẹ 1–2 giây.

### Cảnh báo an toàn phần cứng (đọc kỹ)

1. **Không nối motor thẳng vào chân GPIO của ESP32.** Chân GPIO chỉ chịu vài chục mA; motor kéo hàng trăm mA đến vài A → hỏng chip. Luôn qua cầu H.
2. **Nguồn motor và nguồn ESP32 tách riêng, nhưng nối chung GND.** Motor tạo nhiễu điện và sụt áp khi khởi động; nếu dùng chung nguồn, ESP32 có thể bị reset ngẫu nhiên.
3. **Encoder: kiểm tra điện áp cấp.** Nhiều encoder cấp 5 V và xuất tín hiệu 5 V, trong khi **chân ESP32 chỉ chịu 3.3 V**. Nếu datasheet cho phép, cấp encoder bằng 3.3 V. Nếu bắt buộc 5 V, dùng bộ chia áp hoặc module chuyển mức. Luôn **đo bằng DMM trước khi nối**.
4. Tránh các chân đặc biệt của ESP32: GPIO 0, 2, 12, 15 (strapping pin, ảnh hưởng lúc khởi động), GPIO 6–11 (nối flash), GPIO 34–39 (chỉ input).

### Gợi ý gán chân (xác nhận lại với board của bạn)

| Chức năng | GPIO gợi ý |
|---|---|
| PWM tới cầu H (PWMA) | 25 |
| Hướng (AIN1, AIN2) | 26, 27 |
| STBY của TB6612 | 14 (hoặc nối thẳng 3.3 V) |
| Encoder A, B | 32, 33 |
| I2C SDA, SCL | 21, 22 |

## B.4. Từ điển thuật ngữ (Dự án B)

**GPIO (General Purpose Input/Output).** Chân của chip mà bạn có thể bảo "xuất mức cao/thấp" hoặc "cho tôi biết mức đang là cao hay thấp". Giống một công tắc điện bạn bật/tắt được bằng code.

**PWM (Pulse Width Modulation).** Vấn đề: chip chỉ xuất được BẬT (3.3 V) hoặc TẮT (0 V), nhưng bạn muốn motor quay *chậm vừa*. Giải pháp: bật/tắt cực nhanh (ví dụ 20.000 lần/giây). Nếu bật 50% thời gian thì motor "cảm nhận" như được cấp nửa công suất.
- **Tần số PWM:** số chu kỳ bật/tắt mỗi giây (ví dụ 20 kHz).
- **Duty cycle:** phần trăm thời gian BẬT trong một chu kỳ (50% = bật nửa, tắt nửa).
- Ví dụ đời thường: bạn bật/tắt đèn bàn 1000 lần/giây; mắt bạn thấy đèn sáng "một nửa".

**Cầu H (H-bridge).** Vấn đề: motor cần dòng lớn, và để đổi chiều quay thì phải đảo cực điện. Cầu H là mạch gồm 4 công tắc điện tử xếp hình chữ H: bật cặp chéo này thì motor quay thuận, bật cặp chéo kia thì quay ngược. ESP32 chỉ gửi tín hiệu nhỏ để điều khiển các công tắc đó.

**Encoder.** Một đĩa có nhiều vạch gắn trên trục motor + cảm biến đếm vạch. Mỗi vạch đi qua → 1 xung điện. Quay nhanh → xung dày; quay chậm → xung thưa. Đếm xung trong một khoảng thời gian → biết tốc độ.
- **PPR (Pulses Per Revolution):** số xung mỗi vòng quay. Xem datasheet motor.
- **Quadrature (hai kênh A và B):** hai tín hiệu lệch pha nhau. Nhìn thứ tự A→B hay B→A để biết motor đang quay chiều nào.
- **Tỉ số truyền (gear ratio):** motor có hộp giảm tốc (ví dụ 1:30). Encoder thường gắn ở trục motor *trước* hộp số. Vậy một vòng trục ra = 30 vòng encoder → xung nhiều hơn.

**Ngắt (interrupt).** Vấn đề: xung encoder đến rất nhanh và bất ngờ; nếu code chỉ "ngó" chân GPIO mỗi lần vòng lặp, bạn sẽ bỏ sót xung. Ngắt là cơ chế: khi có xung, chip **dừng việc đang làm**, chạy ngay một hàm nhỏ (ISR) để đếm xung, rồi quay lại. Giống như bạn đang đọc sách thì chuông cửa reo: bạn đặt sách xuống, ra mở cửa, rồi đọc tiếp.
- ESP32 còn có **PCNT (Pulse Counter)**: bộ đếm xung *bằng phần cứng*, không cần ngắt, không bỏ sót. Nên dùng cái này cho encoder.

**Tính tốc độ từ xung.**
```
RPM = (số xung đếm được / PPR_trục_ra) / Δt(giây) × 60
```
Ví dụ: motor 11 xung/vòng ở trục motor, hộp số 1:30 → 330 xung/vòng ở trục ra. Trong 10 ms đếm được 11 xung → 1100 xung/giây → 1100/330 ≈ 3.33 vòng/giây → **200 RPM**. (Thay số liệu của motor bạn.)

**Điều khiển vòng kín và PID.**
- **Setpoint:** giá trị bạn muốn (300 RPM).
- **Measured:** giá trị đo được.
- **Error = setpoint − measured.**
- **PID** là công thức biến error thành lệnh PWM:
  - **P (Proportional):** sai lệch càng lớn, đạp ga càng mạnh. Đơn giản nhưng thường không bao giờ đạt chính xác (còn sai lệch nhỏ kéo dài).
  - **I (Integral):** cộng dồn sai lệch theo thời gian. Nếu cứ thiếu một chút kéo dài, I tăng dần cho đến khi bù hết. Giải quyết sai lệch kéo dài.
  - **D (Derivative):** nhìn tốc độ thay đổi của sai lệch để "phanh trước khi vượt quá". Hay bị nhiễu, thường để cuối cùng.
- **Anti-windup:** nếu motor đã chạy hết công suất mà vẫn chưa đủ tốc độ, I cứ cộng dồn mãi → tích lũy quá lớn → khi hết tải sẽ vượt quá rất nhiều. Cách sửa: giới hạn (clamp) giá trị I.
- Đời thường: máy điều hòa giữ phòng 25 °C chính là một bộ điều khiển vòng kín.

```c
// Ý tưởng PID (chạy mỗi dt = 0.01 giây)
error      = setpoint - measured;
integral  += error * dt;
integral   = clamp(integral, -I_MAX, I_MAX);       // anti-windup
derivative = (error - prev_error) / dt;
output     = Kp*error + Ki*integral + Kd*derivative;
duty       = clamp(output, 0, 100);                // giới hạn PWM 0–100%
prev_error = error;
```

**Step response (đáp ứng bước).** Bạn đột ngột đổi setpoint từ 0 lên 300 RPM rồi ghi lại tốc độ theo thời gian. Đồ thị cho thấy hệ thống phản ứng thế nào:
- **Rise time:** mất bao lâu để lên gần 300.
- **Overshoot:** vọt quá 300 bao nhiêu %.
- **Settling time:** mất bao lâu để ổn định quanh 300.
- **Steady-state error:** cuối cùng còn lệch bao nhiêu.
Đây là "ngôn ngữ chung" của kỹ sư điều khiển.

**FreeRTOS và task.** Vấn đề: chương trình của bạn phải (1) chạy PID đúng mỗi 10 ms, (2) đọc cảm biến, (3) gửi log. Nếu viết trong một vòng lặp lớn, việc gửi log chậm sẽ làm PID bị trễ → motor giật. FreeRTOS cho phép chia thành nhiều **task** (như nhiều "người làm việc" song song), mỗi task có **độ ưu tiên**; task PID ưu tiên cao nên luôn được chạy đúng giờ.
- `vTaskDelayUntil()`: đợi đến mốc thời gian tiếp theo (chu kỳ chính xác, không bị trôi).
- **Queue:** "hộp thư" an toàn để task này gửi dữ liệu cho task kia.

**I2C.** Giao thức nói chuyện giữa chip và cảm biến chỉ bằng 2 dây:
- **SDA** (dữ liệu), **SCL** (xung nhịp).
- Mỗi thiết bị có một **địa chỉ** (INA219 mặc định 0x40).
- Mỗi cảm biến có các **thanh ghi (register)** như những ngăn tủ đánh số; bạn đọc/ghi vào ngăn số mấy thì lấy được dữ liệu/ cài đặt tương ứng.
- **Điện trở pull-up (thường 4.7 kΩ):** dây I2C chỉ biết kéo xuống thấp; nó cần điện trở kéo lên mức cao. Thiếu pull-up là lỗi I2C phổ biến nhất. (Nhiều module breakout đã có sẵn.)

**Datasheet.** Tài liệu chính thức của nhà sản xuất chip, nói: chân nào làm gì, thanh ghi nào chứa cái gì, điện áp tối đa. Kỹ năng đọc datasheet là kỹ năng cốt lõi của kỹ sư phần cứng.

**INA219.** Chip đo điện áp và dòng điện. Nó đo sụt áp trên một điện trở rất nhỏ (shunt, thường 0.1 Ω) nối nối tiếp với tải, rồi suy ra dòng I = U/R. Khi motor chịu tải nặng, dòng tăng → bạn thấy trực tiếp bằng số.

## B.5. Lộ trình từng tuần

### Tuần 1 — Quay motor và đếm xung (Mục tiêu: in ra được RPM thật)

**Vì sao tuần này:** mọi thứ sau đó (PID, log) đều cần hai thứ: *ra lệnh cho motor* và *biết motor đang quay bao nhanh*. Không có hai thứ này thì PID chỉ là công thức trên giấy.

**Kiến thức cần:** GPIO, PWM, cầu H, encoder, PCNT/ngắt (xem Từ điển).

**Việc cần làm:**
- [x] Cài **ESP-IDF** (khuyên dùng, vì là bộ SDK chính thức, FreeRTOS tích hợp sẵn, công ty dùng thật) hoặc dùng Arduino framework nếu muốn nhanh hơn lúc đầu
- [x] Chạy ví dụ nhấp nháy LED (blink) để chắc môi trường hoạt động
- [ ] Dùng **LEDC** (bộ PWM của ESP32) xuất PWM 20 kHz ra một chân; xem bằng LED hoặc logic analyzer thấy độ sáng/độ rộng xung đổi theo duty
- [ ] Nối cầu H + motor (chưa nối encoder), cấp nguồn riêng, **đo điện áp ra motor bằng DMM** ở duty 25/50/75/100%
- [ ] Điều khiển chiều quay bằng AIN1/AIN2
- [ ] Nối encoder, dùng **PCNT** đếm xung A (rồi thêm B để biết chiều); in số đếm mỗi 100 ms
- [ ] Tính RPM theo công thức ở trên
- [ ] Điền bảng đo: duty (%) → RPM

**Làm đúng khi…**
- Quay trục bằng tay, số đếm thay đổi tương ứng; đổi chiều quay thì số đếm tăng/giảm đúng chiều
- Bảng duty → RPM có xu hướng tăng đều (có thể có vùng chết ở duty thấp vì motor chưa đủ lực khởi động)

**Tự kiểm tra:** (1) Vì sao không nối motor thẳng vào GPIO? (2) Nếu PPR trục ra là 330 và bạn đếm 66 xung trong 20 ms thì RPM bằng bao nhiêu? *(Đáp án: 66/330 = 0.2 vòng trong 0.02 s → 10 vòng/s → 600 RPM.)*

**Hằng số cho motor đã chốt (JGA25-370, 1/21.3):**
```c
#define ENCODER_PPR_MOTOR   11      // xung mỗi vòng trục motor (một kênh)
#define GEAR_RATIO          21.3f   // theo nhà sản xuất, cần hiệu chuẩn
#define COUNTS_PER_REV      (ENCODER_PPR_MOTOR * 4 * GEAR_RATIO)  // ≈ 937.2 count/vòng trục ra
```
- Ở khoảng 200 RPM (3.33 vòng/giây): ≈ 3100 count/giây, tức ≈ 31 count trong cửa sổ 10 ms; 1 count lệch ≈ 6.4 RPM (≈ 3% sai số lượng tử hóa).
- **Hiệu chuẩn:** quay tay trục ra đúng 1 vòng, đọc số count. Nếu ra ≈ 937 là đúng; nếu lệch nhiều thì dùng số đo thật và ghi vào Nhật ký lỗi.
- Dùng **PCNT** giải mã quadrature bằng phần cứng, cấp encoder 3.3 V. Nếu tín hiệu A/B không đổi mức khi quay, thử bật pull-up nội hoặc thêm điện trở 10 kΩ lên 3.3 V.
- **ESP-IDF v6.1.1 là bản rất mới:** nhiều ví dụ trên mạng viết cho v4/v5 dùng API cũ có thể không build được. Luôn tra tài liệu đúng bản v6.1 trên docs.espressif.com.

### Tuần 2 — PID và FreeRTOS (Mục tiêu: tốc độ bám theo setpoint, có đồ thị)

**Vì sao tuần này:** đây là phần lõi của dự án — biến "motor quay" thành "motor quay đúng tốc độ mong muốn".

**Kiến thức cần:** PID, step response, FreeRTOS task, `vTaskDelayUntil`.

**Việc cần làm:**
- [ ] Tạo task `control_task` ưu tiên cao, chu kỳ 10 ms bằng `vTaskDelayUntil`
- [ ] Trong task: đọc PCNT → tính RPM → tính PID → cập nhật duty PWM
- [ ] Bắt đầu với **chỉ P** (Ki = Kd = 0). Tăng Kp từng bước nhỏ, quan sát: nếu dao động mạnh → giảm bớt
- [ ] Thêm **I** để loại bỏ sai lệch kéo dài; thêm **anti-windup**
- [ ] Chỉ thêm **D** nếu vẫn vọt quá nhiều (tốc độ đo có nhiễu thì D thường gây hại, nhiều bài toán chỉ cần PI)
- [ ] Xuất dữ liệu theo dạng CSV qua UART: `thoi_gian_ms,setpoint,rpm,duty`
- [ ] Dùng Python (matplotlib) vẽ đồ thị step response; thử 3 bộ tham số khác nhau, so sánh
- [ ] Thử **nhiễu tải**: dùng ngón tay giữ nhẹ trục trong khi chạy, ghi lại cách bộ điều khiển hồi phục

**Làm đúng khi…** Đồ thị cho thấy tốc độ lên đến setpoint, ổn định (sai lệch cuối nhỏ), và khi bạn thêm tải thì tốc độ tụt rồi tự phục hồi.

**Phương pháp chỉnh PID thực tế (cho người mới):**
1. Ki = Kd = 0. Tăng Kp cho đến khi bắt đầu dao động đều.
2. Giảm Kp xuống khoảng một nửa.
3. Tăng Ki từ từ đến khi hết sai lệch cuối mà không dao động quá lớn.
4. Ghi lại mỗi thử nghiệm (Kp, Ki, Kd, overshoot, settling time) vào bảng. Bảng này là bằng chứng.

**Tự kiểm tra:** (1) Vì sao chỉ P thường còn sai lệch cuối? (2) Vì sao phải dùng `vTaskDelayUntil` thay vì `vTaskDelay`? *(Gợi ý: một cái tính từ mốc cố định, một cái tính từ lúc gọi, nên bị trôi.)*

### Tuần 3 — Driver I2C, logging, đóng gói (Mục tiêu: dự án B hoàn chỉnh)

**Vì sao tuần này:** viết driver từ datasheet chứng minh bạn đọc hiểu tài liệu gốc và hiểu giao thức ở mức thấp, thay vì chỉ gọi thư viện của người khác. Đây là thứ phân biệt bạn với người "ghép thư viện".

**Kiến thức cần:** I2C, địa chỉ thiết bị, thanh ghi, pull-up, datasheet INA219.

**Việc cần làm:**
- [ ] Nối INA219: VCC (3.3 V), GND, SDA, SCL; **đặt INA219 nối tiếp trên đường nguồn dương của motor** (VIN+ phía nguồn, VIN− phía cầu H), nhớ nối chung GND
- [ ] Viết hàm **I2C scan** để chắc thấy thiết bị ở địa chỉ 0x40
- [ ] Viết hai hàm cơ bản: `ina219_read_reg(reg)` và `ina219_write_reg(reg, value)` (dùng driver I2C master của ESP-IDF, không dùng thư viện INA219)
- [ ] Đọc datasheet INA219, tìm bảng thanh ghi: configuration (0x00), shunt voltage (0x01), bus voltage (0x02), power (0x03), current (0x04), calibration (0x05)
- [ ] Đọc điện áp bus và điện áp shunt; tự tính dòng I = U_shunt / R_shunt; **so sánh với DMM** (đo dòng bằng DMM nối tiếp) để kiểm chứng
- [ ] Tạo `logger_task` nhận dữ liệu qua **queue** từ control_task, gửi ra UART (không để task PID gửi trực tiếp)
- [ ] Vẽ đồ thị dòng điện theo thời gian khi thêm tải
- [ ] Quay video demo 30–60 giây
- [ ] Viết README (xem Phần III)

**Làm đúng khi…** Dòng điện từ driver của bạn sai khác DMM không nhiều (vài %), và khi bạn giữ trục thì dòng tăng rõ rệt.

**Tự kiểm tra:** (1) Vì sao I2C cần điện trở pull-up? (2) Vì sao đặt cảm biến dòng *nối tiếp* với tải, không phải song song?

### Mở rộng (chỉ làm nếu dư thời gian)
- Chế độ điều khiển vị trí (góc) thay vì tốc độ
- Giao diện web qua WiFi để đổi setpoint
- Giới hạn dòng: nếu dòng vượt ngưỡng thì tự giảm PWM (bảo vệ motor)

## B.6. Tiêu chí hoàn thành dự án B

- [ ] Tốc độ giữ ổn định dưới thay đổi tải, có đồ thị chứng minh
- [ ] Bảng so sánh ít nhất 3 bộ tham số PID
- [ ] Driver INA219 tự viết, kiểm chứng với DMM
- [ ] Ít nhất 3 task FreeRTOS (điều khiển, đọc cảm biến hoặc log, giao tiếp)
- [ ] Repo GitHub có README, sơ đồ nối dây, ảnh/đồ thị, video

## B.7. Lỗi thường gặp (và cách nghĩ)

| Hiện tượng | Nguyên nhân thường gặp | Cách kiểm tra |
|---|---|---|
| ESP32 tự reset khi motor khởi động | Sụt áp / nhiễu do chung nguồn | Tách nguồn, thêm tụ lọc, nối chung GND |
| RPM nhảy lung tung | Nhiễu xung encoder, dây dài, thiếu GND chung | Xem bằng logic analyzer; thêm bộ lọc trung bình |
| Motor không quay ở duty thấp | Vùng chết (lực khởi động) | Ghi lại duty tối thiểu để quay, bù trong code |
| PID dao động dữ dội | Kp quá lớn hoặc chu kỳ lấy mẫu không đều | Giảm Kp; kiểm tra chu kỳ task bằng log thời gian |
| I2C không thấy thiết bị | Sai địa chỉ, đảo SDA/SCL, thiếu pull-up | Chạy I2C scan; đo mức điện áp dây |

---

# PHẦN II — DỰ ÁN A: BỘ ĐỒNG XỬ LÝ SERVO TRÊN FPGA (SPARTAN-3E + PICO)

## A.1. Bài toán

Servo cần một xung lặp lại mỗi **20 ms**; độ rộng xung **1 ms đến 2 ms** quyết định góc quay (khoảng 1.5 ms = giữa). Giả sử bạn điều khiển **8 servo cùng lúc** bằng một vi điều khiển: mỗi servo cần timing riêng và chính xác đến micro-giây. Trong khi MCU còn phải đọc cảm biến, xử lý lệnh... chỉ cần một ngắt bị trễ một chút là servo giật.

**Cách khác:** dùng FPGA. FPGA không "chạy chương trình tuần tự" mà là **các khối mạch chạy song song thật sự**. Tám khối PWM nằm cạnh nhau, mỗi khối tự chạy, không cạnh tranh thời gian CPU. Vi điều khiển chỉ việc ra lệnh "kênh 3, 1.5 ms", FPGA lo phần còn lại. Mô hình **MCU + FPGA** này có thật trong rất nhiều thiết bị công nghiệp, y tế, viễn thông.

## A.2. Sản phẩm cuối cùng

```
[Pico (SPI master)] ──SPI──► [FPGA Spartan-3E]
  Giao diện dòng lệnh           ├─ SPI slave
  "set 3 1500"                  ├─ Register map (bảng thanh ghi)
  "get 3", "id"                 └─ 8 bộ PWM song song ──► 8 servo
```

- Gõ lệnh trên máy tính → Pico gửi SPI → FPGA cập nhật → servo quay
- Testbench tự kiểm tra (self-checking) cho PWM và SPI
- Ảnh waveform mô phỏng + ảnh logic analyzer đo thật
- README, bảng register map, sơ đồ khối, video

## A.3. Linh kiện và cách nối

| Linh kiện | Ghi chú |
|---|---|
| Bo Spartan-3E | Xung nhịp 50 MHz. Chuẩn I/O dùng `LVCMOS33` (3.3 V). **Có nguồn riêng**, nạp qua cổng **USB Type-B** (đã nạp thành công từ ISE VM). Model bo: CHƯA XÁC NHẬN |
| Raspberry Pi Pico | Cũng 3.3 V → nối trực tiếp được với FPGA. **Chưa hàn header**: hàn bằng thanh header đực 1×40 đã đặt (bẻ đôi thành 2 hàng 20 chân; cắm vào breadboard rồi hàn để thẳng hàng) |
| 4–8 servo (SG90 hoặc tương tự) | Hiện có **2 servo** (trong kit). Bắt đầu với 2 servo; mua thêm sau nếu muốn demo 4 con |
| Nguồn 5 V riêng cho servo (≥ 2–3 A nếu dùng nhiều servo) | Dùng adapter Vilros 5 V 2.5 A qua breakout micro-USB cái; đủ cho 2–4 servo. Servo khởi động/chịu tải kéo dòng lớn |
| Dây jumper, breadboard, logic analyzer (nên có) | |

### Cảnh báo an toàn phần cứng

1. **Không cấp nguồn servo từ FPGA hay Pico.** Dùng nguồn 5 V riêng, **nối chung GND** với FPGA và Pico. Servo khi khởi động có thể kéo hàng trăm mA mỗi con, nhiều con cùng lúc làm sụt áp và treo cả hệ thống.
2. Chân tín hiệu servo nối với chân FPGA; hầu hết servo nhận được mức 3.3 V. Nếu servo của bạn không phản ứng, kiểm tra datasheet.
3. Kiểm tra điện áp chân I/O của FPGA và Pico bằng DMM **trước khi nối** hai bên.
4. Lấy tên chân và vị trí các header từ **tài liệu bo (Spartan-3E Starter Kit User Guide, UG230)** để viết file ràng buộc chân (`.ucf`). Không đoán tên chân.

### Đề xuất nối SPI (Pico là master, FPGA là slave)

| Tín hiệu | Pico | FPGA | Chiều |
|---|---|---|---|
| SCK (xung nhịp) | GP18 | một chân I/O | Pico → FPGA |
| MOSI (dữ liệu từ master) | GP19 | một chân I/O | Pico → FPGA |
| MISO (dữ liệu về master) | GP16 | một chân I/O | FPGA → Pico |
| CS (chọn chip) | GP17 | một chân I/O | Pico → FPGA |
| GND | GND | GND | chung |

## A.4. Từ điển thuật ngữ (Dự án A)

**FPGA.** Một con chip chứa hàng ngàn "viên gạch logic" (LUT, flip-flop) mà bạn **tự nối lại bằng code** để tạo ra mạch số của riêng mình. Khác với MCU (chip có sẵn CPU chạy chương trình), ở FPGA bạn *thiết kế phần cứng*. Ví dụ: tám bộ đếm chạy cùng lúc thì thật sự có tám mạch đếm vật lý.

**Verilog / HDL.** Ngôn ngữ mô tả phần cứng. Điểm quan trọng: bạn không viết "lệnh chạy lần lượt", mà **mô tả mạch**. Các khối `always @(posedge clk)` chạy *đồng thời*.
> ⚠ Bộ công cụ **ISE 14.7** (dùng cho Spartan-3E) hỗ trợ **Verilog-2001** tốt nhưng **SystemVerilog hạn chế**. Hãy viết phần RTL (mã đưa lên chip) bằng Verilog thuần.

**Clock (xung nhịp).** Tín hiệu vuông đều đặn (ở đây 50 MHz = 50 triệu chu kỳ/giây, mỗi chu kỳ **20 ns**). Mọi mạch số "nhích một bước" theo mỗi nhịp.

**Flip-flop (FF) và `posedge clk`.** FF là ô nhớ 1 bit, chỉ cập nhật tại cạnh lên (posedge) của clock. Mạch đếm, thanh ghi... đều xây từ FF.

**Counter (bộ đếm), comparator (bộ so sánh).** Hai khối cơ bản nhất. PWM = bộ đếm chạy từ 0 đến 19999 (mỗi bước 1 µs) + bộ so sánh: "nếu đếm < độ rộng xung thì xuất 1, ngược lại xuất 0".

**FSM (Finite State Machine, máy trạng thái).** Mạch có vài "trạng thái" (ví dụ: ĐỢI, NHẬN BIT, XONG) và quy tắc chuyển giữa chúng. Giống đèn giao thông: xanh → vàng → đỏ. SPI slave dùng FSM hoặc bộ đếm bit để biết đang nhận bit thứ mấy.

**Testbench và simulation (mô phỏng).** Vấn đề: nạp lên chip thật rồi mới thử thì không thể "nhìn" bên trong. Testbench là một đoạn code (chạy trên máy tính, không lên chip) mô phỏng "thế giới bên ngoài": tạo clock, gửi tín hiệu vào, kiểm tra tín hiệu ra. Mô phỏng cho bạn xem từng tín hiệu theo thời gian (waveform). **Self-checking testbench** tự so sánh kết quả và in `PASS/FAIL`, không cần bạn nhìn bằng mắt.
- Trong ISE: dùng **ISim**.

**Synthesis, UCF, bitstream.** Quy trình: code Verilog → *synthesis* (biến thành mạch logic) → *implement* (xếp mạch vào chip, nối chân) → *bitstream* (file cấu hình để nạp). **UCF** là file nói "tín hiệu `sck` nối với chân vật lý nào của chip". Nạp bằng **iMPACT** (bạn đã dùng cho dự án led_test).

**SPI (Serial Peripheral Interface).** Cách hai chip nói chuyện bằng 4 dây:
- **SCK:** xung nhịp do master tạo ra
- **MOSI:** dữ liệu master → slave
- **MISO:** dữ liệu slave → master
- **CS (chip select):** master kéo xuống thấp để "gọi" slave này
Mỗi nhịp SCK, mỗi bên truyền 1 bit. Master là bên quyết định tốc độ.
- **CPOL/CPHA (mode 0..3):** quy ước SCK nghỉ ở mức nào (CPOL) và lấy mẫu dữ liệu ở cạnh nào (CPHA). Hai bên **phải dùng cùng mode**. Bắt đầu bằng **Mode 0** (CPOL = 0, CPHA = 0): SCK nghỉ ở mức thấp, dữ liệu được đọc ở cạnh lên.
- Ví dụ đời thường: master là người hỏi, nhịp SCK là tiếng gõ bàn; mỗi tiếng gõ là một chữ cái được đọc.

**Đồng bộ tín hiệu ngoài vào miền clock (synchronizer).** Vấn đề: SCK, MOSI, CS đến từ chip khác, **không đồng bộ** với clock 50 MHz của FPGA. Nếu tín hiệu đổi đúng lúc FF đang lấy mẫu, FF có thể rơi vào trạng thái chập chờn (*metastability*) và cho giá trị sai ngẫu nhiên — lỗi rất khó tìm. Cách chuẩn: cho tín hiệu qua **2 flip-flop nối tiếp** trước khi dùng. Sau đó phát hiện **cạnh lên/cạnh xuống** của SCK bằng cách so sánh giá trị hiện tại với giá trị chu kỳ trước.
- Vì FPGA chạy 50 MHz, nên SCK của SPI để thấp (khoảng 1 MHz) cho an toàn: SCK chậm hơn clock FPGA rất nhiều (≥ 10 lần).

**Register map (bảng thanh ghi).** Thay vì mỗi thông tin có một đường dây riêng, ta đánh số các "ngăn nhớ" (địa chỉ). MCU ghi vào "ngăn số 3" giá trị 1500 nghĩa là "kênh 3 rộng 1500 µs". Đây đúng là cách các chip thương mại (cảm biến, driver, bộ nhớ) được thiết kế, nên nhà tuyển dụng rất quen thuộc.

**Shadow register (thanh ghi bóng).** Nếu bạn đổi độ rộng xung *giữa chu kỳ* thì xung hiện tại bị cụt/dài lạ, servo giật. Giải pháp: lưu giá trị mới vào thanh ghi đệm, chỉ chuyển sang giá trị dùng thật **ở đầu chu kỳ 20 ms kế tiếp**.

**ID register ("Who am I").** Một thanh ghi chỉ-đọc chứa hằng số cố định (ví dụ 0xA55A). Bước đầu tiên khi tích hợp phần cứng: đọc thử ID. Nếu đọc đúng → SPI hoạt động, đúng dây, đúng mode. Thủ thuật kỹ sư rất hay dùng.

**Pico SDK.** Bộ thư viện C/C++ chính thức cho Pico (`spi_init`, `gpio_put`...). Dùng CMake để build.

## A.5. Thiết kế giao thức (để bạn chỉnh nếu muốn)

**Khung SPI 24 bit (3 byte), MSB trước:**

```
 byte 0                 byte 1         byte 2
[R/W][ADDR 7 bit]    [DATA cao 8]   [DATA thấp 8]
```

- R/W = 0: ghi; R/W = 1: đọc
- Khi **đọc**: FPGA biết địa chỉ sau 8 bit đầu, rồi đưa giá trị thanh ghi ra MISO trong 16 bit sau
- Khi **ghi**: FPGA giữ 16 bit dữ liệu vào thanh ghi đúng địa chỉ **khi CS lên lại mức cao**

**Register map:**

| Địa chỉ | Tên | R/W | Ý nghĩa |
|---|---|---|---|
| 0x00–0x07 | `PULSE_CH0..7` | R/W | Độ rộng xung (µs). Hợp lệ 500–2500; ngoài khoảng thì bị kẹp (clamp) để bảo vệ servo |
| 0x10 | `ENABLE` | R/W | Mỗi bit bật/tắt một kênh |
| 0x20 | `ID` | R | Hằng số `0xA55A` |
| 0x21 | `VERSION` | R | Phiên bản thiết kế |

*(Đây là đề xuất. Nếu bạn đổi, ghi vào Nhật ký thay đổi.)*

**Phép tính để thấy nó khả thi:** clock 50 MHz → 1 µs = 50 chu kỳ → bộ chia tick đếm 0..49. Chu kỳ 20 ms = 20.000 tick → bộ đếm 15 bit (2^15 = 32.768 > 20.000). **Một bộ đếm dùng chung, tám bộ so sánh** là đủ.

## A.6. Lộ trình từng tuần

### Tuần 4 — Khối PWM servo (Mục tiêu: xung 50 Hz đúng, servo quay)

**Vì sao tuần này:** đây là khối đơn giản nhất nhưng dạy bạn trọn quy trình FPGA (viết → mô phỏng → nạp → đo). Làm quen quy trình trên thứ dễ trước khi đụng thứ khó (SPI).

**Kiến thức cần:** clock, counter, comparator, testbench, synthesis, UCF, iMPACT.

**Môi trường (chi tiết ở Phần IV):** soạn `rtl/`, `tb/`, `constraints/` trên **Windows** (VS Code) trong `C:\ISE\ISE_Projects\fpga-servo-coprocessor`; mở **ISE VM** để ISim, synthesis, bitstream và iMPACT; ISE VM đọc thẳng cùng thư mục đó, **không cần clone hay copy**. Khi Add Source trong ISE, **bỏ tích "Copy to Project"**. Tên file toàn chữ thường (ISE VM là Linux, phân biệt hoa/thường). Project ISE đặt trong `ise/` và thêm nguồn bằng đường dẫn tương đối (`../rtl/...`).

**Việc cần làm:**
- [ ] Nhắc lại quy trình ISE bạn đã làm với `led_test` (tạo project → code → UCF → bitstream → iMPACT)
- [ ] Viết khối tạo **tick 1 µs** (bộ đếm 0..49)
- [ ] Viết **bộ đếm chu kỳ 0..19999** (tăng mỗi tick)
- [ ] Viết một kênh: `pwm_out = (period_cnt < width_us)`
- [ ] Viết **testbench**: tạo clock 50 MHz, đặt `width_us = 1500`; chạy mô phỏng; đo trên waveform xem xung rộng 1500 µs, chu kỳ 20 ms
- [ ] Nâng lên N kênh bằng `parameter N = 8` (một bộ đếm dùng chung)
- [ ] Viết UCF, nạp bo, cho `width_us` đổi bằng **switch** trên bo; nối 1 servo (nguồn 5 V riêng!) xem nó quay
- [ ] Đo xung bằng logic analyzer (hoặc DMM chế độ duty/Hz: ở 50 Hz, duty 5–10% là đúng)

> **Hãy tự viết trước, đừng chép.** Sau đó so với ý tưởng sau để thấy khác biệt:

```verilog
// Ví dụ minh họa (Verilog-2001) — chỉ để đối chiếu
module servo_pwm (
    input  wire        clk,       // 50 MHz
    input  wire        rst,
    input  wire [15:0] width_us,  // độ rộng xung, đơn vị µs
    output reg         pwm_out
);
    reg [5:0]  tick_cnt;
    reg [14:0] period_cnt;
    wire       tick = (tick_cnt == 6'd49);   // mỗi 1 µs

    always @(posedge clk) begin
        if (rst) begin
            tick_cnt   <= 6'd0;
            period_cnt <= 15'd0;
        end else if (tick) begin
            tick_cnt   <= 6'd0;
            period_cnt <= (period_cnt == 15'd19999) ? 15'd0 : period_cnt + 15'd1;
        end else begin
            tick_cnt <= tick_cnt + 6'd1;
        end
    end

    always @(posedge clk)
        pwm_out <= (period_cnt < width_us);
endmodule
```

**Làm đúng khi…** Waveform mô phỏng và logic analyzer đều cho: chu kỳ 20 ms, độ rộng bằng đúng `width_us`, và servo quay theo switch.

**Tự kiểm tra:** (1) Vì sao dùng bộ đếm 15 bit chứ không phải 14? (2) Nếu clock là 100 MHz thì bộ chia tick phải đếm đến mấy?

### Tuần 5 — SPI slave (Mục tiêu: testbench báo PASS)

**Vì sao tuần này:** SPI slave là khối khó nhất. Dành nguyên một tuần và test **trong mô phỏng** trước khi đụng phần cứng, vì trong mô phỏng bạn nhìn được mọi tín hiệu, còn trên chip thật thì không.

**Kiến thức cần:** SPI mode 0, synchronizer 2-FF, phát hiện cạnh, thanh ghi dịch (shift register), bộ đếm bit.

**Việc cần làm:**
- [ ] Vẽ tay (giấy) sơ đồ thời gian SPI mode 0, đánh dấu: CS xuống → từng bit ở mỗi cạnh lên SCK → CS lên
- [ ] Viết khối **đồng bộ** SCK/MOSI/CS (2 FF mỗi tín hiệu) và **phát hiện cạnh lên/cạnh xuống** của SCK
- [ ] Viết **thanh ghi dịch 24 bit** nhận MOSI ở mỗi cạnh lên SCK, bộ đếm bit 0..23
- [ ] Khi CS lên lại (kết thúc khung): xuất ra tín hiệu `frame_done` và giá trị khung nhận được (R/W, địa chỉ, dữ liệu)
- [ ] Viết testbench có một **task `spi_write(addr, data)`** mô phỏng master: kéo CS xuống, phát 24 bit với SCK 1 MHz, kéo CS lên
- [ ] Testbench tự kiểm: gửi nhiều khung (kể cả giá trị biên như 0x0000, 0xFFFF), so khớp, in `PASS`/`FAIL`
- [ ] **Chỉ làm đường ghi** trong tuần này; đường đọc để tuần 6–8

**Làm đúng khi…** Testbench gửi hơn 20 khung ngẫu nhiên và tất cả đều khớp.

**Tự kiểm tra:** (1) Vì sao phải đồng bộ SCK trước khi dùng? (2) Nếu hai bên dùng mode khác nhau (master mode 0, slave đọc ở mode 1) thì điều gì xảy ra với dữ liệu?

### Tuần 6 — Register map và ghép khối (Mục tiêu: 8 kênh PWM điều khiển qua SPI)

**Vì sao tuần này:** ghép hai khối đã test riêng thành hệ thống. Làm cả **thử tích hợp sớm với Pico** để lộ lỗi sớm, đừng để tuần cuối mới nối thật.

**Việc cần làm:**
- [ ] Viết khối **register map**: giải mã địa chỉ, ghi vào `PULSE_CHx`, `ENABLE`; đọc từ `ID`, `VERSION`
- [ ] Thêm **kẹp (clamp)** giá trị 500–2500 µs
- [ ] Thêm **shadow register**: giá trị mới chỉ có hiệu lực ở đầu chu kỳ 20 ms kế tiếp
- [ ] Thêm **đường đọc SPI**: sau 8 bit đầu (biết địa chỉ), nạp giá trị thanh ghi vào thanh ghi dịch và đưa ra MISO (đổi dữ liệu ở cạnh xuống SCK trong mode 0)
- [ ] Mở rộng testbench: ghi → đọc lại → so sánh; ghi giá trị ngoài khoảng → kiểm tra bị kẹp
- [ ] Nối top-level: SPI slave + register map + PWM ×8, viết UCF, nạp bo
- [ ] Dùng LED hoặc logic analyzer để thấy đầu ra PWM đổi khi bạn ghi
- [ ] **Cuối tuần (thử sớm):** nối Pico (dây SPI ngắn, chung GND), viết chương trình tối thiểu đọc thanh ghi `ID`; mục tiêu: nhận về `0xA55A`

**Làm đúng khi…** Đọc `ID` từ Pico thật nhận được đúng hằng số. Nếu chưa được: không sang tuần 7; dùng logic analyzer xem SCK/MOSI/MISO/CS để tìm lỗi (xem Bảng lỗi bên dưới).

### Tuần 7 — Phần mềm Pico và giao diện dòng lệnh (Mục tiêu: gõ lệnh → servo quay thật)

**Vì sao tuần này:** phần cứng đã sẵn sàng, giờ làm cho nó **dùng được**. Một giao diện lệnh đơn giản biến một dự án "rời rạc" thành một hệ thống có thể demo.

**Việc cần làm:**
- [ ] Cài **Pico SDK** (C/C++, CMake), build thử chương trình mẫu blink
- [ ] Khởi tạo SPI ở 1 MHz, mode 0, tự điều khiển chân CS bằng GPIO:

```c
spi_init(spi0, 1000 * 1000);
spi_set_format(spi0, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);
gpio_set_function(18, GPIO_FUNC_SPI);  // SCK
gpio_set_function(19, GPIO_FUNC_SPI);  // MOSI
gpio_set_function(16, GPIO_FUNC_SPI);  // MISO
gpio_init(17); gpio_set_dir(17, GPIO_OUT); gpio_put(17, 1);  // CS thủ công
```

- [ ] Viết hai hàm: `fpga_write(addr, value)` và `fpga_read(addr)` (đóng khung 3 byte theo A.5, kéo CS xuống/lên quanh mỗi khung)
- [ ] Viết CLI qua USB serial: `id`, `set <kênh> <µs>`, `get <kênh>`, `enable <mask>`
- [ ] Nối 2–4 servo (nguồn 5 V riêng, chung GND), thử từng lệnh
- [ ] Viết một chương trình mẫu: quét servo qua lại mượt (ví dụ sóng tam giác)

**Làm đúng khi…** `set 3 1500` làm servo 3 về giữa; `get 3` trả lại 1500; lệnh `set 3 3000` bị kẹp về 2500.

### Tuần 8 — Kiểm thử, tài liệu, video (Mục tiêu: dự án A hoàn chỉnh)

**Việc cần làm:**
- [ ] **Stress test:** Pico gửi hàng ngàn lệnh ngẫu nhiên trong 10 phút; đọc lại và so khớp; ghi lại số lỗi (mục tiêu: 0)
- [ ] Chụp **ảnh waveform** quan trọng (mô phỏng + logic analyzer): một khung SPI, xung PWM 1 ms / 1.5 ms / 2 ms
- [ ] Vẽ sơ đồ khối và bảng register map vào README
- [ ] Viết mục **Problems & Lessons** từ Nhật ký lỗi
- [ ] Quay video: gõ lệnh, nhiều servo chuyển động cùng lúc không giật
- [ ] Dọn repo: cấu trúc thư mục rõ (`rtl/`, `tb/`, `constraints/`, `pico_fw/`, `docs/`)

### Mở rộng (chỉ khi dư thời gian)
- Khối **đếm encoder** trong FPGA, Pico đọc tốc độ qua thanh ghi
- Khối **ramp**: servo tự chuyển động mượt từ góc này sang góc khác với tốc độ cài đặt
- Cổng **ngắt** (FPGA kéo một chân báo cho Pico khi có sự kiện)

## A.7. Tiêu chí hoàn thành dự án A

- [ ] 4–8 servo chạy đồng thời, không giật
- [ ] Testbench tự kiểm cho PWM và SPI (báo PASS)
- [ ] Đọc/ghi thanh ghi từ Pico hoạt động ổn định (stress test 0 lỗi)
- [ ] Bảng register map và sơ đồ khối trong README
- [ ] Ảnh waveform mô phỏng + đo thật
- [ ] Video + Problems & Lessons

## A.8. Lỗi thường gặp (và cách nghĩ)

| Hiện tượng | Nguyên nhân thường gặp | Cách kiểm tra |
|---|---|---|
| Đọc `ID` ra toàn 0x0000 hoặc 0xFFFF | Sai dây, thiếu GND chung, FPGA chưa nạp | Logic analyzer xem MISO có đổi không; đo DMM |
| Dữ liệu đúng nhưng lệch 1 bit | Sai mode SPI (CPHA) hoặc đếm bit sai | So sánh waveform với sơ đồ thời gian vẽ tay |
| Lỗi ngẫu nhiên, lúc đúng lúc sai | Thiếu đồng bộ 2-FF, SCK quá nhanh | Giảm SCK xuống 100 kHz thử; kiểm tra khối đồng bộ |
| Mô phỏng PASS nhưng trên chip lỗi | Sai chân UCF, mức điện áp, hoặc code không tổng hợp được | Xem cảnh báo của synthesis; kiểm tra UCF |
| Servo giật/rung | Sụt nguồn, xung không đều, thiếu shadow register | Dùng nguồn 5 V riêng đủ mạnh; xem xung bằng logic analyzer |
| ISE báo lỗi cú pháp | Dùng cú pháp SystemVerilog trong RTL | Viết lại bằng Verilog-2001 |

---

# PHẦN III — ĐÓNG GÓI PORTFOLIO

## Mẫu README cho mỗi dự án

```markdown
# Tên dự án
Video demo: <link>

## Mục tiêu (1–2 câu: bài toán gì, vì sao)
## Sơ đồ khối
## Phần cứng (danh sách linh kiện + sơ đồ nối dây)
## Cách chạy / build
## Kết quả (ảnh waveform, đồ thị, số liệu đo)
## Problems & Lessons  ← QUAN TRỌNG NHẤT
- Lỗi 1: hiện tượng → giả thuyết → cách kiểm tra → nguyên nhân thật → cách sửa
## Việc có thể làm tiếp
```

## Cách kể mỗi dự án trong 60 giây (phỏng vấn)

1. **Bài toán:** vấn đề cụ thể là gì?
2. **Thiết kế:** vì sao chọn cách này?
3. **Khó khăn:** một lỗi thật bạn đã gặp và cách tìm ra nguyên nhân
4. **Kết quả:** có con số hoặc đồ thị chứng minh
5. **Bài học:** nếu làm lại thì đổi gì

---

# PHẦN IV — KIẾN TRÚC MÔI TRƯỜNG LÀM VIỆC

**Ba nguyên tắc:** (1) Git là đường duy nhất đưa source giữa Ubuntu và Windows. (2) ISE VM không có bản source riêng, nó đọc thẳng clone trên Windows. (3) Mỗi thiết bị USB gắn cố định với một VM.

## IV.1. Vai trò từng môi trường

| Môi trường | Cấu hình | Làm | Không làm | USB |
|---|---|---|---|---|
| **Windows 11 host** | RAM 16 GB, VirtualBox + Extension Pack, Git for Windows, VS Code | Soạn Verilog/testbench/UCF; git cho clone A#1; chạy VM | Cài ESP-IDF/Pico SDK, build firmware | Cắm vật lý mọi thiết bị, nhường cho VM bằng USB filter |
| **Ubuntu 22.04.5 VM** | 4 CPU, RAM 5288 MB, ổ 59 GB | **Toàn bộ Dự án B**; build và nạp Pico; PulseView; serial; git cho repo B và `pico_fw/`, README, `docs/` của repo A | Verilog, ISE, đặt repo trong shared folder | ESP32, Pico, logic analyzer |
| **ISE 14.7 VM** | Oracle Linux (do AMD cung cấp), RAM 6144 MB | ISim, synthesis, implementation, bitstream, **iMPACT nạp Spartan-3E** | Git, clone repo, Pico/ESP32 | Spartan-3E (USB Type-B) |
| **GitHub** | Tài khoản `ngodh` | Lưu lịch sử, đồng bộ, backup | Chứa file build | Không |

## IV.2. Sơ đồ

```
                    ┌──────────────────────────┐
                    │          GITHUB          │
                    │ repo B  esp32-motor-pid  │
                    │ repo A  fpga-servo-...   │
                    └───▲──────────────────▲───┘
      git pull/push     │ (SSH)            │ (HTTPS)   git pull/push
      repo B + repo A   │                  │           repo A
 ┌──────────────────────┴──┐        ┌──────┴───────────────────────┐
 │ UBUNTU VM  (ext4)       │        │ WINDOWS 11 HOST  (NTFS)      │
 │ clone B  (đầy đủ)       │        │ clone A#1                    │
 │ clone A#2               │        │ C:\ISE\ISE_Projects\         │
 │ BUILD: ESP32 + Pico     │        │   fpga-servo-coprocessor     │
 │ ESP-IDF, Pico SDK       │        │ SOẠN Verilog, UCF            │
 └─────────────────────────┘        └──────────────┬───────────────┘
                                                   │ Shared Folder
                                                   │ (vboxsf, cùng file)
                                    ┌──────────────▼───────────────┐
                                    │ ISE 14.7 VM (Oracle Linux)   │
                                    │ KHÔNG clone, KHÔNG git       │
                                    │ ISim · XST · Impl · Bitgen   │
                                    │ iMPACT                       │
                                    └──────────────────────────────┘
 Global Folder D:\Ubuntu2204_shared_folder: chỉ chuyển file lớn (video, log thô).

 Phần cứng và USB:
   Windows ─ USB filter → Ubuntu VM:  ESP32 (CP210x, flash + log UART)
                                      Pico (BOOTSEL: ổ RPI-RP2 | chạy: /dev/ttyACM0)
                                      Logic analyzer (PulseView)
           ─ USB filter → ISE VM:     Spartan-3E (USB-B, iMPACT)
   Pico ──SPI (GP16 MISO, GP17 CS, GP18 SCK, GP19 MOSI) + GND chung──► chân I/O Spartan-3E
   Spartan-3E ──PWM──► servo (nguồn 5 V riêng từ adapter)
```

| Luồng | Từ → đến | Nội dung |
|---|---|---|
| Git | Ubuntu ↔ GitHub (SSH); Windows ↔ GitHub (HTTPS) | Source |
| Cùng file | Windows ↔ ISE VM (shared folder) | Verilog, UCF, project ISE; không phải truyền file |
| Build artifacts | Nằm lại nơi build | `.bit` (ISE VM), `.uf2` và `build/` (Ubuntu); không vào Git |
| USB | Windows → VM | Mỗi thiết bị thuộc một VM cố định |
| Serial/UART | ESP32 và Pico → Ubuntu | Log, đồ thị, CLI |
| SPI | Pico → FPGA | Khung 24 bit đọc/ghi thanh ghi |

## IV.3. Git: quy tắc sở hữu thư mục

Repo B: **1 clone** (Ubuntu). Repo A: **2 clone** (Windows và Ubuntu), đồng bộ bằng GitHub. Mỗi nơi chỉ sửa vùng của mình nên không bao giờ xung đột merge.

| Thư mục (repo A) | Chỉ sửa ở |
|---|---|
| `rtl/`, `tb/`, `constraints/`, `ise/`, `docs/img/sim_*` | **Windows** (clone A#1) |
| `pico_fw/`, `README.md`, `docs/*.md`, `docs/img/la_*`, `docs/logs/` | **Ubuntu** (clone A#2) |

- Quy ước tên file: **chữ thường, gạch dưới** (`servo_pwm.v`, `servo_pwm_tb.v`), tên module trùng tên file.
- Không đưa vào Git: `build/`, `.bit`, `.uf2`, `.elf`, `sdkconfig`, `managed_components/`, file sinh ra của ISE (đã có trong `.gitignore`).
- Ubuntu thấy `ISE_Projects` nhưng **chỉ để xem**, không chạy git hay build ở đó.

## IV.4. Shared folder

| Thư mục | Vai trò |
|---|---|
| `C:\ISE\ISE_Projects` | Cầu nối clone Windows ↔ ISE VM (cùng file). Bắt buộc cho Dự án A |
| `D:\Ubuntu2204_shared_folder` | Chỉ chuyển file lớn (video, log thô). Không chứa source |

| Loại tài nguyên | Chuyển bằng gì |
|---|---|
| Source | Git |
| Build artifacts, firmware, bitstream | Không chuyển, nằm lại nơi build |
| Waveform | Ảnh chụp trong `docs/img/` qua Git |
| Log nhỏ, báo cáo | Git |
| Log lớn, video | `D:\Ubuntu2204_shared_folder`, rồi upload (Drive/YouTube) |

Không build ESP32 và Pico trong shared folder. ISE buộc phải làm việc trong thư mục project; nếu chậm hoặc lỗi khóa file/quyền thì ghi vào Nhật ký lỗi và tìm phương án dự phòng.

## IV.5. USB filter

| Thiết bị | VM | Filter |
|---|---|---|
| ESP32 (CP210x) | Ubuntu | Vendor `10c4`, Product `ea60` |
| Pico | Ubuntu | Vendor `2e8a`, Product để trống (bắt cả BOOTSEL và chạy thường) |
| Logic analyzer | Ubuntu | `lsusb` trước/sau khi mở PulseView, thêm cả hai ID |
| Spartan-3E | ISE VM | ID lấy từ Devices → USB của ISE VM |

Một thiết bị chỉ thuộc một nơi tại một thời điểm. Không nhận được thiết bị thì kiểm tra theo thứ tự: cáp có dữ liệu và bo có nguồn → thiết bị có trong Devices → USB của VM → chương trình khác trên Windows đang giữ → Extension Pack, USB 2.0 controller, filter → trong guest: `lsusb`, `dmesg | tail`, `ls /dev/ttyUSB* /dev/ttyACM*` → rút cắm lại, cắm thẳng cổng máy, khởi động lại VM.

## IV.6. Workflow Dự án B (chỉ trong Ubuntu VM)

1. Bật Windows → VirtualBox → khởi động Ubuntu VM → cắm ESP32 (`ls /dev/ttyUSB*` thấy cổng).
2. Terminal: `source ~/.espressif/tools/activate_idf_v6.1.1.sh`, `cd ~/dwcstinhs/projects/esp32-motor-pid`, `git pull`.
3. Sửa code trong `main/`.
4. `idf.py build` (firmware ở `build/`, không vào Git).
5. `idf.py -p /dev/ttyUSB0 flash monitor` (thoát bằng Ctrl+]).
6. Ghi log: **đóng monitor trước**, rồi chạy script đọc serial ghi CSV (một chương trình mở cổng serial tại một thời điểm).
7. Vẽ đồ thị: terminal khác chỉ kích hoạt `embedded-env` (không kích hoạt ESP-IDF), chạy `scripts/plot.py`, lưu PNG vào `docs/`.
8. `git status` → `git add -A && git commit -m "..."` → `git push`.
9. Tắt VM bằng Shut down. **Không restore snapshot khi còn code chưa push.**

## IV.7. Workflow Dự án A

| Giai đoạn | Môi trường | Việc chính | Kết quả nằm ở |
|---|---|---|---|
| 1. RTL | Windows soạn → ISE VM chạy | `git pull`; sửa `rtl/`, `tb/`, `constraints/`; ISim; Synthesize → Implement → Generate Programming File; iMPACT nạp bo; commit/push từ Windows | `.bit` trong `ise/` (không vào Git); ảnh waveform `docs/img/sim_*` |
| 2. Pico firmware | Ubuntu | `git pull`; sửa `pico_fw/`; `cd pico_fw/build && cmake .. && make -j4`; giữ BOOTSEL khi cắm Pico, copy `.uf2` vào ổ `RPI-RP2`; `picocom` trên `/dev/ttyACM0`; commit/push | `.uf2` trong `pico_fw/build/` |
| 3. Tích hợp | ISE VM (nạp lại `.bit` nếu bo mất nguồn) → Ubuntu | Nối SPI (GP16/17/18/19) + GND chung; CLI `id` phải trả `0xA55A`; `set`/`get`; PulseView khi lỗi | Waveform đo thật |
| 4. Portfolio | Cả hai | Ảnh ISim (Windows) và ảnh PulseView (Ubuntu) với tiền tố tên khác nhau; README chỉ sửa ở Ubuntu; push cả hai rồi `git pull` chéo | GitHub |

- Pico và FPGA **độc lập**: Pico không cần `.bit`, ISE không cần file Pico. Thứ nối hai bên là tài liệu register map và dây SPI.
- Cấu hình FPGA qua JTAG **mất khi tắt nguồn bo** hoặc bấm nút PROG; bo có nguồn riêng nên tắt ISE VM không làm mất cấu hình.

## IV.8. Checklist khi chuyển môi trường

**Rời:** lưu mọi file → `git status` → commit + push → đóng chương trình đang giữ USB/serial.
**Vào:** `git pull` (nếu là clone) → đúng nhánh `main` → USB đã gắn đúng VM → kích hoạt đúng môi trường (ESP-IDF cho B; không kích hoạt khi chạy script Python).

## IV.9. Những điều tuyệt đối không làm

1. Không sửa cùng một file ở hai clone; không sửa ngoài vùng sở hữu.
2. Không sửa trước khi `git pull`; không rời môi trường khi chưa commit/push.
3. Không dùng shared folder để đồng bộ source bằng tay; không clone repo B hoặc A#2 vào shared folder.
4. Không chạy git từ trong ISE VM hay Ubuntu trên `ISE_Projects`.
5. Không để ISE tích "Copy to Project".
6. Không commit `build/`, `.bit`, `.uf2`, `sdkconfig`, venv.
7. Không restore snapshot khi còn code chưa push.
8. Không mở serial monitor và script log cùng lúc; không để hai VM cùng giữ một thiết bị USB.
9. Không `git push --force`.
10. Không rút USB hay tắt nóng VM khi đang flash hoặc nạp.

## IV.10. Đường dẫn và cấu hình quan trọng

| Mục | Giá trị |
|---|---|
| Kích hoạt ESP-IDF | `source ~/.espressif/tools/activate_idf_v6.1.1.sh` (IDF_PATH `~/.espressif/v6.1.1/esp-idf`) |
| Pico SDK | `/home/dwcstinhs/pico/pico-sdk` (`PICO_SDK_PATH`) |
| Repo B (Ubuntu) | `~/dwcstinhs/projects/esp32-motor-pid` |
| Repo A (Ubuntu) | `~/dwcstinhs/projects/fpga-servo-coprocessor` |
| Repo A (Windows) | `C:\ISE\ISE_Projects\fpga-servo-coprocessor` |
| Remote | `git@github.com:ngodh/esp32-motor-pid.git`, `git@github.com:ngodh/fpga-servo-coprocessor.git` |
| Python venv | `embedded-env` (matplotlib, pandas, pyserial) |
| Global folder | `D:\Ubuntu2204_shared_folder` |

## IV.11. Bộ nhớ (RAM) khi chạy hai VM

Máy 16 GB: Ubuntu 5288 MB + ISE 6144 MB ≈ 11.2 GB, Windows còn ≈ 4.8 GB. Kiểm tra bằng Task Manager → Memory: "In use" nên dưới khoảng 85%. Khi build ESP-IDF, theo dõi `free -h`; nếu `Swap used` vượt khoảng 500 MB hoặc báo `Killed signal terminated program cc1` thì tăng RAM Ubuntu thêm 1 GB. Đổi RAM: tắt hẳn VM → Settings → System → Motherboard → Base Memory (nếu bị mờ: Discard Saved State).

## IV.12. Còn CHƯA XÁC NHẬN

- Đường dẫn mount của `ISE_Projects` trong ISE VM (chạy `ls /media`; thường là `/media/sf_ISE_Projects`).
- Model bo Spartan-3E.
- `picotool` đã cài chưa (không bắt buộc: copy `.uf2` vào ổ `RPI-RP2` là đủ).
- Hiệu năng ISE khi làm việc trực tiếp trong shared folder.

---

# PHẦN V — SỔ TAY CỦA BẠN (tự cập nhật)

## Thông số phần cứng thực tế (cập nhật 20/11/2026)

| Mục | Giá trị |
|---|---|
| Motor chính | JGA25-370, 6 V, tỉ số 1/21.3 (≈280 RPM), trục 4 mm, 6 dây *(đã đặt mua)* |
| Motor thử nghiệm | Motor DC 3–6 V trong kit: 0.35–0.4 A, 19000 RPM @ 3 V, 2 dây, không encoder, 25×21 mm, trục 2 mm |
| Encoder | 11 xung/vòng trục motor, 2 kênh A–B, cấp 3.3–5 V (dùng 3.3 V); ≈ 937 count/vòng trục ra khi đọc ×4, cần hiệu chuẩn |
| Cầu H | TB6612FNG *(đã đặt mua)*; L293D trong kit để dự phòng |
| Servo | 2 (trong kit); mua thêm sau nếu cần |
| Nguồn | Adapter Vilros 5 V 2.5 A, đầu ra micro-USB → breakout micro-USB cái *(đã đặt 2 cái)* |
| Logic analyzer | USB 24M 8CH *(đã đặt mua)*, dùng PulseView |
| Dây nối | Đực-đực, đực-cái, cái-cái, đủ số lượng |
| Spartan-3E | Nguồn riêng; nạp qua USB Type-B (đã nạp được từ ISE VM); model: CHƯA XÁC NHẬN |
| Pico | Chưa hàn header; đã đặt thanh header đực 1×40 |
| ESP32 | Silicon Labs CP210x, ID `10c4:ea60` |
| Phần mềm | ESP-IDF v6.1.1 (EIM), Pico SDK (tinyusb 0.18.0), arm-none-eabi-gcc 10.3.1, CMake 3.22.1, Ninja 1.10.1, Python 3.10.12, PulseView, picocom |
| Máy tính | Windows 11, RAM 16 GB. Ubuntu VM 22.04.5: 4 CPU, RAM 5288 MB, ổ 59 GB. ISE VM (Oracle Linux, AMD): RAM 6144 MB |

## Nhật ký lỗi (ghi mỗi lần gặp lỗi)

| Ngày | Dự án | Hiện tượng | Giả thuyết | Cách kiểm tra | Nguyên nhân thật | Cách sửa |
|---|---|---|---|---|---|---|
| 20/11/2026 | A (Pico SDK) | `ls lib/tinyusb` không in gì (thư mục rỗng) | Clone Pico SDK thiếu submodule | `git submodule status`: dòng `lib/tinyusb` có dấu `-` | Quên `--recurse-submodules` khi clone | `cd $PICO_SDK_PATH && git submodule update --init`; kiểm tra lại: `tinyusb` (0.18.0) có nội dung |
| | | | | | | |

## Nhật ký thay đổi kế hoạch

| Ngày | Thay đổi | Lý do |
|---|---|---|
| 20/11/2026 | Motor chính chuyển sang JGA25-370 6 V 1/21.3 có encoder; motor 3 V trong kit chỉ để thử nghiệm | 19000 RPM với 1 xung/vòng cho độ phân giải đo tốc độ quá kém |
| 20/11/2026 | Cầu H: TB6612FNG (L293D dự phòng) | Motor 6 V trên nguồn 5 V cần cầu H tụt áp ít |
| 20/11/2026 | Nguồn motor/servo: adapter Vilros 5 V 2.5 A qua breakout micro-USB | Đã có adapter; cổng ra là micro-USB (không phải USB-C) |
| 20/11/2026 | Repo A có 2 clone (Windows + Ubuntu), chia quyền sở hữu thư mục; thêm thư mục `ise/` | ISE VM chỉ nhìn thấy đĩa Windows; Ubuntu build Pico trên đĩa riêng |
| 20/11/2026 | RAM Ubuntu VM 8192 → 5288 MB (ISE 6144 MB) | Máy 16 GB, chạy hai VM cùng lúc |
| | | |

## Từ mới tôi vừa học (tự thêm)

- **Submodule (Git):** repo con nằm trong repo cha; phải tải riêng bằng `git submodule update --init`
- **vboxsf / Shared Folder:** cách VirtualBox cho VM thấy một thư mục của Windows
- **USB filter:** quy tắc VirtualBox tự gắn thiết bị USB vào VM khi cắm
- **Save State vs Pause:** Save State ghi RAM của VM ra đĩa và giải phóng RAM; Pause thì không
- 

## Tài liệu cần tìm đọc

- Datasheet / manual: ESP32 Technical Reference Manual (phần LEDC, PCNT), INA219 datasheet (Texas Instruments), TB6612FNG datasheet
- Spartan-3E Starter Kit User Guide (UG230): sơ đồ chân, xung nhịp, header mở rộng
- Raspberry Pi Pico C/C++ SDK guide (phần SPI)
- ESP-IDF Programming Guide (FreeRTOS, I2C master, LEDC, PCNT)
- Sách FPGA mà bạn đang học (Pong Chu, Morris Mano): phần bộ đếm, FSM, testbench, UART
