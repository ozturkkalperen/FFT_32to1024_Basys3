# Basys 3 Yapılandırılabilir FFT İşlemcisi

Bu proje, Digilent Basys 3 FPGA kartı için Vivado 2022.2 ve Verilog kullanılarak geliştirilmiş kapsamlı bir dijital sinyal işleme sistemidir. Proje, 32'den 1024'e kadar farklı noktalarda yapılandırılabilen bir FFT (Hızlı Fourier Dönüşümü) işlemcisi içermektedir.

## 🎯 Proje Özellikleri

- **Yapılandırılabilir FFT Boyutu:** 32, 64, 128, 256, 512, 1024 nokta
- **Veri Formatı:** 16-bit Q8.8 sabit noktalı
- **Çıkış Arayüzleri:** 
  - UART (115200 baud, 8-N-1) - PC'ye detaylı veri gönderimi
  - 7-segment gösterge - Tepe frekansı indeksi gösterimi
- **Benchmark Odaklı:** Kaynak, performans ve güç tüketimi metrikleri

## 📁 Proje Yapısı

```
├── data_generator.v           # Test verisi üreteci (kare dalga)
├── seven_segment_driver.v     # 7-segment gösterge sürücüsü
├── uart_tx.v                  # UART verici modülü
├── magnitude_calculator.v     # FFT çıkışı büyüklük hesaplayıcısı
├── peak_detector.v           # Tepe frekansı tespit edici
├── uart_data_sender.v        # UART veri gönderici
├── top_fft_processor.v       # Ana modül (FSM kontrolü)
├── basys3_constraints.xdc    # Basys 3 pin kısıtları
├── tb_top_fft_processor.v    # Testbench
├── create_fft_project.tcl    # Vivado proje oluşturma scripti
├── benchmark_fft_report.md   # Benchmark rapor şablonu
└── README.md                 # Bu dosya
```

## 🚀 Hızlı Başlangıç

### Gereksinimler
- Vivado 2022.2 veya üzeri
- Digilent Basys 3 FPGA kartı
- USB kablosu (programlama ve UART için)

### 1. Proje Oluşturma
```bash
# Vivado'yu TCL modunda başlatın
vivado -mode tcl

# Proje oluşturma scriptini çalıştırın
source create_fft_project.tcl
```

### 2. FFT IP Entegrasyonu
Proje oluşturulduktan sonra:
1. Vivado GUI'yi açın: `vivado ./vivado_project/fft_processor_basys3.xpr`
2. `top_fft_processor.v` dosyasında FFT IP placeholder'ını gerçek IP ile değiştirin
3. IP Catalog'dan FFT IP'yi yapılandırın (script otomatik olarak oluşturur)

### 3. Synthesis ve Implementation
```tcl
# Farklı FFT boyutları için synthesis
launch_runs synth_fft_32 -jobs 8
launch_runs synth_fft_64 -jobs 8
launch_runs synth_fft_128 -jobs 8
# ... diğer boyutlar

# Implementation
launch_runs impl_1 -jobs 8
```

### 4. Bitstream Oluşturma ve Programlama
```tcl
launch_runs impl_1 -to_step write_bitstream -jobs 8
```

## 🔧 Sistem Mimarisi

### Ana FSM Durumları
1. **CONFIG_FFT:** FFT IP'sini yapılandır
2. **SEND_DATA_TO_FFT:** Test verisini FFT'ye gönder
3. **WAIT_FFT_RESULT:** FFT hesaplamasını bekle
4. **PROCESS_RESULTS:** Sonuçları işle ve tepe frekansını bul
5. **SEND_UART_DATA:** Sonuçları UART üzerinden gönder

### Veri Akışı
```
Data Generator → FFT IP → Magnitude Calculator → Peak Detector
                    ↓
UART Sender ← Result Buffer ← FFT Output
```

## 🎛️ Kullanım

### Switch Yapılandırması
- **sw[4:0]:** FFT boyutu seçimi
  - `00000` → 32 nokta
  - `00001` → 64 nokta
  - `00010` → 128 nokta
  - `00011` → 256 nokta
  - `00100` → 512 nokta
  - `00101` → 1024 nokta

### Çıkışlar
- **7-Segment Gösterge:** Tepe frekansının indeksini gösterir
- **UART (115200 baud):** Her FFT sonucu için 4 byte gönderir
  - Byte 1: Real kısmı (yüksek 8 bit)
  - Byte 2: Real kısmı (düşük 8 bit)
  - Byte 3: İmajiner kısmı (yüksek 8 bit)
  - Byte 4: İmajiner kısmı (düşük 8 bit)

## 📊 Benchmark ve Raporlama

### Rapor Oluşturma
```tcl
# Kaynak kullanımı
report_utilization -file utilization_post_impl.rpt

# Zamanlama analizi
report_timing_summary -file timing_summary.rpt

# Güç analizi
report_power -file power_analysis.rpt
```

### Benchmark Şablonu
`benchmark_fft_report.md` dosyası, farklı FFT boyutları için metrikleri kaydetmek üzere hazırlanmış şablonu içerir.

## 🔍 Modül Detayları

### Data Generator (`data_generator.v`)
- Q8.8 formatında kare dalga üretir
- FFT boyutuna göre uyarlanabilir periyot
- AXI4-Stream uyumlu çıkış

### Seven Segment Driver (`seven_segment_driver.v`)
- 4 haneli gösterge kontrolü
- Multiplexing ile güncelleme
- BCD dönüştürme dahili

### UART TX (`uart_tx.v`)
- 115200 baud, 8-N-1 yapılandırması
- Busy/Done sinyal kontrolü
- 100MHz saat için optimize edilmiş

### Magnitude Calculator (`magnitude_calculator.v`)
- Yaklaşık büyüklük hesabı: |real| + |imag|
- 2-aşamalı pipeline
- Kaynak tasarruflu tasarım

### Peak Detector (`peak_detector.v`)
- Gerçek zamanlı tepe tespit
- İndeks ve büyüklük çıkışı
- FFT boyutuna uyarlanabilir

## 🧪 Test ve Doğrulama

### Simulation
```bash
# Testbench'i çalıştırın
xsim tb_top_fft_processor
```

### Hardware Test
1. Bitstream'i FPGA'ya yükleyin
2. Switch'lerle FFT boyutunu ayarlayın
3. 7-segment göstergeyi gözlemleyin
4. UART çıkışını seri terminal ile izleyin

## 📈 Performans Beklentileri

### Basys 3 (Artix-7) Kaynakları
- **LUTs:** 20,800
- **Flip-Flops:** 41,600
- **BRAM:** 50 blok
- **DSP Slices:** 90

### Tahmini Kullanım (1024-nokta FFT)
- **LUTs:** ~8,000-12,000 (%40-60)
- **BRAM:** ~20-30 (%40-60)
- **DSP:** ~40-60 (%45-65)

## 🔄 PYNQ Z2 Karşılaştırması İçin Hazırlık

Bu tasarım, gelecekte PYNQ Z2 üzerinde yapılacak implementasyon ile karşılaştırılmak üzere optimize edilmiştir. Karşılaştırma metrikleri:

- **Kaynak Verimliliği**
- **Maksimum Frekans**
- **Güç Tüketimi**
- **Implementation Süresi**

## 🐛 Troubleshooting

### Yaygın Sorunlar
1. **FFT IP Bulunamıyor:** IP Catalog'u yenileyin
2. **Timing Violations:** Clock constraints'leri kontrol edin
3. **UART Veri Bozuk:** Baud rate ayarlarını doğrulayın

### Debug İpuçları
- ILA (Integrated Logic Analyzer) kullanarak iç sinyalleri gözlemleyin
- Simulation'da UART çıkışını monitor edin
- 7-segment göstergeyi test için kullanın

## 📝 Lisans

Bu proje eğitim amaçlı geliştirilmiştir. Ticari kullanım için uygun lisans alınmalıdır.

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Branch'e push yapın (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## 📞 İletişim

Proje ile ilgili sorularınız için issue açabilir veya email gönderebilirsiniz.

---

**Not:** Bu proje benchmark odaklıdır ve PYNQ Z2 ile karşılaştırma için optimize edilmiştir. Tüm metrikler `benchmark_fft_report.md` dosyasında belgelenmelidir.