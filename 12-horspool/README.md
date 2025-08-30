# Running (NASM + LD)

Repository ini berisi contoh program **Assembly (NASM)** untuk horspool algorithm dan sebuah script `run.sh` untuk memudahkan proses **compile, link, dan run** kode ASM.

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
### Output berhasil (sesuai aturan maksimal 32 karakter pada teks)
<div align="center">
  <img width="544" height="220" alt="image" src="https://github.com/user-attachments/assets/abf91bdf-28ab-41b1-95a3-64bf90be7196" />
  <img width="574" height="241" alt="image" src="https://github.com/user-attachments/assets/6d294c9b-c2c1-4f6f-9997-87b12a5600ec" />
  <img width="597" height="198" alt="image" src="https://github.com/user-attachments/assets/c00cddd7-af9b-419e-b37a-0ea457e37892" />
</div>


### output gagal (melanggar aturan 32 karakter)
<p align="center">
  <img width="637" height="162" alt="image" src="https://github.com/user-attachments/assets/3ea5e6d4-0321-4e63-8d08-3b06bb29af95" />
</p>
