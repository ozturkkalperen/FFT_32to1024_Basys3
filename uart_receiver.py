#!/usr/bin/env python3
"""
UART Receiver for FFT Processor Data
Receives and analyzes FFT results from Basys 3 FPGA
Compatible with Python 3.6+
"""

import serial
import struct
import numpy as np
import matplotlib.pyplot as plt
import argparse
import time
from typing import List, Tuple

class FFTDataReceiver:
    def __init__(self, port: str, baudrate: int = 115200):
        """
        Initialize UART receiver for FFT data
        
        Args:
            port: Serial port name (e.g., 'COM3' on Windows, '/dev/ttyUSB0' on Linux)
            baudrate: Baud rate (default: 115200)
        """
        self.port = port
        self.baudrate = baudrate
        self.serial_conn = None
        
    def connect(self):
        """Establish serial connection"""
        try:
            self.serial_conn = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE,
                timeout=1
            )
            print(f"Connected to {self.port} at {self.baudrate} baud")
            return True
        except serial.SerialException as e:
            print(f"Failed to connect to {self.port}: {e}")
            return False
    
    def disconnect(self):
        """Close serial connection"""
        if self.serial_conn and self.serial_conn.is_open:
            self.serial_conn.close()
            print("Disconnected from serial port")
    
    def receive_fft_data(self, fft_size: int) -> List[Tuple[int, int]]:
        """
        Receive FFT data from UART
        
        Args:
            fft_size: Expected FFT size (32, 64, 128, 256, 512, 1024)
            
        Returns:
            List of (real, imaginary) tuples
        """
        if not self.serial_conn or not self.serial_conn.is_open:
            print("Serial connection not established")
            return []
        
        fft_data = []
        bytes_expected = fft_size * 4  # 4 bytes per complex sample
        bytes_received = 0
        
        print(f"Waiting for {fft_size} FFT samples ({bytes_expected} bytes)...")
        
        while bytes_received < bytes_expected:
            if self.serial_conn.in_waiting >= 4:
                # Read 4 bytes for one complex sample
                data = self.serial_conn.read(4)
                if len(data) == 4:
                    # Unpack as signed 16-bit integers (big-endian)
                    real_high, real_low, imag_high, imag_low = struct.unpack('BBBB', data)
                    
                    # Combine bytes to form 16-bit signed integers
                    real = (real_high << 8) | real_low
                    imag = (imag_high << 8) | imag_low
                    
                    # Convert to signed if necessary
                    if real > 32767:
                        real -= 65536
                    if imag > 32767:
                        imag -= 65536
                    
                    fft_data.append((real, imag))
                    bytes_received += 4
                    
                    # Progress indicator
                    if len(fft_data) % (fft_size // 10) == 0:
                        progress = (len(fft_data) / fft_size) * 100
                        print(f"Progress: {progress:.1f}%")
            else:
                time.sleep(0.001)  # Short delay to avoid busy waiting
        
        print(f"Received {len(fft_data)} FFT samples")
        return fft_data
    
    def q8_8_to_float(self, value: int) -> float:
        """Convert Q8.8 fixed-point to float"""
        return value / 256.0
    
    def calculate_magnitude_spectrum(self, fft_data: List[Tuple[int, int]]) -> List[float]:
        """Calculate magnitude spectrum from complex FFT data"""
        magnitudes = []
        for real, imag in fft_data:
            # Convert Q8.8 to float
            real_f = self.q8_8_to_float(real)
            imag_f = self.q8_8_to_float(imag)
            
            # Calculate magnitude
            magnitude = np.sqrt(real_f**2 + imag_f**2)
            magnitudes.append(magnitude)
        
        return magnitudes
    
    def find_peak_frequency(self, magnitudes: List[float], sample_rate: float = 1.0) -> Tuple[int, float]:
        """Find peak frequency in magnitude spectrum"""
        peak_index = np.argmax(magnitudes)
        peak_magnitude = magnitudes[peak_index]
        
        # Calculate frequency (assuming normalized frequency)
        peak_frequency = (peak_index * sample_rate) / len(magnitudes)
        
        return peak_index, peak_frequency
    
    def plot_results(self, fft_data: List[Tuple[int, int]], fft_size: int):
        """Plot FFT results"""
        # Calculate magnitude spectrum
        magnitudes = self.calculate_magnitude_spectrum(fft_data)
        
        # Find peak
        peak_index, peak_freq = self.find_peak_frequency(magnitudes)
        
        # Create frequency axis
        freq_axis = np.arange(len(magnitudes)) / len(magnitudes)
        
        # Plot
        plt.figure(figsize=(12, 8))
        
        # Magnitude spectrum
        plt.subplot(2, 2, 1)
        plt.plot(freq_axis, magnitudes)
        plt.axvline(x=peak_freq, color='r', linestyle='--', 
                   label=f'Peak at index {peak_index}')
        plt.title(f'FFT Magnitude Spectrum ({fft_size} points)')
        plt.xlabel('Normalized Frequency')
        plt.ylabel('Magnitude')
        plt.legend()
        plt.grid(True)
        
        # Real part
        plt.subplot(2, 2, 2)
        real_parts = [self.q8_8_to_float(r) for r, i in fft_data]
        plt.plot(real_parts)
        plt.title('Real Part')
        plt.xlabel('Sample Index')
        plt.ylabel('Amplitude')
        plt.grid(True)
        
        # Imaginary part
        plt.subplot(2, 2, 3)
        imag_parts = [self.q8_8_to_float(i) for r, i in fft_data]
        plt.plot(imag_parts)
        plt.title('Imaginary Part')
        plt.xlabel('Sample Index')
        plt.ylabel('Amplitude')
        plt.grid(True)
        
        # Phase spectrum
        plt.subplot(2, 2, 4)
        phases = [np.arctan2(self.q8_8_to_float(i), self.q8_8_to_float(r)) 
                 for r, i in fft_data]
        plt.plot(freq_axis, phases)
        plt.title('Phase Spectrum')
        plt.xlabel('Normalized Frequency')
        plt.ylabel('Phase (radians)')
        plt.grid(True)
        
        plt.tight_layout()
        plt.show()
        
        print(f"\nResults Summary:")
        print(f"FFT Size: {fft_size}")
        print(f"Peak Index: {peak_index}")
        print(f"Peak Frequency: {peak_freq:.4f} (normalized)")
        print(f"Peak Magnitude: {magnitudes[peak_index]:.4f}")

def main():
    parser = argparse.ArgumentParser(description='FFT UART Data Receiver')
    parser.add_argument('--port', '-p', required=True, 
                       help='Serial port (e.g., COM3, /dev/ttyUSB0)')
    parser.add_argument('--fft-size', '-s', type=int, default=32,
                       choices=[32, 64, 128, 256, 512, 1024],
                       help='FFT size to receive')
    parser.add_argument('--baudrate', '-b', type=int, default=115200,
                       help='Baud rate (default: 115200)')
    parser.add_argument('--plot', action='store_true',
                       help='Plot received data')
    parser.add_argument('--save', '-o', 
                       help='Save data to file (CSV format)')
    
    args = parser.parse_args()
    
    # Create receiver instance
    receiver = FFTDataReceiver(args.port, args.baudrate)
    
    try:
        # Connect to serial port
        if not receiver.connect():
            return
        
        # Receive FFT data
        fft_data = receiver.receive_fft_data(args.fft_size)
        
        if not fft_data:
            print("No data received")
            return
        
        # Save data if requested
        if args.save:
            with open(args.save, 'w') as f:
                f.write("Index,Real,Imaginary,Real_Float,Imag_Float\n")
                for i, (real, imag) in enumerate(fft_data):
                    real_f = receiver.q8_8_to_float(real)
                    imag_f = receiver.q8_8_to_float(imag)
                    f.write(f"{i},{real},{imag},{real_f:.6f},{imag_f:.6f}\n")
            print(f"Data saved to {args.save}")
        
        # Plot if requested
        if args.plot:
            receiver.plot_results(fft_data, args.fft_size)
        
        # Print summary
        magnitudes = receiver.calculate_magnitude_spectrum(fft_data)
        peak_index, peak_freq = receiver.find_peak_frequency(magnitudes)
        print(f"\nPeak detected at index {peak_index} (frequency {peak_freq:.4f})")
        
    except KeyboardInterrupt:
        print("\nInterrupted by user")
    finally:
        receiver.disconnect()

if __name__ == "__main__":
    main()