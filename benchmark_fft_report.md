# Basys 3 Yapılandırılabilir FFT İşlemcisi Benchmark Raporu

Bu rapor, farklı FFT boyutları (32, 64, 128, 256, 512, 1024) için kaynak, performans ve güç tüketimi metriklerini belgelemektedir.

## Proje Genel Bilgileri

- **FPGA:** Digilent Basys 3 (Xilinx Artix-7 XC7A35T)
- **Araç:** Vivado 2022.2
- **Sistem Saati:** 100 MHz
- **Veri Formatı:** 16-bit Q8.8 Sabit Noktalı
- **FFT IP:** Xilinx FFT IP Core 9.1 (Pipelined Streaming I/O)

## Metrikler (FFT Boyutu: 32)

### Kaynak Kullanımı
- **LUTs (Look-Up Tables):** ___ / 20800 (__._%)
- **Registers (FF):** ___ / 41600 (__._%)
- **BRAM (Block RAM):** ___ / 50 (__._%)
- **DSP Slices:** ___ / 90 (__._%)
- **IO Pins:** ___ / 106 (__._%)

### Performans (Zamanlama)
- **WNS (Worst Negative Slack):** ___ ns
- **TNS (Total Negative Slack):** ___ ns
- **Hesaplanan Fmax:** ___ MHz
- **Setup Violations:** ___
- **Hold Violations:** ___

### Güç Tüketimi
- **Total Power:** ___ W
- **Dynamic Power:** ___ W
- **Static Power:** ___ W
- **I/O Power:** ___ W
- **Clock Power:** ___ W

---

## Metrikler (FFT Boyutu: 64)

### Kaynak Kullanımı
- **LUTs (Look-Up Tables):** ___ / 20800 (__._%)
- **Registers (FF):** ___ / 41600 (__._%)
- **BRAM (Block RAM):** ___ / 50 (__._%)
- **DSP Slices:** ___ / 90 (__._%)
- **IO Pins:** ___ / 106 (__._%)

### Performans (Zamanlama)
- **WNS (Worst Negative Slack):** ___ ns
- **TNS (Total Negative Slack):** ___ ns
- **Hesaplanan Fmax:** ___ MHz
- **Setup Violations:** ___
- **Hold Violations:** ___

### Güç Tüketimi
- **Total Power:** ___ W
- **Dynamic Power:** ___ W
- **Static Power:** ___ W
- **I/O Power:** ___ W
- **Clock Power:** ___ W

---

## Metrikler (FFT Boyutu: 128)

### Kaynak Kullanımı
- **LUTs (Look-Up Tables):** ___ / 20800 (__._%)
- **Registers (FF):** ___ / 41600 (__._%)
- **BRAM (Block RAM):** ___ / 50 (__._%)
- **DSP Slices:** ___ / 90 (__._%)
- **IO Pins:** ___ / 106 (__._%)

### Performans (Zamanlama)
- **WNS (Worst Negative Slack):** ___ ns
- **TNS (Total Negative Slack):** ___ ns
- **Hesaplanan Fmax:** ___ MHz
- **Setup Violations:** ___
- **Hold Violations:** ___

### Güç Tüketimi
- **Total Power:** ___ W
- **Dynamic Power:** ___ W
- **Static Power:** ___ W
- **I/O Power:** ___ W
- **Clock Power:** ___ W

---

## Metrikler (FFT Boyutu: 256)

### Kaynak Kullanımı
- **LUTs (Look-Up Tables):** ___ / 20800 (__._%)
- **Registers (FF):** ___ / 41600 (__._%)
- **BRAM (Block RAM):** ___ / 50 (__._%)
- **DSP Slices:** ___ / 90 (__._%)
- **IO Pins:** ___ / 106 (__._%)

### Performans (Zamanlama)
- **WNS (Worst Negative Slack):** ___ ns
- **TNS (Total Negative Slack):** ___ ns
- **Hesaplanan Fmax:** ___ MHz
- **Setup Violations:** ___
- **Hold Violations:** ___

### Güç Tüketimi
- **Total Power:** ___ W
- **Dynamic Power:** ___ W
- **Static Power:** ___ W
- **I/O Power:** ___ W
- **Clock Power:** ___ W

---

## Metrikler (FFT Boyutu: 512)

### Kaynak Kullanımı
- **LUTs (Look-Up Tables):** ___ / 20800 (__._%)
- **Registers (FF):** ___ / 41600 (__._%)
- **BRAM (Block RAM):** ___ / 50 (__._%)
- **DSP Slices:** ___ / 90 (__._%)
- **IO Pins:** ___ / 106 (__._%)

### Performans (Zamanlama)
- **WNS (Worst Negative Slack):** ___ ns
- **TNS (Total Negative Slack):** ___ ns
- **Hesaplanan Fmax:** ___ MHz
- **Setup Violations:** ___
- **Hold Violations:** ___

### Güç Tüketimi
- **Total Power:** ___ W
- **Dynamic Power:** ___ W
- **Static Power:** ___ W
- **I/O Power:** ___ W
- **Clock Power:** ___ W

---

## Metrikler (FFT Boyutu: 1024)

### Kaynak Kullanımı
- **LUTs (Look-Up Tables):** ___ / 20800 (__._%)
- **Registers (FF):** ___ / 41600 (__._%)
- **BRAM (Block RAM):** ___ / 50 (__._%)
- **DSP Slices:** ___ / 90 (__._%)
- **IO Pins:** ___ / 106 (__._%)

### Performans (Zamanlama)
- **WNS (Worst Negative Slack):** ___ ns
- **TNS (Total Negative Slack):** ___ ns
- **Hesaplanan Fmax:** ___ MHz
- **Setup Violations:** ___
- **Hold Violations:** ___

### Güç Tüketimi
- **Total Power:** ___ W
- **Dynamic Power:** ___ W
- **Static Power:** ___ W
- **I/O Power:** ___ W
- **Clock Power:** ___ W

---

## Karşılaştırma Tablosu

| FFT Boyutu | LUTs | Registers | BRAM | DSP | Fmax (MHz) | Total Power (W) |
|------------|------|-----------|------|-----|------------|-----------------|
| 32         | ___  | ___       | ___  | ___ | ___        | ___             |
| 64         | ___  | ___       | ___  | ___ | ___        | ___             |
| 128        | ___  | ___       | ___  | ___ | ___        | ___             |
| 256        | ___  | ___       | ___  | ___ | ___        | ___             |
| 512        | ___  | ___       | ___  | ___ | ___        | ___             |
| 1024       | ___  | ___       | ___  | ___ | ___        | ___             |

## Analiz ve Sonuçlar

### Kaynak Kullanımı Trendi
- **LUT Kullanımı:** FFT boyutu arttıkça LUT kullanımının nasıl değiştiğini açıklayın.
- **BRAM Kullanımı:** BRAM kullanımının FFT boyutuyla ilişkisini analiz edin.
- **DSP Kullanımı:** DSP slice kullanımının trend analizini yapın.

### Performans Analizi
- **Fmax Değişimi:** Farklı FFT boyutlarında maksimum frekans değişimini değerlendirin.
- **Zamanlama Kısıtları:** Critical path analizini ve timing violations'ları açıklayın.

### Güç Tüketimi Analizi
- **Güç Skalabilite:** FFT boyutu ile güç tüketimi arasındaki ilişkiyi analiz edin.
- **Dinamik vs Statik Güç:** Her FFT boyutu için dinamik ve statik güç oranlarını karşılaştırın.

## Vivado Rapor Oluşturma Talimatları

### 1. Utilization Raporu
```tcl
# Synthesis sonrası
report_utilization -file utilization_post_synth.rpt
report_utilization -hierarchical -file utilization_hierarchical.rpt

# Implementation sonrası
report_utilization -file utilization_post_impl.rpt
```

### 2. Timing Raporu
```tcl
# Timing summary
report_timing_summary -file timing_summary.rpt

# Detailed timing
report_timing -max_paths 10 -nworst 3 -delay_type min_max -sort_by group -file timing_detailed.rpt
```

### 3. Power Raporu
```tcl
# Power analysis
report_power -file power_analysis.rpt
report_power -hierarchical -file power_hierarchical.rpt
```

### 4. Raporları Okuma ve Doldurma
1. **Vivado'da Reports sekmesini açın**
2. **Post-Synthesis veya Post-Implementation raporlarını seçin**
3. **Utilization Summary'den LUT, FF, BRAM, DSP değerlerini alın**
4. **Timing Summary'den WNS, TNS, Fmax değerlerini alın**
5. **Power Report'tan güç tüketim değerlerini alın**
6. **Bu değerleri yukarıdaki template'e doldurun**

## PYNQ Z2 ile Karşılaştırma İçin Notlar

Bu rapordan elde edilen metrikler, gelecekte PYNQ Z2 üzerinde yapılacak benzer tasarımla karşılaştırılacaktır. Özellikle aşağıdaki metrikler kritik öneme sahiptir:

- **Kaynak Verimliliği:** LUT/FF/BRAM kullanım oranları
- **Performans:** Maksimum çalışma frekansı ve throughput
- **Güç Tüketimi:** Toplam ve dinamik güç değerleri
- **Implementasyon Süresi:** Synthesis ve implementation süreleri

---

**Rapor Tarihi:** ___________  
**Raporu Hazırlayan:** ___________  
**Vivado Versiyonu:** 2022.2