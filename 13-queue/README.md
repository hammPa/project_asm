# Running (NASM + LD)

Repository ini berisi contoh program **Assembly (NASM)** untuk data structure & algorithm tepatnya queue dan sebuah script `run.sh` untuk memudahkan proses **compile, link, dan run** kode ASM.

---

## Prasyarat

Sebelum menjalankan, pastikan sudah menginstall:

- **NASM** (Netwide Assembler)  
- **LD** (GNU Linker)  

### Instalasi di Debian/Ubuntu
```bash
sudo apt update
sudo apt install nasm build-essential gcc-multilib
```

---

## Cara Menjalankan

Gunakan script run.sh untuk compile dan run file .asm:
```bash
./run.sh file1.asm file2.asm ...
```

---

## Isi run.sh
```bash
#!/bin/bash

# Cek minimal 1 file .asm
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 file1.asm file2.asm ..."
    exit 1
fi

# Nama output = nama file pertama (tanpa .asm)
firstfile="$1"
output="${firstfile%.asm}"

# Compile semua file .asm ke .o
for file in "$@"; do
    nasm -f elf32 "$file" -o "${file%.asm}.o"
done

# Kumpulkan semua file .o
objects=""
for file in "$@"; do
    objects="$objects ${file%.asm}.o"
done

# Link semua file .o
ld -m elf_i386 $objects -o "$output"

# Jalankan hasilnya
./"$output"

```

---

## Contoh Output:
<p align="center">
  <img width="456" height="724" alt="image" src="https://github.com/user-attachments/assets/cfac7cc3-67cc-4f87-acdb-5fa2f971ae28" />
</p>
